#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFAsyncOperationProgressBlockHolder : NSObject

@property ( nonatomic, copy ) JFFAsyncOperationProgressHandler progressBlock;

+(id)asyncOperationProgressBlockHolder;

-(void)performProgressBlockWithArgument:( id )progress_info_;

@end
