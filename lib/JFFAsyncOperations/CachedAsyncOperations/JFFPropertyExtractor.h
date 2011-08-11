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

@property ( nonatomic, retain ) JFFPropertyPath* propertyPath;
@property ( nonatomic, retain ) NSObject* object;

//object related data
@property ( nonatomic, retain ) NSMutableArray* delegates;
@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;
@property ( nonatomic, copy ) JFFAsyncOperation asyncLoader;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didFinishBlock;

@property ( nonatomic, retain ) id property;

-(void)clearData;

@end
