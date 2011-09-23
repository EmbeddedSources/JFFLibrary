#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFCancelAyncOperationBlockHolder : NSObject
{
@private
   JFFCancelAsyncOperation _cancel_block;
}

@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;
@property ( nonatomic, copy, readonly ) JFFCancelAsyncOperation onceCancelBlock;

@end
