#import <Foundation/Foundation.h>

@interface JFFAssignProxy : NSProxy
{
@private
   id _target;
}

@property ( nonatomic, assign, readonly ) id target;

+(id)assignProxyWithTarget:( id )delegate_;

@end
