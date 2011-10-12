#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFCancelAyncOperationBlockHolder : NSObject

@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;

+(id)cancelAyncOperationBlockHolder;

-(void)performCancelBlockOnceWithArgument:( BOOL )cancel_;

@end
