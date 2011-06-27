#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFBlockOperation : NSOperation
{
@private
   JFFSyncOperation _load_data_block;
   JFFCancelAsyncOperationHandler _cancel_block_handler;
   JFFDidFinishAsyncOperationHandler _did_load_data_block;
}

+(id)performOperationWithLoadDataBlock:( JFFSyncOperation )load_data_block_
                        didCancelBlock:( JFFCancelAsyncOperationHandler )cancel_block_handler_
                      didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_;

-(void)cancel:( BOOL )cancel_;

@end
