#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFPedingLoaderData : NSObject
{
@private
   JFFAsyncOperation _native_loader;
   JFFAsyncOperationProgressHandler _progress_callback;
   JFFCancelAsyncOperationHandler _cancel_callback;
   JFFDidFinishAsyncOperationHandler _done_callback;
}

@property ( nonatomic, copy ) JFFAsyncOperation nativeLoader;
@property ( nonatomic, copy ) JFFAsyncOperationProgressHandler progressCallback;
@property ( nonatomic, copy ) JFFCancelAsyncOperationHandler cancelCallback;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler doneCallback;

@end
