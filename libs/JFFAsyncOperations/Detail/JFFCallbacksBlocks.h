#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFCallbacksBlocks : NSObject
{
@private
   JFFAsyncOperationProgressHandler _on_progress_block;
   JFFDidFinishAsyncOperationHandler _did_load_data_block;
}

@property ( nonatomic, copy ) JFFAsyncOperationProgressHandler onProgressBlock;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didLoadDataBlock;

+(id)callbacksBlocksWithOnProgressBlock:( JFFAsyncOperationProgressHandler )on_progress_block_
                       didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_;

@end
