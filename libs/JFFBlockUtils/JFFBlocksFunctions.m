#import "JFFBlocksFunctions.h"

#import "JFFSimpleBlockHolder.h"

#import <Foundation/Foundation.h>

typedef JFFAsyncDataLoader (*MergeTwoLoadersPtr)( JFFAsyncDataLoader, JFFAsyncDataLoader );

static JFFAsyncDataLoader createEmptyLoaderBlock()
{
   return [ [ ^( JFFSyncOperationProgressHandler progress_callback_, JFFCancelHandler cancel_callback_, JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_( [ NSNull null ], nil );
      return [ [ ^() { /*do nothing*/ } copy ] autorelease ];
   } copy ] autorelease ];
}

static JFFAsyncDataLoader MergeLoaders( MergeTwoLoadersPtr merger_, NSArray* blocks_ )
{
   if ( ![ blocks_ lastObject ] )
      return createEmptyLoaderBlock();

   JFFAsyncDataLoader first_block_ = [ blocks_ objectAtIndex: 0 ];

   for ( JFFAsyncDataLoader second_block_ in blocks_ )
   {
      if ( second_block_ == first_block_ )
         continue;

      first_block_ = merger_( first_block_, second_block_ );
   }

   return first_block_;
}

static JFFAsyncDataLoader loaderBlockWithBlocksSequencePair( JFFAsyncDataLoader first_loader_, JFFAsyncDataLoader second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ [ first_loader_ copy ] autorelease ];
   second_loader_ = [ [ second_loader_ copy ] autorelease ];

   if ( second_loader_ == nil )
      return first_loader_;

   return [ [ ^( JFFSyncOperationProgressHandler progress_callback_
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

JFFAsyncDataLoader loaderBlockWithBlocksSequence( JFFAsyncDataLoader first_loader_, JFFAsyncDataLoader second_loader_, ... )
{
   JFFAsyncDataLoader first_block_ = first_loader_;

   va_list args;
   va_start( args, second_loader_ );
   for ( JFFAsyncDataLoader second_block_ = second_loader_; second_block_ != nil; second_block_ = va_arg( args, JFFAsyncDataLoader ) )
   {
      first_block_ = loaderBlockWithBlocksSequencePair( first_block_, second_block_ );
   }
   va_end( args );

   return first_block_;
}

JFFAsyncDataLoader loaderBlockWithBlocksSequenceArray( NSArray* blocks_ )
{
   return MergeLoaders( loaderBlockWithBlocksSequencePair, blocks_ );
}

static JFFAsyncDataLoader loaderBlockWithBlocksTrySequencePair( JFFAsyncDataLoader first_loader_, JFFAsyncDataLoader second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ [ first_loader_ copy ] autorelease ];
   second_loader_ = [ [ second_loader_ copy ] autorelease ];

   if ( second_loader_ == nil )
      return first_loader_;

   return [ [ ^( JFFSyncOperationProgressHandler progress_callback_
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

JFFAsyncDataLoader loaderBlockWithBlocksTrySequence( JFFAsyncDataLoader first_loader_, JFFAsyncDataLoader second_loader_, ... )
{
   JFFAsyncDataLoader first_block_ = first_loader_;

   va_list args;
   va_start( args, second_loader_ );
   for ( JFFAsyncDataLoader second_block_ = second_loader_; second_block_ != nil; second_block_ = va_arg( args, JFFAsyncDataLoader ) )
   {
      first_block_ = loaderBlockWithBlocksTrySequencePair( first_block_, second_block_ );
   }
   va_end( args );

   return first_block_;
}

static JFFAsyncDataLoader loaderBlockWithBlocksGroupPair( JFFAsyncDataLoader first_loader_, JFFAsyncDataLoader second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ [ first_loader_ copy ] autorelease ];
   second_loader_ = [ [ second_loader_ copy ] autorelease ];

   if ( second_loader_ == nil )
      return first_loader_;

   return [ [ ^( JFFSyncOperationProgressHandler progress_callback_
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

JFFAsyncDataLoader loaderBlockWithBlocksGroup( JFFAsyncDataLoader first_loader_, JFFAsyncDataLoader second_loader_, ... )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   JFFAsyncDataLoader first_block_ = first_loader_;

   va_list args;
   va_start( args, second_loader_ );
   for ( JFFAsyncDataLoader second_block_ = second_loader_; second_block_ != nil; second_block_ = va_arg( args, JFFAsyncDataLoader ) )
   {
      first_block_ = loaderBlockWithBlocksGroupPair( first_block_, second_block_ );
   }
   va_end( args );

   return first_block_;
}

JFFAsyncDataLoader loaderBlockWithBlocksGroupArray( NSArray* blocks_ )
{
   return MergeLoaders( loaderBlockWithBlocksGroupPair, blocks_ );
}

static JFFAsyncDataLoader loaderBlockFailOnFirstErrorWithBlocksGroupPair( JFFAsyncDataLoader first_loader_, JFFAsyncDataLoader second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ [ first_loader_ copy ] autorelease ];
   second_loader_ = [ [ second_loader_ copy ] autorelease ];

   if ( second_loader_ == nil )
      return first_loader_;

   return [ [ ^( JFFSyncOperationProgressHandler progress_callback_
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

JFFAsyncDataLoader loaderBlockFailOnFirstErrorWithBlocksGroup( JFFAsyncDataLoader first_loader_
                                                             , JFFAsyncDataLoader second_loader_
                                                             , ... )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   JFFAsyncDataLoader first_block_ = first_loader_;

   va_list args;
   va_start( args, second_loader_ );
   for ( JFFAsyncDataLoader second_block_ = second_loader_; second_block_ != nil; second_block_ = va_arg( args, JFFAsyncDataLoader ) )
   {
      first_block_ = loaderBlockFailOnFirstErrorWithBlocksGroupPair( first_block_, second_block_ );
   }
   va_end( args );

   return first_block_;
}

JFFAsyncDataLoader loaderBlockFailOnFirstErrorWithBlocksGroupArray( NSArray* blocks_ )
{
   return MergeLoaders( loaderBlockFailOnFirstErrorWithBlocksGroupPair, blocks_ );
}

JFFAsyncDataLoader loaderBlockWithDoneCallbackBlock( JFFAsyncDataLoader loader_
                                                   , JFFDidFinishAsyncOperationHandler done_callback_block_ )
{
   done_callback_block_ = [ [ done_callback_block_ copy ] autorelease ];
   loader_ = [ [ loader_ copy ] autorelease ];
   return [ [ ^( JFFSyncOperationProgressHandler progress_callback_
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

JFFAsyncDataLoader loaderBlockWithDoneHookBlock( JFFAsyncDataLoader loader_
                                               , JFFDidFinishAsyncOperationHook done_callback_hook_ )
{
   done_callback_hook_ = [ [ done_callback_hook_ copy ] autorelease ];
   loader_ = [ [ loader_ copy ] autorelease ];
   return [ [ ^( JFFSyncOperationProgressHandler progress_callback_
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
