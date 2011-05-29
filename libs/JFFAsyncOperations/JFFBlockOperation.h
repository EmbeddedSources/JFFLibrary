#include <ESCommon/ESUtils/Blocks/ESBlocksDefinitions.h>

#import <Foundation/Foundation.h>

@interface ESBlockOperation : NSOperation
{
@private
   JFFSyncOperation _load_data_block;
   JFFDidFinishAsyncOperationHandler _did_load_data_block;

   NSOperationQueue* _operation_queue;
}

+(id)performOperationWithLoadDataBlock:( JFFSyncOperation )load_data_block_
                        didCancelBlock:( JFFCancelHandler )cancel_block_
                      didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_;

@end
