#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFDidFinishAsyncOperationHookHolder : NSObject

@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHook finishHookBlock;

@end
