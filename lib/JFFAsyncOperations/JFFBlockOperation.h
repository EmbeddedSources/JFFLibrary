#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

//TODO remove
@interface JFFBlockOperation : NSOperation
{
@private
   JFFSyncOperation _load_data_block;
   JFFDidFinishAsyncOperationHandler _did_load_data_block;
}

+(id)performOperationWithLoadDataBlock:( JFFSyncOperation )load_data_block_
                      didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_;

-(void)cancel:( BOOL )cancel_;

@end
