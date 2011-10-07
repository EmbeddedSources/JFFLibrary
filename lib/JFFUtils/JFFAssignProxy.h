#import <Foundation/Foundation.h>

@interface JFFAssignProxy : NSProxy

@property ( nonatomic, assign, readonly ) id target;

+(id)assignProxyWithTarget:( id )delegate_;

@end
