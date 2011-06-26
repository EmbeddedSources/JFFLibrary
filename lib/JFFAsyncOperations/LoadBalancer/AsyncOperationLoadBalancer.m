#import "AsyncOperationLoadBalancer.h"

@implementation AsyncOperationLoadBalancer

@end

JFFAsyncOperation balancedAsyncOperation( JFFAsyncOperation loader_ )
{
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
            , JFFCancelAsyncOperationHandler cancel_callback_
            , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      return [ [ ^( BOOL canceled_ ) {} copy ] autorelease ];
   } copy ] autorelease ];
}
