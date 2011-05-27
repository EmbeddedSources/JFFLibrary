#import "JFFBlocksFunctions.h"

#import "JFFSimpleBlockHolder.h"

#import <Foundation/Foundation.h>

typedef JFFAsyncOperation (*MergeTwoLoadersPtr)( JFFAsyncOperation, JFFAsyncOperation );

static JFFAsyncOperation createEmptyLoaderBlock()
{
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_, JFFCancelHandler cancel_callback_, JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_( [ NSNull null ], nil );
      return [ [ ^() { /*do nothing*/ } copy ] autorelease ];
   } copy ] autorelease ];
}

static JFFAsyncOperation MergeLoaders( MergeTwoLoadersPtr merger_, NSArray* blocks_ )
{
   if ( ![ blocks_ lastObject ] )
      return createEmptyLoaderBlock();

   JFFAsyncOperation first_block_ = [ blocks_ objectAtIndex: 0 ];

   for ( JFFAsyncOperation second_block_ in blocks_ )
   {
      if ( second_block_ == first_block_ )
         continue;

      first_block_ = merger_( first_block_, second_block_ );
   }

   return first_block_;
}

static JFFAsyncOperation sequenceOfAsyncOperationsPair( JFFAsyncOperation first_loader_, JFFAsyncOperation second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ [ first_loader_ copy ] autorelease ];
   second_loader_ = [ [ second_loader_ copy ] autorelease ];

   if ( second_loader_ == nil )
      return first_loader_;

   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFSimpleBlockHolder* block_holder_ = [ JFFSimpleBlockHolder simpleBlockHolder ];

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      JFFCancelAsyncOpration first_cancel_ = first_loader_( progress_callback_
                                                           , cancel_callback_
                                                           , ^( id result_, NSError* error_ )
      {
         if ( error_ )
         {
            done_callback_( nil, error_ );
         }
         else
         {
            block_holder_.simpleBlock = second_loader_( progress_callback_
                                                       , cancel_callback_
                                                       , done_callback_ );
         }
      } );
      if ( !block_holder_.simpleBlock )
         block_holder_.simpleBlock = first_cancel_;

      return [ [ ^()
      {
         [ block_holder_ performBlockOnce ];
      } copy ] autorelease ];
   } copy ] autorelease ];
}

JFFAsyncOperation sequenceOfAsyncOperations( JFFAsyncOperation first_loader_, JFFAsyncOperation second_loader_, ... )
{
   JFFAsyncOperation first_block_ = first_loader_;

   va_list args;
   va_start( args, second_loader_ );
   for ( JFFAsyncOperation second_block_ = second_loader_; second_block_ != nil; second_block_ = va_arg( args, JFFAsyncOperation ) )
   {
      first_block_ = sequenceOfAsyncOperationsPair( first_block_, second_block_ );
   }
   va_end( args );

   return first_block_;
}

JFFAsyncOperation sequenceOfAsyncOperationsArray( NSArray* blocks_ )
{
   return MergeLoaders( sequenceOfAsyncOperationsPair, blocks_ );
}

static JFFAsyncOperation trySequenceOfAsyncOperationsPair( JFFAsyncOperation first_loader_, JFFAsyncOperation second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ [ first_loader_ copy ] autorelease ];
   second_loader_ = [ [ second_loader_ copy ] autorelease ];

   if ( second_loader_ == nil )
      return first_loader_;

   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFSimpleBlockHolder* block_holder_ = [ JFFSimpleBlockHolder simpleBlockHolder ];

      done_callback_ = [ [ done_callback_ copy ] autorelease ];

      JFFCancelAsyncOpration first_cancel_ = first_loader_( progress_callback_, cancel_callback_, ^( id result_, NSError* error_ )
      {
         if ( error_ )
         {
            block_holder_.simpleBlock = second_loader_( progress_callback_, cancel_callback_, done_callback_ );
         }
         else
         {
            done_callback_( result_, nil );
         }
      } );
      if ( !block_holder_.simpleBlock )
         block_holder_.simpleBlock = first_cancel_;

      return [ [ ^()
      {
         [ block_holder_ performBlockOnce ];
      } copy ] autorelease ];
   } copy ] autorelease ];
}

JFFAsyncOperation trySequenceOfAsyncOperations( JFFAsyncOperation first_loader_, JFFAsyncOperation second_loader_, ... )
{
   JFFAsyncOperation first_block_ = first_loader_;

   va_list args;
   va_start( args, second_loader_ );
   for ( JFFAsyncOperation second_block_ = second_loader_; second_block_ != nil; second_block_ = va_arg( args, JFFAsyncOperation ) )
   {
      first_block_ = trySequenceOfAsyncOperationsPair( first_block_, second_block_ );
   }
   va_end( args );

   return first_block_;
}

static JFFAsyncOperation groupOfAsyncOperationsPair( JFFAsyncOperation first_loader_, JFFAsyncOperation second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ [ first_loader_ copy ] autorelease ];
   second_loader_ = [ [ second_loader_ copy ] autorelease ];

   if ( second_loader_ == nil )
      return first_loader_;

   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL loaded_ = NO;
      __block NSError* block_error_ = nil;

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      JFFDidFinishAsyncOperationHandler result_block_ = ^( id result_, NSError* error_ )
      {
         if ( loaded_ )
         {
            error_ = error_ ? error_ : block_error_;
            done_callback_( error_ ? nil : [ NSNull null ], error_ );
            return;
         }
         loaded_ = YES;
         block_error_ = error_;
      };

      JFFSimpleBlockHolder* cancel_holder1_ = [ JFFSimpleBlockHolder simpleBlockHolder ];
      JFFSimpleBlockHolder* cancel_holder2_ = [ JFFSimpleBlockHolder simpleBlockHolder ];

      __block BOOL caneled_ = NO;

      cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
      JFFCancelHandler cancel_callback1_ = [ [ ^( void )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder2_ performBlockOnce ];
            if ( cancel_callback_ )
               cancel_callback_();
         }
      } copy ] autorelease ];

      JFFCancelHandler cancel_callback2_ = [ [ ^( void )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder1_ performBlockOnce ];
            if ( cancel_callback_ )
               cancel_callback_();
         }
      } copy ] autorelease ];

      JFFCancelAsyncOpration cancel1_ = first_loader_( progress_callback_, cancel_callback1_, result_block_ );
      JFFCancelAsyncOpration cancel2_ = second_loader_( progress_callback_, cancel_callback2_, result_block_ );

      cancel_holder1_.simpleBlock = cancel1_;
      cancel_holder2_.simpleBlock = cancel2_;

      return [ [ ^()
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder1_ performBlockOnce ];
            [ cancel_holder2_ performBlockOnce ];
            if ( cancel_callback_ )
               cancel_callback_();
         }
      } copy ] autorelease ];
   } copy ] autorelease ];
}

JFFAsyncOperation groupOfAsyncOperations( JFFAsyncOperation first_loader_, JFFAsyncOperation second_loader_, ... )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   JFFAsyncOperation first_block_ = first_loader_;

   va_list args;
   va_start( args, second_loader_ );
   for ( JFFAsyncOperation second_block_ = second_loader_; second_block_ != nil; second_block_ = va_arg( args, JFFAsyncOperation ) )
   {
      first_block_ = groupOfAsyncOperationsPair( first_block_, second_block_ );
   }
   va_end( args );

   return first_block_;
}

JFFAsyncOperation groupOfAsyncOperationsArray( NSArray* blocks_ )
{
   return MergeLoaders( groupOfAsyncOperationsPair, blocks_ );
}

static JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsPair( JFFAsyncOperation first_loader_
                                                                    , JFFAsyncOperation second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ [ first_loader_ copy ] autorelease ];
   second_loader_ = [ [ second_loader_ copy ] autorelease ];

   if ( second_loader_ == nil )
      return first_loader_;

   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL loaded_ = NO;
      __block NSError* block_error_ = nil;
      __block BOOL done_ = NO;

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      JFFDidFinishAsyncOperationHandler result_block_ = ^( id result_, NSError* error_ )
      {
         error_ = error_ ? error_ : block_error_;
         if ( ( loaded_ || error_ ) && !done_ )
         {
            done_ = YES;
            done_callback_( error_ ? nil : [ NSNull null ], error_ );
            return;
         }
         loaded_ = YES;
         block_error_ = error_;
      };

      JFFSimpleBlockHolder* cancel_holder1_ = [ JFFSimpleBlockHolder simpleBlockHolder ];
      JFFSimpleBlockHolder* cancel_holder2_ = [ JFFSimpleBlockHolder simpleBlockHolder ];

      __block BOOL caneled_ = NO;

      cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
      JFFCancelHandler cancel_callback1_ = [ [ ^( void )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder2_ performBlockOnce ];
            if ( cancel_callback_ )
               cancel_callback_();
         }
      } copy ] autorelease ];

      JFFCancelHandler cancel_callback2_ = [ [ ^( void )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder1_ performBlockOnce ];
            if ( cancel_callback_ )
               cancel_callback_();
         }
      } copy ] autorelease ];

      JFFCancelAsyncOpration cancel1_ = first_loader_( progress_callback_, cancel_callback1_, result_block_ );

      JFFCancelAsyncOpration cancel2_ = block_error_ != nil
         ? (JFFCancelAsyncOpration)[ [ ^() { /*do nothing*/ } copy ] autorelease ]
         : second_loader_( progress_callback_, cancel_callback2_, result_block_ );

      cancel_holder1_.simpleBlock = cancel1_;
      cancel_holder2_.simpleBlock = cancel2_;

      return [ [ ^()
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder1_ performBlockOnce ];
            [ cancel_holder2_ performBlockOnce ];
            if ( cancel_callback_ )
               cancel_callback_();
         }
      } copy ] autorelease ];
   } copy ] autorelease ];
}

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperations( JFFAsyncOperation first_loader_
                                                         , JFFAsyncOperation second_loader_
                                                         , ... )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   JFFAsyncOperation first_block_ = first_loader_;

   va_list args;
   va_start( args, second_loader_ );
   for ( JFFAsyncOperation second_block_ = second_loader_; second_block_ != nil; second_block_ = va_arg( args, JFFAsyncOperation ) )
   {
      first_block_ = failOnFirstErrorGroupOfAsyncOperationsPair( first_block_, second_block_ );
   }
   va_end( args );

   return first_block_;
}

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsArray( NSArray* blocks_ )
{
   return MergeLoaders( failOnFirstErrorGroupOfAsyncOperationsPair, blocks_ );
}

JFFAsyncOperation loaderBlockWithDoneCallbackBlock( JFFAsyncOperation loader_
                                                   , JFFDidFinishAsyncOperationHandler done_callback_block_ )
{
   done_callback_block_ = [ [ done_callback_block_ copy ] autorelease ];
   loader_ = [ [ loader_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      return loader_( progress_callback_, cancel_callback_, ^( id result_, NSError* error_ )
      {
         done_callback_block_( result_, error_ );
         if ( done_callback_ )
            done_callback_( result_, error_ );
      } );
   } copy ] autorelease ];
}

JFFAsyncOperation loaderBlockWithDoneHookBlock( JFFAsyncOperation loader_
                                               , JFFDidFinishAsyncOperationHook done_callback_hook_ )
{
   done_callback_hook_ = [ [ done_callback_hook_ copy ] autorelease ];
   loader_ = [ [ loader_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      return loader_( progress_callback_, cancel_callback_, ^( id result_, NSError* error_ )
      {
         done_callback_hook_( result_, error_, done_callback_ );
      } );
   } copy ] autorelease ];
}
