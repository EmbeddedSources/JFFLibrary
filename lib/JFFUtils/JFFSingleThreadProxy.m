#import "JFFSingleThreadProxy.h"

#import "JFFResultContext.h"
#include "JGCDAdditions.h"

@interface JFFProxyObjectContainer : NSObject

@property ( retain, nonatomic ) id target;

@end

@implementation JFFProxyObjectContainer

@synthesize target;

@end

@interface JFFSingleThreadProxy ()

@property ( retain, nonatomic ) JFFProxyObjectContainer* container;
@property ( assign, nonatomic ) dispatch_queue_t dispatchQueue;

@end

@implementation JFFSingleThreadProxy

@synthesize container;
@synthesize dispatchQueue;

-(void)dealloc
{
   JFFProxyObjectContainer* container_ = self.container;
   void (^release_listener_)( void ) = ^void( void )
   {
      container_.target = nil;
   };
   dispatch_async( dispatchQueue, release_listener_ );
   dispatch_release( dispatchQueue );

   [ container release ];

   [ super dealloc ];
}

-(id)initWithTargetFactory:( JFFObjectFactory )factory_
             dispatchQueue:( dispatch_queue_t )dispatch_queue_
{
   dispatchQueue = dispatch_queue_;
   dispatch_retain( dispatchQueue );

   factory_ = [ [ factory_ copy ] autorelease ];
   void (^release_listener_)( void ) = ^void( void )
   {
      self.container = [ [ JFFProxyObjectContainer new ] autorelease ];
      self.container.target = factory_();
   };
   dispatch_async( dispatchQueue, release_listener_ );

   return self;
}

+(id)singleThreadProxyWithTargetFactory:( JFFObjectFactory )factory_
                          dispatchQueue:( dispatch_queue_t )dispatch_queue_
{
   JFFSingleThreadProxy* result_ = [ [ self alloc ] initWithTargetFactory: factory_
                                                            dispatchQueue: dispatch_queue_ ];

   return [ result_ autorelease ];
}

-(void)forwardInvocation:( NSInvocation* )invocation_
{
   SEL selector_ = [ invocation_ selector ];

   void (^forward_invocation_)( void ) = ^void( void )
   {
      if ( [ self.container.target respondsToSelector: selector_ ] )
         [ invocation_ invokeWithTarget: self.container.target ];
   };
   safe_dispatch_sync( dispatchQueue, forward_invocation_ );
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
   JFFResultContext* context_ = [ JFFResultContext new ];
   void (^method_signature_)( void ) = ^void( void )
   {
      context_.result = [ self.container.target methodSignatureForSelector: selector_ ];
   };
   safe_dispatch_sync( dispatchQueue, method_signature_ );
   return context_.result;
}

@end
