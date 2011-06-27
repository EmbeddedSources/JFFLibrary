#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFCancelAyncOperationBlockHolder : NSObject
{
@private
   JFFCancelAsyncOperation _cancel_block;
}

@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;

+(id)cancelAyncOperationBlockHolder;

-(void)performCancelBlockOnceWithArgument:( BOOL )cancel_;

@end
