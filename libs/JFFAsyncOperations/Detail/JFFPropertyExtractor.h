#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFPropertyPath;

@interface JFFPropertyExtractor : NSObject
{
@private
   JFFPropertyPath* _property_path;
   NSObject* _object;

   SEL _property_get_selector;
   SEL _property_set_selector;
}

@property ( nonatomic, retain, readonly ) JFFPropertyPath* propertyPath;
@property ( nonatomic, retain, readonly ) NSObject* object;

//object related data
@property ( nonatomic, retain ) NSMutableArray* delegates;
@property ( nonatomic, copy ) JFFCancelAsyncOpration cancelBlock;
@property ( nonatomic, copy ) JFFAsyncOperation asyncLoader;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didFinishBlock;

@property ( nonatomic, retain ) id property;

+(id)propertyForObject:( NSObject* )object_
          propertyPath:( JFFPropertyPath* )property_path_
           asyncLoader:( JFFAsyncOperation )async_loader_
        didFinishBlock:( JFFDidFinishAsyncOperationHandler )did_finish_block_;

-(void)clearData;

@end
