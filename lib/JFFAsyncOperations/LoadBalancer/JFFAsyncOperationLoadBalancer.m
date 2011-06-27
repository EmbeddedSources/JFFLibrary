#import "JFFAsyncOperationLoadBalancer.h"

#import "JFFContextLoaders.h"
#import "JFFAsyncOperationLoadBalancerCotexts.h"

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

//TODO check on recurcive load balancer

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

static JFFCancelAsyncOperationHandler cancelCallbackWrapper( JFFCancelAsyncOperationHandler native_cancel_callback_
                                                            , JFFContextLoaders* context_loaders_ )
{
   native_cancel_callback_ = [ [ native_cancel_callback_ copy ] autorelease ];
   return [ [ ^( BOOL canceled_ )
   {
      if ( canceled_ )
      {
         --context_loaders_.activeLoadersNumber;
      }
      else
      {
         assert( NO );// @"balanced loaders should not be unsubscribed from native loader"
      }

      //TODO remove native loader from executing loaders if exists
      //TODO perform next loader

      if ( native_cancel_callback_ )
      {
         peformBlockWithinContext( ^
         {
            native_cancel_callback_( canceled_ );
         }, context_loaders_ );
      }
   } copy ] autorelease ];
}

static JFFDidFinishAsyncOperationHandler doneCallbackWrapper( JFFDidFinishAsyncOperationHandler native_done_callback_
                                                             , JFFContextLoaders* context_loaders_ )
{
   native_done_callback_ = [ [ native_done_callback_ copy ] autorelease ];
   return [ [ ^( id result_, NSError* error_ )
   {
      --context_loaders_.activeLoadersNumber;

      //TODO remove native loader from executing loaders if exists
      //TODO perform next loader

      if ( native_done_callback_ )
      {
         peformBlockWithinContext( ^
         {
            native_done_callback_( result_, error_ );
         }, context_loaders_ );
      }
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
      progress_callback_ = [ [ progress_callback_ copy ] autorelease ];
      JFFAsyncOperationProgressHandler wrapped_progress_callback_ = ^( id progress_info_ )
      {
         peformBlockWithinContext( ^
         {
            progress_callback_( progress_info_ );
         }, context_loaders_ );
      };

      JFFCancelAsyncOperationHandler wrapped_cancel_callback_ = cancelCallbackWrapper( native_cancel_callback_, context_loaders_ );
      JFFDidFinishAsyncOperationHandler wrapped_done_callback_ = doneCallbackWrapper( native_done_callback_, context_loaders_ );

      JFFCancelAsyncOperation cancel_block_ = native_loader_( wrapped_progress_callback_
                                                             , wrapped_cancel_callback_
                                                             , wrapped_done_callback_ );

      //TODO insert native loader to executing loaders here
      //and wrapped cancel_block_

      return [ [ ^( BOOL canceled_ )
      {
         if ( canceled_ )
         {
            cancel_block_( YES );
         }
         else
         {
            native_cancel_callback_( NO );
            //TODO unsubscribe here
         }
      } copy ] autorelease ];
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

      JFFCancelAsyncOperation wrapped_cancel_block_ = nil;

      if ( context_loaders_.activeLoadersNumber >= 5 /* || globalActiveNumber >= 10 */ )
      {
         [ context_loaders_.pendingLoaders addObject: native_loader_ ];
      }
      else
      {
         JFFAsyncOperation context_loader_ = balancedAsyncOperationWithContext( native_loader_, context_loaders_ );
         ++context_loaders_.activeLoadersNumber;
         wrapped_cancel_block_ = context_loader_( progress_callback_, cancel_callback_, done_callback_ );
      }

      return [ [ ^( BOOL canceled_ )
      {
         if ( wrapped_cancel_block_ )
         {
            wrapped_cancel_block_( canceled_ );
         }
         else
         {
            //executing or already executed
            if ( ![ context_loaders_.pendingLoaders containsObject: native_loader_ ] )
            {
               //TODO how to cancel if it executing now?
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
               //TODO unsubscribe here
            }
         }
      } copy ] autorelease ];
   } copy ] autorelease ];
}
