#import <Foundation/Foundation.h>

@interface JFFAssignProxy : NSProxy

@property ( nonatomic, unsafe_unretained, readonly ) id target;

+(id)assignProxyWithTarget:( id )target_;

@end
