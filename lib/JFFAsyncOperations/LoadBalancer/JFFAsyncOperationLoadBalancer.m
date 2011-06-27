#import "JFFAsyncOperationLoadBalancer.h"

#import "JFFContextLoaders.h"
#import "JFFPedingLoaderData.h"
#import "JFFAsyncOperationLoadBalancerCotexts.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

static NSUInteger max_operation_count_ = 5;

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
   NSLog( @"!!!SET ACTIVE CONTEXT NAME: %@", context_name_ );
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

static JFFAsyncOperation balancedAsyncOperationWithContext( JFFAsyncOperation native_loader_
                                                           , JFFContextLoaders* context_loaders_
                                                           , JFFInsertPendingLoaderPositionType pending_position_ );

static void performInBalancerPedingLoaderData( JFFPedingLoaderData* pending_loader_data_
                                              , JFFContextLoaders* context_loaders_ )
{
   JFFAsyncOperation balanced_loader_ = balancedAsyncOperationWithContext( pending_loader_data_.nativeLoader
                                                                          , context_loaders_
                                                                          , JFFInsertPendingLoaderFirst );

   balanced_loader_( pending_loader_data_.progressCallback
                    , pending_loader_data_.cancelCallback
                    , pending_loader_data_.doneCallback );
}

static BOOL performLoaderFromContextIfPossible( JFFContextLoaders* context_loaders_ )
{
   if ( context_loaders_.pendingLoadersNumber > 0 )
   {
      JFFPedingLoaderData* pending_loader_data_ = [ context_loaders_ popPendingLoaderData ];
      performInBalancerPedingLoaderData( pending_loader_data_, context_loaders_ );
      return YES;
   }
   return NO;
}

static void findAndPerformNextNativeLoader()
{
   JFFAsyncOperationLoadBalancerCotexts* balancer_ = sharedBalancer();

   JFFContextLoaders* active_loaders_ = [ balancer_ activeContextLoaders ];
   if ( performLoaderFromContextIfPossible( active_loaders_ ) )
      return;

   for ( NSString* name_ in balancer_.allContextNames )
   {
      JFFContextLoaders* context_loaders_ = [ balancer_.contextLoadersByName objectForKey: name_ ];
      if ( performLoaderFromContextIfPossible( context_loaders_ ) )
         return;
   }
}

static void logBalancerState()
{
   NSLog( @"|||||LOAD BALANCER|||||" );
   JFFAsyncOperationLoadBalancerCotexts* balancer_ = sharedBalancer();
   JFFContextLoaders* active_loaders_ = [ balancer_ activeContextLoaders ];
   NSLog( @"Active context name: %@", active_loaders_.name );
   NSLog( @"pending count: %d", active_loaders_.pendingLoadersNumber );
   NSLog( @"active  count: %d", active_loaders_.activeLoadersNumber );

   for ( NSString* name_ in balancer_.allContextNames )
   {
      JFFContextLoaders* context_loaders_ = [ balancer_.contextLoadersByName objectForKey: name_ ];

      if ( [ name_ isEqualToString: active_loaders_.name ] )
         continue;

      NSLog( @"context name: %@", context_loaders_.name );
      NSLog( @"pending count: %d", context_loaders_.pendingLoadersNumber );
      NSLog( @"active  count: %d", context_loaders_.activeLoadersNumber );
   }
   NSLog( @"|||||END LOG|||||" );
}

static void finishExecuteOfNativeLoader( JFFAsyncOperation native_loader_
                                        , JFFContextLoaders* context_loaders_ )
{
   if ( [ context_loaders_ removeActiveNativeLoader: native_loader_ ] )
   {
      --global_active_number_;
      logBalancerState();
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

      [ native_cancel_callback_ copy ];

      finishExecuteOfNativeLoader( native_loader_, context_loaders_ );

      if ( native_cancel_callback_ )
      {
         peformBlockWithinContext( ^
         {
            native_cancel_callback_( canceled_ );
         }, context_loaders_ );
      }

      [ native_cancel_callback_ release ];

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
      [ native_done_callback_ copy ];

      finishExecuteOfNativeLoader( native_loader_, context_loaders_ );

      if ( native_done_callback_ )
      {
         peformBlockWithinContext( ^
         {
            native_done_callback_( result_, error_ );
         }, context_loaders_ );
      }

      [ native_done_callback_ release ];

      findAndPerformNextNativeLoader();
   } copy ] autorelease ];
}

static JFFAsyncOperation wrappedAsyncOperationWithContext( JFFAsyncOperation native_loader_
                                                          , JFFContextLoaders* context_loaders_ )
{
   native_loader_ = [ [ native_loader_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler native_progress_callback_
                , JFFCancelAsyncOperationHandler native_cancel_callback_
                , JFFDidFinishAsyncOperationHandler native_done_callback_ )
   {
      //progress holder for unsubscribe
      JFFAsyncOperationProgressBlockHolder* progress_block_holder_ = [ JFFAsyncOperationProgressBlockHolder asyncOperationProgressBlockHolder ];
      progress_block_holder_.progressBlock = native_progress_callback_;
      JFFAsyncOperationProgressHandler wrapped_progress_callback_ = ^( id progress_info_ )
      {
         peformBlockWithinContext( ^
         {
            [ progress_block_holder_ performProgressBlockWithArgument: progress_info_ ];
         }, context_loaders_ );
      };

      __block BOOL done_ = NO;

      //cancel holder for unsubscribe
      JFFCancelAyncOperationBlockHolder* cancel_block_holder_ = [ JFFCancelAyncOperationBlockHolder cancelAyncOperationBlockHolder ];
      native_cancel_callback_ = [ [ native_cancel_callback_ copy ] autorelease ];
      cancel_block_holder_.cancelBlock = native_cancel_callback_;
      JFFCancelAsyncOperation wrapped_cancel_callback_ = ^( BOOL canceled_ )
      {
         done_ = YES;
         [ cancel_block_holder_ performCancelBlockOnceWithArgument: canceled_ ];
      };

      //finish holder for unsubscribe
      JFFDidFinishAsyncOperationBlockHolder* finish_block_holder_ = [ JFFDidFinishAsyncOperationBlockHolder didFinishAyncOperationBlockHolder ];
      native_done_callback_ = [ [ native_done_callback_ copy ] autorelease ];
      finish_block_holder_.didFinishBlock = native_done_callback_;
      JFFDidFinishAsyncOperationHandler wrapped_done_callback_ = ^( id result_, NSError* error_ )
      {
         done_ = YES;
         [ finish_block_holder_ performDidFinishBlockOnceWithResult: result_ error: error_ ];
      };

      wrapped_cancel_callback_ = cancelCallbackWrapper( wrapped_cancel_callback_
                                                       , native_loader_
                                                       , context_loaders_ );

      wrapped_done_callback_ = doneCallbackWrapper( wrapped_done_callback_
                                                   , native_loader_
                                                   , context_loaders_ );

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
               if ( native_cancel_callback_ )
                  native_cancel_callback_( NO );

               progress_block_holder_.progressBlock = nil;
               cancel_block_holder_.cancelBlock = nil;
               finish_block_holder_.didFinishBlock = nil;
            }
         } copy ] autorelease ];

         [ context_loaders_ addActiveNativeLoader: native_loader_
                                    wrappedCancel: wrapped_cancel_block_ ];
         logBalancerState();

         return wrapped_cancel_block_;
      }

      cancel_block_ = [ [ ^( BOOL canceled_ ) { /* do nothing */ } copy ] autorelease ];
      return cancel_block_;
   } copy ] autorelease ];
}

static JFFAsyncOperation balancedAsyncOperationWithContext( JFFAsyncOperation native_loader_
                                                           , JFFContextLoaders* context_loaders_
                                                           , JFFInsertPendingLoaderPositionType pending_position_ )
{
   native_loader_ = [ [ native_loader_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      //TODO check condition yet
      if ( ( [ sharedBalancer().activeContextName isEqualToString: context_loaders_.name ]
            && context_loaders_.activeLoadersNumber < max_operation_count_ )
          || global_active_number_ == 0 )
      {
         JFFAsyncOperation context_loader_ = wrappedAsyncOperationWithContext( native_loader_, context_loaders_ );
         return context_loader_( progress_callback_, cancel_callback_, done_callback_ );
      }

      [ context_loaders_ addPendingNativeLoader: native_loader_
                               progressCallback: progress_callback_
                                 cancelCallback: cancel_callback_
                                   doneCallback: done_callback_
                                pendingPosition: pending_position_ ];

      logBalancerState();

      JFFCancelAsyncOperation cancel_ = [ [ ^( BOOL canceled_ )
      {
         if ( ![ context_loaders_ containsPendingNativeLoader: native_loader_ ] )
         {
            //cancel only wrapped cancel block
            [ context_loaders_ cancelActiveNativeLoader: native_loader_ cancel: canceled_ ];
            return;
         }

         if ( canceled_ )
         {
            [ context_loaders_ removePendingNativeLoader: native_loader_ ];
            cancel_callback_( YES );
         }
         else
         {
            cancel_callback_( NO );

            [ context_loaders_ unsubscribePendingNativeLoader: native_loader_ ];
         }
      } copy ] autorelease ];

      return cancel_;
   } copy ] autorelease ];
}

JFFAsyncOperation balancedAsyncOperation( JFFAsyncOperation native_loader_ )
{
   JFFContextLoaders* context_loaders_ = [ sharedBalancer() currentContextLoaders ];
   return balancedAsyncOperationWithContext( native_loader_, context_loaders_, JFFInsertPendingLoaderLast );
}
