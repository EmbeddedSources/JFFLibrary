#import "JFFAsyncOperationLoadBalancer.h"

#import "JFFContextLoaders.h"
#import "JFFAsyncOperationLoadBalancerCotexts.h"
#import "JFFAsyncOperationProgressBlockHolder.h"

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

static NSUInteger global_active_number_ = 0;

static JFFAsyncOperationLoadBalancerCotexts* sharedBalancer()
{
   return [ JFFAsyncOperationLoadBalancerCotexts sharedBalancer ];
}

static void setBalancerCurrentContextName( NSString* context_name_ )
{
   sharedBalancer().currentContextName = context_name_;
}

void setBalancerActiveContextName( NSString* context_name_ )
{
   sharedBalancer().activeContextName = context_name_;
   setBalancerCurrentContextName( context_name_ );
}

static void peformBlockWithinContext( JFFSimpleBlock block_, JFFContextLoaders* context_loaders_ )
{
   NSString* current_context_name_ = sharedBalancer().currentContextName;
   sharedBalancer().currentContextName = context_loaders_.name;

   block_();

   sharedBalancer().currentContextName = current_context_name_;
}

static void findAndPerformNextNativeLoader()
{
   JFFContextLoaders* active_loaders_ = [ sharedBalancer() activeContextLoaders ];
   //TODO check condition yet
   if ( active_loaders_.activeLoadersNumber < 5 || global_active_number_ == 0 )
   {
      JFFAsyncOperation loader_ = nil;

      if ( [ active_loaders_.pendingLoaders count ] > 0 )
      {
         loader_ = [ [ [ active_loaders_.pendingLoaders objectAtIndex: 0 ] copy ] autorelease ];
         [ loader_ removeObjectAtIndex: 0 ];
      }

      if ( !loader_ )
      {
         //TODO get any loader
      }

      //TODO perform loader
   }
}

static void finishExecuteOfNativeLoader( JFFAsyncOperation native_loader_
                                        , JFFContextLoaders* context_loaders_ )
{
   if ( [ context_loaders_ removeNativeLoader: native_loader_ ] )
   {
      --global_active_number_;
   }
}

static JFFCancelAsyncOperationHandler cancelCallbackWrapper( JFFCancelAsyncOperationHandler native_cancel_callback_
                                                            , JFFAsyncOperation native_loader_
                                                            , JFFContextLoaders* context_loaders_ )
{
   native_cancel_callback_ = [ [ native_cancel_callback_ copy ] autorelease ];
   return [ [ ^( BOOL canceled_ )
   {
      if ( !canceled_ )
      {
         assert( NO );// @"balanced loaders should not be unsubscribed from native loader"
      }

      finishExecuteOfNativeLoader( native_loader_, context_loaders_ );

      if ( native_cancel_callback_ )
      {
         peformBlockWithinContext( ^
         {
            native_cancel_callback_( canceled_ );
         }, context_loaders_ );
      }

      findAndPerformNextNativeLoader();
   } copy ] autorelease ];
}

static JFFDidFinishAsyncOperationHandler doneCallbackWrapper( JFFDidFinishAsyncOperationHandler native_done_callback_
                                                             , JFFAsyncOperation native_loader_
                                                             , JFFContextLoaders* context_loaders_ )
{
   native_done_callback_ = [ [ native_done_callback_ copy ] autorelease ];
   return [ [ ^( id result_, NSError* error_ )
   {
      finishExecuteOfNativeLoader( native_loader_, context_loaders_ );

      if ( native_done_callback_ )
      {
         peformBlockWithinContext( ^
         {
            native_done_callback_( result_, error_ );
         }, context_loaders_ );
      }

      findAndPerformNextNativeLoader();
   } copy ] autorelease ];
}

static JFFAsyncOperation balancedAsyncOperationWithContext( JFFAsyncOperation native_loader_
                                                           , JFFContextLoaders* context_loaders_ )
{
   native_loader_ = [ [ native_loader_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler native_cancel_callback_
                , JFFDidFinishAsyncOperationHandler native_done_callback_ )
   {
      JFFAsyncOperationProgressBlockHolder* progress_block_holder_ = [ JFFAsyncOperationProgressBlockHolder asyncOperationProgressBlockHolder ];
      progress_block_holder_.progressBlock = progress_callback_;

      JFFAsyncOperationProgressHandler wrapped_progress_callback_ = ^( id progress_info_ )
      {
         peformBlockWithinContext( ^
         {
            [ progress_block_holder_ performProgressBlockWithArgument: progress_info_ ];
         }, context_loaders_ );
      };

      __block BOOL done_ = NO;

      JFFCancelAsyncOperationHandler wrapped_cancel_callback_ = cancelCallbackWrapper( native_cancel_callback_
                                                                                      , native_loader_
                                                                                      , context_loaders_ );
      wrapped_cancel_callback_ = ^( BOOL canceled_ )
      {
         done_ = YES;
         wrapped_cancel_callback_( canceled_ );
      };

      JFFDidFinishAsyncOperationHandler wrapped_done_callback_ = doneCallbackWrapper( native_done_callback_
                                                                                     , native_loader_
                                                                                     , context_loaders_ );
      wrapped_done_callback_ = ^( id result_, NSError* error_ )
      {
         done_ = YES;
         wrapped_done_callback_( result_, error_ );
      };

      //TODO check native loader no within balancer !!!
      JFFCancelAsyncOperation cancel_block_ = native_loader_( wrapped_progress_callback_
                                                             , wrapped_cancel_callback_
                                                             , wrapped_done_callback_ );

      if ( !done_ )
      {
         ++global_active_number_;

         JFFCancelAsyncOperation wrapped_cancel_block_ = [ [ ^( BOOL canceled_ )
         {
            if ( canceled_ )
            {
               cancel_block_( YES );
            }
            else
            {
               native_cancel_callback_( NO );

               //TODO unsubscribe here cancel and done
               progress_block_holder_.progressBlock = nil;
            }
         } copy ] autorelease ];

         [ context_loaders_ addActiveNativeLoader: native_loader_
                                    wrappedCancel: wrapped_cancel_block_ ];

         return wrapped_cancel_block_;
      }

      cancel_block_ = [ [ ^( BOOL canceled_ ) { /* do nothing */ } copy ] autorelease ];
      return cancel_block_;
   } copy ] autorelease ];
}

JFFAsyncOperation balancedAsyncOperation( JFFAsyncOperation native_loader_ )
{
   native_loader_ = [ [ native_loader_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFContextLoaders* context_loaders_ = [ sharedBalancer() currentContextLoaders ];

      JFFAsyncOperationProgressBlockHolder* progress_block_holder_ = [ JFFAsyncOperationProgressBlockHolder asyncOperationProgressBlockHolder ];
      progress_block_holder_.progressBlock = progress_callback_;
      progress_callback_ = ^( id progress_info_ )
      {
         [ progress_block_holder_ performProgressBlockWithArgument: progress_info_ ];
      };

      //TODO check condition yet
      if ( ( [ sharedBalancer().activeContextName isEqualToString: context_loaders_.name ]
            && context_loaders_.activeLoadersNumber < 5 )
          || global_active_number_ == 0 )
      {
         JFFAsyncOperation context_loader_ = balancedAsyncOperationWithContext( native_loader_, context_loaders_ );
         return context_loader_( progress_callback_, cancel_callback_, done_callback_ );
      }

      [ context_loaders_.pendingLoaders addObject: native_loader_ ];

      JFFCancelAsyncOperation cancel_ = [ [ ^( BOOL canceled_ )
      {
         if ( ![ context_loaders_.pendingLoaders containsObject: native_loader_ ] )
         {
            //executing or already executed
            if ( canceled_ )
            {
               //cancel only wrapped cancel block
               [ context_loaders_ cancelNativeLoader: native_loader_ cancel: canceled_ ];
            }
            return;
         }

         if ( canceled_ )
         {
            [ context_loaders_.pendingLoaders removeObject: native_loader_ ];
            cancel_callback_( YES );
         }
         else
         {
            cancel_callback_( NO );

            //TODO unsubscribe here cancel and done
            progress_block_holder_.progressBlock = nil;
         }
      } copy ] autorelease ];

      return cancel_;
   } copy ] autorelease ];
}
