#import "JFFMulticastDelegate.h"

#import "JFFAssignProxy.h"
#import "JFFUtilsBlockDefinitions.h"

#import "NSArray+BlocksAdditions.h"
#import "NSObject+OnDeallocBlock.h"

@interface JFFMulticastDelegate ()

@property ( nonatomic, retain ) NSMutableArray* delegates;

@end

@interface JFFAssignProxyDelegate : JFFAssignProxy

@property ( nonatomic, copy ) JFFSimpleBlock onDeallocBlock;

@end

@implementation JFFAssignProxyDelegate

@synthesize onDeallocBlock = _on_dealloc_block;

-(void)dealloc
{
   [ _on_dealloc_block release ];

   [ super dealloc ];
}

-(void)onAddToMulticastDelegate:( JFFMulticastDelegate* )multicast_delegate_
{
   __block JFFMulticastDelegate* assign_multicast_delegate_ = multicast_delegate_;
   __block JFFAssignProxyDelegate* self_ = self;
   self.onDeallocBlock = ^( void )
   {
      [ assign_multicast_delegate_ removeDelegate: self_.target ];
   };
   [ self.target addOnDeallocBlock: self.onDeallocBlock ];
}

-(void)onRemoveFromMulticastDelegate:( JFFMulticastDelegate* )multicast_delegate_
{
   [ self.target removeOnDeallocBlock: self.onDeallocBlock ];
   self.onDeallocBlock = nil;
}

@end

@implementation JFFMulticastDelegate

@synthesize delegates = _delegates;

-(void)dealloc
{
   [ self removeAllDelegates ];
   [ _delegates release ];

   [ super dealloc ];
}

-(NSMutableArray*)delegates
{
   if ( !_delegates )
   {
      _delegates = [ NSMutableArray new ];
   }
   return _delegates;
}

-(void)addDelegate:( id )delegate_
{
   JFFAssignProxyDelegate* proxy_ = [ JFFAssignProxyDelegate assignProxyWithTarget: delegate_ ];
   if ( ![ self.delegates containsObject: proxy_ ] )
   {
      [ self.delegates addObject: proxy_ ];
      [ proxy_ onAddToMulticastDelegate: self ];
   }
}

-(void)removeDelegate:( id )delegate_
{
   JFFAssignProxyDelegate* proxy_ = [ JFFAssignProxyDelegate assignProxyWithTarget: delegate_ ];

   proxy_ = [ _delegates firstMatch: ^BOOL( id object_ )
   {
      return [ object_ isEqual: proxy_ ];
   } ];

   if ( proxy_ )
   {
      [  proxy_ onRemoveFromMulticastDelegate: self ];
      [ _delegates removeObject: proxy_ ];
   }
}

-(void)removeAllDelegates
{
   for( JFFAssignProxyDelegate* proxy_ in _delegates )
   {
      [  proxy_ onRemoveFromMulticastDelegate: self ];
   }
   [ _delegates removeAllObjects ];
}

-(void)forwardInvocation:( NSInvocation* )invocation_
{
   SEL selector_ = [ invocation_ selector ];

   NSArray* delegates_ = _delegates ? [ [ NSArray alloc ] initWithArray: _delegates ] : nil;
   for( JFFAssignProxyDelegate* proxy_ in delegates_ )
   {
      if ( [ proxy_ respondsToSelector: selector_ ] )
      {
         [ invocation_ invokeWithTarget: proxy_ ];
      }
   }
   [ delegates_ release ];
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
   for( JFFAssignProxyDelegate* proxy_ in _delegates )
   {
      NSMethodSignature* result_ = [ proxy_ methodSignatureForSelector: selector_ ];
      if( result_ )
         return result_;
   }

   return [ [ self class ] instanceMethodSignatureForSelector: @selector( doNothing ) ];
}

-(void)doNothing
{
}

@end
