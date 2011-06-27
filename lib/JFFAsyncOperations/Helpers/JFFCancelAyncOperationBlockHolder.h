#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFCancelAyncOperationBlockHolder : NSObject
{
@private
   JFFCancelAsyncOperation _simple_block;
}

//TODO rename property
@property ( nonatomic, copy ) JFFCancelAsyncOperation simpleBlock;

+(id)cancelAyncOperationBlockHolder;

-(void)performCancelBlockOnceWithArgument:( BOOL )cancel_;

@end
