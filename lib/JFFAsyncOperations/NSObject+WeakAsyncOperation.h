#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface NSObject (WeakAsyncOperation)

-(JFFAsyncOperation)weakAsyncOperation:( JFFAsyncOperation )async_op_;

@end
