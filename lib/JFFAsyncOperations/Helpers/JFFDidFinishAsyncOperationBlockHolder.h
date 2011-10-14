#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFDidFinishAsyncOperationBlockHolder : NSObject

@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didFinishBlock;
@property ( nonatomic, copy, readonly ) JFFDidFinishAsyncOperationHandler onceDidFinishBlock;

+(id)didFinishAyncOperationBlockHolder;

-(void)performDidFinishBlockOnceWithResult:( id )result_ error:( NSError* )error_;

@end
