#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFContextLoaders;

@interface JFFAsyncOperationLoadBalancerCotexts : NSObject

@property ( nonatomic, retain ) NSString* currentContextName;
@property ( nonatomic, retain ) NSString* activeContextName;
@property ( nonatomic, retain ) NSMutableDictionary* contextLoadersByName;

+(id)sharedBalancer;

-(JFFContextLoaders*)currentContextLoaders;

@end
