#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFDidFinishAsyncOperationBlockHolder : NSObject
{
@private
   JFFDidFinishAsyncOperationHandler _did_finish_blcok;
}

@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didFinishBlock;
@property ( nonatomic, copy, readonly ) JFFDidFinishAsyncOperationHandler onceDidFinishBlock;

@end
