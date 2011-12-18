#import "JFFAsyncOperationContinuity.h"

#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

#import <JFFScheduler/JFFScheduler.h>

#import <Foundation/Foundation.h>

#include <assert.h>

typedef JFFAsyncOperation (*MergeTwoLoadersPtr)( JFFAsyncOperation, JFFAsyncOperation );

static JFFAsyncOperation createEmptyLoaderBlock()
{
   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_( [ NSNull null ], nil );
      return JFFEmptyCancelAsyncOperationBlock;
   };
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

   first_loader_ = [ first_loader_ copy ];
   second_loader_ = [ second_loader_ copy ];

   if ( second_loader_ == nil )
      return first_loader_;

   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFCancelAyncOperationBlockHolder* block_holder_ = [ JFFCancelAyncOperationBlockHolder new ];

      done_callback_ = [ done_callback_ copy ];
      JFFCancelAsyncOperation first_cancel_ = first_loader_( progress_callback_
                                                           , cancel_callback_
                                                           , ^void( id result_, NSError* error_ )
      {
         if ( error_ )
         {
            if ( done_callback_ )
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

      return block_holder_.onceCancelBlock;
   };
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

JFFAsyncOperation sequenceOfAsyncOperationsArray( NSArray* loaders_ )
{
   return MergeLoaders( sequenceOfAsyncOperationsPair, loaders_ );
}

static JFFAsyncOperation trySequenceOfAsyncOperationsPair( JFFAsyncOperation first_loader_, JFFAsyncOperation second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_  = [ first_loader_ copy ];
   second_loader_ = [ second_loader_ copy ];

   if ( second_loader_ == nil )
      return first_loader_;

   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFCancelAyncOperationBlockHolder* block_holder_ = [ JFFCancelAyncOperationBlockHolder new ];

      done_callback_ = [ done_callback_ copy ];

      JFFCancelAsyncOperation first_cancel_ = first_loader_( progress_callback_, cancel_callback_, ^void( id result_, NSError* error_ )
      {
         if ( error_ )
         {
            block_holder_.cancelBlock = second_loader_( progress_callback_, cancel_callback_, done_callback_ );
         }
         else
         {
            if ( done_callback_ )
               done_callback_( result_, nil );
         }
      } );
      if ( !block_holder_.cancelBlock )
         block_holder_.cancelBlock = first_cancel_;

      return block_holder_.onceCancelBlock;
   };
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

JFFAsyncOperation trySequenceOfAsyncOperationsArray( NSArray* loaders_ )
{
   return MergeLoaders( trySequenceOfAsyncOperationsPair, loaders_ );
}

static JFFAsyncOperation groupOfAsyncOperationsPair( JFFAsyncOperation first_loader_, JFFAsyncOperation second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ first_loader_ copy ];
   second_loader_ = [ second_loader_ copy ];

   if ( second_loader_ == nil )
      return first_loader_;

   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL loaded_ = NO;
      __block NSError* error_holder_;

      done_callback_ = [ done_callback_ copy ];
      JFFDidFinishAsyncOperationHandler result_block_ = ^void( id result_, NSError* error_ )
      {
         if ( loaded_ )
         {
            error_ = error_ ? error_ : error_holder_;
            if ( done_callback_ )
               done_callback_( error_ ? nil : [ NSNull null ], error_ );
            return;
         }
         loaded_ = YES;
         error_holder_ = error_;
      };

      __block BOOL block_canceled_ = NO;

      cancel_callback_ = [ cancel_callback_ copy ];
      JFFCancelAsyncOperationHandler (^makeCancelHandler_)( JFFCancelAyncOperationBlockHolder* ) =
         ^( JFFCancelAyncOperationBlockHolder* cancel_holder_ )
      {
         return ^void( BOOL canceled_ )
         {
            if ( !block_canceled_ )
            {
               block_canceled_ = YES;
               cancel_holder_.onceCancelBlock( canceled_ );
               if ( cancel_callback_ )
                  cancel_callback_( canceled_ );
            }
         };
      };

      result_block_ = [ result_block_ copy ];

      JFFDidFinishAsyncOperationHandler (^makeFinishHandler_)( JFFCancelAyncOperationBlockHolder* ) =
         ^( JFFCancelAyncOperationBlockHolder* cancel_holder_ )
      {
         return ^void( id result_, NSError* error_ )
         {
            cancel_holder_.cancelBlock = nil;
            result_block_( result_, error_ );
         };
      };

      JFFCancelAyncOperationBlockHolder* cancel_holder1_ = [ JFFCancelAyncOperationBlockHolder new ];
      JFFCancelAyncOperationBlockHolder* cancel_holder2_ = [ JFFCancelAyncOperationBlockHolder new ];

      cancel_holder1_.cancelBlock = first_loader_( progress_callback_
                                                  , makeCancelHandler_( cancel_holder2_ )
                                                  , makeFinishHandler_( cancel_holder1_ ) );
      cancel_holder2_.cancelBlock = second_loader_( progress_callback_
                                                   , makeCancelHandler_( cancel_holder1_ )
                                                   , makeFinishHandler_( cancel_holder2_ ) );

      return ^void( BOOL cancel_ )
      {
         if ( !block_canceled_ )
         {
            block_canceled_ = YES;
            cancel_holder1_.onceCancelBlock( cancel_ );
            cancel_holder2_.onceCancelBlock( cancel_ );
            if ( cancel_callback_ )
               cancel_callback_( cancel_ );
         }
      };
   };
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

static JFFDidFinishAsyncOperationHandler cancelSafeResultBlock( JFFDidFinishAsyncOperationHandler result_block_
                                                               , JFFCancelAyncOperationBlockHolder* cancel_holder_ )
{
   result_block_ = [ result_block_ copy ];
   return ^void( id result_, NSError* error_ )
   {
      cancel_holder_.cancelBlock = nil;
      result_block_( result_, error_ );
   };
}

static JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsPair( JFFAsyncOperation first_loader_
                                                                    , JFFAsyncOperation second_loader_ )
{
   if ( first_loader_ == nil )
      return createEmptyLoaderBlock();

   first_loader_ = [ first_loader_ copy ];
   second_loader_ = [ second_loader_ copy ];

   if ( second_loader_ == nil )
      return first_loader_;

   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL loaded_ = NO;
      __block BOOL done_ = NO;

      JFFCancelAyncOperationBlockHolder* cancel_holder1_ = [ JFFCancelAyncOperationBlockHolder new ];
      JFFCancelAyncOperationBlockHolder* cancel_holder2_ = [ JFFCancelAyncOperationBlockHolder new ];

      done_callback_ = [ done_callback_ copy ];
      JFFDidFinishAsyncOperationHandler result_block_ = ^void( id result_, NSError* error_ )
      {
         BOOL first_error_ = error_ && !done_;
         if ( loaded_ || first_error_ )
         {
            if ( first_error_ )
            {
               cancel_holder1_.onceCancelBlock( YES );
               cancel_holder2_.onceCancelBlock( YES );
            }

            done_ = YES;
            if ( done_callback_ )
               done_callback_( error_ ? nil : [ NSNull null ], error_ );
            return;
         }
         loaded_ = YES;
      };

      __block BOOL block_canceled_ = NO;

      cancel_callback_ = [ cancel_callback_ copy ];
      JFFCancelAsyncOperationHandler (^makeCancelCallback_)( JFFCancelAyncOperationBlockHolder* ) =
      ^( JFFCancelAyncOperationBlockHolder* cancel_holder_ )
      {
         return ^void( BOOL canceled_ )
         {
            if ( !block_canceled_ )
            {
               block_canceled_ = YES;
               cancel_holder_.onceCancelBlock( canceled_ );
               if ( cancel_callback_ )
                  cancel_callback_( canceled_ );
            }
         };
      };

      JFFCancelAsyncOperation cancel1_ = first_loader_( progress_callback_
                                                       , makeCancelCallback_( cancel_holder2_ )
                                                       , cancelSafeResultBlock( result_block_, cancel_holder1_ ) );

      cancel_holder1_.cancelBlock = done_ ? JFFEmptyCancelAsyncOperationBlock : cancel1_;

      JFFCancelAsyncOperation cancel2_ = done_
         ? JFFEmptyCancelAsyncOperationBlock
         : second_loader_( progress_callback_
                          , makeCancelCallback_( cancel_holder1_ )
                          , cancelSafeResultBlock( result_block_, cancel_holder2_ ) );

      cancel_holder2_.cancelBlock = done_ ? JFFEmptyCancelAsyncOperationBlock : cancel2_;

      return ^void( BOOL cancel_ )
      {
         if ( !block_canceled_ )
         {
            block_canceled_ = YES;
            cancel_holder1_.onceCancelBlock( cancel_ );
            cancel_holder2_.onceCancelBlock( cancel_ );
            if ( cancel_callback_ )
               cancel_callback_( cancel_ );
         }
      };
   };
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
   finish_callback_block_ = [ finish_callback_block_ copy ];
   loader_ = [ loader_ copy ];
   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_ = [ done_callback_ copy ];
      return loader_( progress_callback_, cancel_callback_, ^void( id result_, NSError* error_ )
      {
         if ( finish_callback_block_ )
            finish_callback_block_( result_, error_ );
         if ( done_callback_ )
            done_callback_( result_, error_ );
      } );
   };
}

JFFAsyncOperation asyncOperationWithFinishHookBlock( JFFAsyncOperation loader_
                                                    , JFFDidFinishAsyncOperationHook finish_callback_hook_ )
{
   assert( finish_callback_hook_ );// should not be nil"
   finish_callback_hook_ = [ finish_callback_hook_ copy ];
   loader_ = [ loader_ copy ];
   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_ = [ done_callback_ copy ];
      return loader_( progress_callback_, cancel_callback_, ^void( id result_, NSError* error_ )
      {
         finish_callback_hook_( result_, error_, done_callback_ );
      } );
   };
}

JFFAsyncOperation asyncOperationWithDoneBlock( JFFAsyncOperation loader_
                                              , JFFSimpleBlock done_callback_hook_ )
{
   loader_ = [ loader_ copy ];
   if ( nil == done_callback_hook_ )
      return loader_;

   done_callback_hook_ = [ done_callback_hook_ copy ];
   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      cancel_callback_ = [ cancel_callback_ copy ];
      JFFCancelAsyncOperationHandler wrap_cancel_callback_ = ^void( BOOL canceled_ )
      {
         done_callback_hook_();

         if ( cancel_callback_ )
            cancel_callback_( canceled_ );
      };

      done_callback_ = [ done_callback_ copy ];
      JFFDidFinishAsyncOperationHandler wrap_done_callback_ = ^void( id result_, NSError* error_ )
      {
         done_callback_hook_();

         if ( done_callback_ )
            done_callback_( result_, error_ );
      };
      return loader_( progress_callback_, wrap_cancel_callback_, wrap_done_callback_ );
   };
}

JFFAsyncOperation asyncOperationWithResult( id result_ )
{
   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      if ( done_callback_ )
         done_callback_( result_, nil );
      return JFFEmptyCancelAsyncOperationBlock;
   };
}

JFFAsyncOperation repeatAsyncOperation( JFFAsyncOperation native_loader_
                                       , PredicateBlock predicate_
                                       , NSTimeInterval delay_
                                       , NSInteger max_repeat_count_ )
{
   assert( native_loader_ );// can not be nil
   assert( predicate_     );// can not be nil

   native_loader_ = [ native_loader_ copy ];
   predicate_     = [ predicate_     copy ];

   return ^( JFFAsyncOperationProgressHandler progress_callback_
            , JFFCancelAsyncOperationHandler cancel_callback_
            , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      progress_callback_ = [ progress_callback_ copy ];
      cancel_callback_   = [ cancel_callback_   copy ];
      done_callback_     = [ done_callback_     copy ];

      JFFCancelAyncOperationBlockHolder* holder_ = [ JFFCancelAyncOperationBlockHolder new ];

      __block JFFDidFinishAsyncOperationHook finishHookHolder_ = nil;

      __block NSInteger currentLeftCount = max_repeat_count_;

      JFFDidFinishAsyncOperationHook finish_callback_hook_ = ^( id result_
                                                               , NSError* error_
                                                               , JFFDidFinishAsyncOperationHandler done_callback_ )
      {
         JFFResultContext* context_ = [ JFFResultContext new ];
         context_.result = result_;
         context_.error  = error_ ;
         if ( !predicate_( context_ ) || currentLeftCount == 0 )
         {
            finishHookHolder_ = nil;
            if ( done_callback_ )
               done_callback_( result_, error_ );
         }
         else
         {
            currentLeftCount = currentLeftCount > 0
               ? currentLeftCount - 1
               : currentLeftCount;

            JFFAsyncOperation loader_ = asyncOperationWithFinishHookBlock( native_loader_
                                                                          , finishHookHolder_ );
            loader_ = asyncOperationAfterDelay( delay_, loader_ );

            holder_.cancelBlock = loader_( progress_callback_, cancel_callback_, done_callback_ );
         }
      };

      finishHookHolder_ = [ finish_callback_hook_ copy ];

      JFFAsyncOperation loader_ = asyncOperationWithFinishHookBlock( native_loader_
                                                                    , finishHookHolder_ );

      holder_.cancelBlock = loader_( progress_callback_, cancel_callback_, done_callback_ );

      return ^( BOOL canceled_ )
      {
         finishHookHolder_ = nil;
         holder_.onceCancelBlock( canceled_ );
      };
   };
}

JFFAsyncOperation asyncOperationAfterDelay( NSTimeInterval delay_
                                           , JFFAsyncOperation loader_ )
{
   loader_ = [ loader_ copy ];
   return ^( JFFAsyncOperationProgressHandler progress_callback_
            , JFFCancelAsyncOperationHandler cancel_callback_
            , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block JFFAsyncOperationProgressHandler  progressHolder_ = [ progress_callback_ copy ];
      __block JFFCancelAsyncOperationHandler    cancelHolder_   = [ cancel_callback_   copy ];
      __block JFFDidFinishAsyncOperationHandler doneHolder_     = [ done_callback_     copy ];

      JFFCancelAyncOperationBlockHolder* lc_holder_ = [ JFFCancelAyncOperationBlockHolder new ];

      __block JFFScheduler* scheduler_ = [ JFFScheduler new ];

      JFFCancelScheduledBlock sch_cancel_ = [ scheduler_ addBlock: ^( JFFCancelScheduledBlock sch_cancel_ )
      {
         #pragma GCC diagnostic push
         #pragma GCC diagnostic ignored "-Warc-retain-cycles"
         scheduler_ = nil;
         #pragma GCC diagnostic pop
         sch_cancel_();

         lc_holder_.cancelBlock = loader_( progressHolder_, cancelHolder_, doneHolder_ );
      } duration: delay_ ];

      lc_holder_.cancelBlock = ^( BOOL canceled_ )
      {
         if ( canceled_ )
         {
            scheduler_ = nil;
            sch_cancel_();
         }
         else
         {
             progressHolder_ = nil;
             cancelHolder_   = nil;
             doneHolder_     = nil;
         }
         if ( cancel_callback_ )
            cancel_callback_( canceled_ );
      };

      return lc_holder_.onceCancelBlock;
   };
}
