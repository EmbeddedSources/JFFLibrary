#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFAsyncOperationProgressBlockHolder : NSObject
{
@private
   JFFAsyncOperationProgressHandler _progress_block;
}

@property ( nonatomic, copy ) JFFAsyncOperationProgressHandler progressBlock;

-(void)performProgressBlockWithArgument:( id )progress_info_;

@end
