#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFActiveLoaderData : NSObject
{
@private
   JFFAsyncOperation _native_loader;
   JFFCancelAsyncOperation _wrapped_cancel;
}

@property ( nonatomic, copy ) JFFAsyncOperation nativeLoader;
@property ( nonatomic, copy ) JFFCancelAsyncOperation wrappedCancel;

@end
