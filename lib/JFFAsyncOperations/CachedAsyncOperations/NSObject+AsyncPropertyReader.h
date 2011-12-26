#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFPropertyPath;
@class JFFPropertyExtractor;

typedef JFFPropertyExtractor* (^JFFPropertyExtractorFactoryBlock)( void );

@interface NSObject (AsyncPropertyReader)

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )propertyName_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )propertyName_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_;

-(BOOL)isLoadingPropertyForPropertyName:( NSString* )name_;

@end
