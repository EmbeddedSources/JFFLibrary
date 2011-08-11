#import "JFFAsyncOperationContinuity.h"

#import "JFFResultContext.h"
#import "JFFCancelAyncOperationBlockHolder.h"

#import <Foundation/Foundation.h>

typedef JFFAsyncOperation (*MergeTwoLoadersPtr)( JFFAsyncOperation, JFFAsyncOperation );

static JFFAsyncOperation createEmptyLoaderBlock()
{
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_( [ NSNull null ], nil );
      return JFFEmptyCancelAsyncOperationBlock;
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
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFCancelAyncOperationBlockHolder* block_holder_ = [ JFFCancelAyncOperationBlockHolder cancelAyncOperationBlockHolder ];

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      JFFCancelAsyncOperation first_cancel_ = first_loader_( progress_callback_
                                                           , cancel_callback_
                                                           , ^( id result_, NSError* error_ )
      {
         if ( error_ )
         {
            done_callback_( nil, error_ );
         }
         else
         {
            block_holder_.cancelBlock = second_loader_( progress_callback_
                                                       , cancel_callback_
                                                       , done_callback_ );
         }
      } );
      if ( !block_holder_.cancelBlock )
         block_holder_.cancelBlock = first_cancel_;

      return [ [ ^( BOOL cancel_ )
      {
         [ block_holder_ performCancelBlockOnceWithArgument: cancel_ ];
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
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFCancelAyncOperationBlockHolder* block_holder_ = [ JFFCancelAyncOperationBlockHolder cancelAyncOperationBlockHolder ];

      done_callback_ = [ [ done_callback_ copy ] autorelease ];

      JFFCancelAsyncOperation first_cancel_ = first_loader_( progress_callback_, cancel_callback_, ^( id result_, NSError* error_ )
      {
         if ( error_ )
         {
            block_holder_.cancelBlock = second_loader_( progress_callback_, cancel_callback_, done_callback_ );
         }
         else
         {
            done_callback_( result_, nil );
         }
      } );
      if ( !block_holder_.cancelBlock )
         block_holder_.cancelBlock = first_cancel_;

      return [ [ ^( BOOL cancel_ )
      {
         [ block_holder_ performCancelBlockOnceWithArgument: cancel_ ];
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
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL loaded_ = NO;
      JFFResultContext* error_holder_ = [ JFFResultContext resultContext ];

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      JFFDidFinishAsyncOperationHandler result_block_ = ^( id result_, NSError* error_ )
      {
         if ( loaded_ )
         {
            error_ = error_ ? error_ : error_holder_.error;
            if ( done_callback_ )
               done_callback_( error_ ? nil : [ NSNull null ], error_ );
            return;
         }
         loaded_ = YES;
         error_holder_.error = error_;
      };

      JFFCancelAyncOperationBlockHolder* cancel_holder1_ = [ JFFCancelAyncOperationBlockHolder cancelAyncOperationBlockHolder ];
      JFFCancelAyncOperationBlockHolder* cancel_holder2_ = [ JFFCancelAyncOperationBlockHolder cancelAyncOperationBlockHolder ];

      __block BOOL caneled_ = NO;

      cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
      JFFCancelAsyncOperationHandler cancel_callback1_ = [ [ ^( BOOL canceled_ )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder2_ performCancelBlockOnceWithArgument: canceled_ ];
            if ( cancel_callback_ )
               cancel_callback_( canceled_ );
         }
      } copy ] autorelease ];

      JFFCancelAsyncOperationHandler cancel_callback2_ = [ [ ^( BOOL canceled_ )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder1_ performCancelBlockOnceWithArgument: canceled_ ];
            if ( cancel_callback_ )
               cancel_callback_( canceled_ );
         }
      } copy ] autorelease ];
       
      cancel_holder1_.cancelBlock = first_loader_( progress_callback_, cancel_callback1_, result_block_ );
      cancel_holder2_.cancelBlock = second_loader_( progress_callback_, cancel_callback2_, result_block_ );
       
      return [ [ ^( BOOL cancel_ )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder1_ performCancelBlockOnceWithArgument: cancel_ ];
            [ cancel_holder2_ performCancelBlockOnceWithArgument: cancel_ ];
            if ( cancel_callback_ )
               cancel_callback_( cancel_ );
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
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL loaded_ = NO;
      JFFResultContext* error_holder_ = [ JFFResultContext resultContext ];
      __block BOOL done_ = NO;

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      JFFDidFinishAsyncOperationHandler result_block_ = ^( id result_, NSError* error_ )
      {
         error_ = error_ ? error_ : error_holder_.error;
         if ( ( loaded_ || error_ ) && !done_ )
         {
            done_ = YES;
            if ( done_callback_ )
               done_callback_( error_ ? nil : [ NSNull null ], error_ );
            return;
         }
         loaded_ = YES;
         error_holder_.error = error_;
      };

      JFFCancelAyncOperationBlockHolder* cancel_holder1_ = [ JFFCancelAyncOperationBlockHolder cancelAyncOperationBlockHolder ];
      JFFCancelAyncOperationBlockHolder* cancel_holder2_ = [ JFFCancelAyncOperationBlockHolder cancelAyncOperationBlockHolder ];

      __block BOOL caneled_ = NO;

      cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
      JFFCancelAsyncOperationHandler cancel_callback1_ = [ [ ^( BOOL canceled_ )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder2_ performCancelBlockOnceWithArgument: canceled_ ];
            if ( cancel_callback_ )
               cancel_callback_( canceled_ );
         }
      } copy ] autorelease ];
       
      JFFCancelAsyncOperationHandler cancel_callback2_ = [ [ ^( BOOL canceled_ )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder1_ performCancelBlockOnceWithArgument: canceled_ ];
            if ( cancel_callback_ )
               cancel_callback_( canceled_ );
         }
      } copy ] autorelease ];

      JFFCancelAsyncOperation cancel1_ = first_loader_( progress_callback_, cancel_callback1_, result_block_ );

      JFFCancelAsyncOperation cancel2_ = error_holder_.error != nil
         ? JFFEmptyCancelAsyncOperationBlock
         : second_loader_( progress_callback_, cancel_callback2_, result_block_ );

      cancel_holder1_.cancelBlock = cancel1_;
      cancel_holder2_.cancelBlock = cancel2_;

      return [ [ ^( BOOL cancel_ )
      {
         if ( !caneled_ )
         {
            caneled_ = YES;
            [ cancel_holder1_ performCancelBlockOnceWithArgument: cancel_ ];
            [ cancel_holder2_ performCancelBlockOnceWithArgument: cancel_ ];
            if ( cancel_callback_ )
               cancel_callback_( cancel_ );
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

JFFAsyncOperation asyncOperationWithFinishCallbackBlock( JFFAsyncOperation loader_
                                                        , JFFDidFinishAsyncOperationHandler finish_callback_block_ )
{
   finish_callback_block_ = [ [ finish_callback_block_ copy ] autorelease ];
   loader_ = [ [ loader_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      return loader_( progress_callback_, cancel_callback_, ^( id result_, NSError* error_ )
      {
         finish_callback_block_( result_, error_ );
         if ( done_callback_ )
            done_callback_( result_, error_ );
      } );
   } copy ] autorelease ];
}

JFFAsyncOperation asyncOperationWithFinishHookBlock( JFFAsyncOperation loader_
                                                    , JFFDidFinishAsyncOperationHook finish_callback_hook_ )
{
   finish_callback_hook_ = [ [ finish_callback_hook_ copy ] autorelease ];
   loader_ = [ [ loader_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      return loader_( progress_callback_, cancel_callback_, ^( id result_, NSError* error_ )
      {
         finish_callback_hook_( result_, error_, done_callback_ );
      } );
   } copy ] autorelease ];
}

JFFAsyncOperation asyncOperationWithDoneBlock( JFFAsyncOperation loader_
                                              , JFFSimpleBlock done_callback_hook_ )
{
   loader_ = [ [ loader_ copy ] autorelease ];
   if ( nil == done_callback_hook_ )
      return loader_;

   done_callback_hook_ = [ [ done_callback_hook_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
      cancel_callback_ = [ [ ^( BOOL canceled_ )
      {
         done_callback_hook_();

         if ( cancel_callback_ )
            cancel_callback_( canceled_ );
      } copy ] autorelease ];

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      done_callback_ = ^( id result_, NSError* error_ )
      {
         done_callback_hook_();

         if ( done_callback_ )
            done_callback_( result_, error_ );
      };
      return loader_( progress_callback_, cancel_callback_, done_callback_ );
   } copy ] autorelease ];
}
