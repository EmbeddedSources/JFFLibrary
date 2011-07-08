#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFContextLoaders;

@interface JFFAsyncOperationLoadBalancerContexts : NSObject
{
@private
   NSString* _current_context_name;
   NSString* _active_context_name;
   NSMutableDictionary* _context_loaders_by_name;
}

@property ( nonatomic, retain ) NSString* currentContextName;
@property ( nonatomic, retain ) NSString* activeContextName;
@property ( nonatomic, retain, readonly ) NSMutableDictionary* contextLoadersByName;

@property ( nonatomic, retain, readonly ) NSArray* allContextNames;

+(id)sharedBalancer;

-(JFFContextLoaders*)activeContextLoaders;
-(JFFContextLoaders*)currentContextLoaders;

@end
