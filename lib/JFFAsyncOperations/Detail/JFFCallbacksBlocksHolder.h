#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFCallbacksBlocksHolder : NSObject
{
@private
   JFFAsyncOperationProgressHandler _on_progress_block;
   JFFCancelAsyncOperationHandler _on_cancel_block;
   JFFDidFinishAsyncOperationHandler _did_load_data_block;
}

@property ( nonatomic, copy ) JFFAsyncOperationProgressHandler onProgressBlock;
@property ( nonatomic, copy ) JFFCancelAsyncOperationHandler onCancelBlock;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didLoadDataBlock;

+(id)callbacksBlocksHolderWithOnProgressBlock:( JFFAsyncOperationProgressHandler )on_progress_block_
                                onCancelBlock:( JFFCancelAsyncOperationHandler )on_cancel_block_
                             didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_;

@end
