#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFPropertyPath;
@class JFFPropertyExtractor;

typedef JFFPropertyExtractor* (^JFFPropertyExtractorFactoryBlock)( void );

@interface NSObject (AsyncPropertyReader)

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )property_name_
                                       asyncOperation:( JFFAsyncOperation )async_operation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )property_name_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                       asyncOperation:( JFFAsyncOperation )async_operation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )async_operation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_;

-(BOOL)isLoadingPropertyForPropertyName:( NSString* )name_;

@end
