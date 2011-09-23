#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFObjectRelatedPropertyData : NSObject
{
@private
   NSMutableArray* _delegates;
   JFFAsyncOperation _async_loader;
   JFFDidFinishAsyncOperationHandler _did_finish_block;
   JFFCancelAsyncOperation _cancel_block;
}

@property ( nonatomic, retain ) NSMutableArray* delegates;
@property ( nonatomic, copy ) JFFAsyncOperation asyncLoader;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didFinishBlock;
@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;

@end
