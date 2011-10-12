#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFDidFinishAsyncOperationBlockHolder : NSObject

@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didFinishBlock;

+(id)didFinishAyncOperationBlockHolder;

-(void)performDidFinishBlockOnceWithResult:( id )result_ error:( NSError* )error_;

@end
