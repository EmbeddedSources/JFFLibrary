#import "JFFAssignProxy.h"

@implementation JFFAssignProxy

@synthesize target = _target;

-(id)initWithTarget:( id )target_
{
   _target = target_;

   return self;
}

+(id)assignProxyWithTarget:( id )delegate_
{
   return [ [ self alloc ] initWithTarget: delegate_ ];
}

-(id)forwardingTargetForSelector:( SEL )selector_
{
   return self.target;
}

@end
