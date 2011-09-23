#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface NSObject (WeakAsyncOperation)

-(JFFAsyncOperation)autoUnsibscribeAsyncOperation:( JFFAsyncOperation )async_op_;

-(JFFAsyncOperation)autoCancelAsyncOperation:( JFFAsyncOperation )async_op_;

@end
