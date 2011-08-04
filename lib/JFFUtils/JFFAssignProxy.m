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
   return [ [ [ self alloc ] initWithTarget: delegate_ ] autorelease ];
}

-(void)forwardInvocation:( NSInvocation* )invocation_
{
   SEL selector_ = [ invocation_ selector ];

   if ( [ self.target respondsToSelector: selector_ ] )
      [ invocation_ invokeWithTarget: self.target ];
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
   return [ self.target methodSignatureForSelector: selector_ ];
}

-(BOOL)isEqual:( id )object_
{
   return [ self.target isEqual: [ object_ target ] ];
}

-(NSUInteger)hash
{
   return [ self.target hash ];
}

@end
