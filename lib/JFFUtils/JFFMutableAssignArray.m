#import "JFFMutableAssignArray.h"

#import "JFFAssignProxy.h"
#import "JFFUtilsBlockDefinitions.h"

#import "NSArray+BlocksAdditions.h"
#import "NSObject+OnDeallocBlock.h"

@interface JFFAutoRemoveAssignProxy : JFFAssignProxy

@property ( nonatomic, copy ) JFFSimpleBlock onDeallocBlock;

@end

@implementation JFFAutoRemoveAssignProxy

@synthesize onDeallocBlock = _on_dealloc_block;

-(void)dealloc
{
   [ _on_dealloc_block release ];

   [ super dealloc ];
}

-(void)onAddToMutableAssignArray:( JFFMutableAssignArray* )array_
{
   __block JFFMutableAssignArray* assign_array_ = array_;
   __block JFFAutoRemoveAssignProxy* self_ = self;
   self.onDeallocBlock = ^( void )
   {
      [ assign_array_ removeObject: self_.target ];
   };
   [ self.target addOnDeallocBlock: self.onDeallocBlock ];
}

-(void)onRemoveFromMutableAssignArray:( JFFMutableAssignArray* )array_
{
   [ self.target removeOnDeallocBlock: self.onDeallocBlock ];
   self.onDeallocBlock = nil;
}

@end

@interface JFFMutableAssignArray ()

@property ( nonatomic, retain ) NSMutableArray* mutableArray;

@end

@implementation JFFMutableAssignArray

@synthesize mutableArray = _mutable_array;
@dynamic array;

-(void)dealloc
{
   [ _mutable_array release ];

   [ super dealloc ];
}

-(NSMutableArray*)mutableArray
{
   if ( !_mutable_array )
   {
      _mutable_array = [ NSMutableArray new ];
   }
   return _mutable_array;
}

-(NSArray*)array
{
   return [ NSArray arrayWithArray: _mutable_array ];
}

-(void)addObject:( id )object_
{
   JFFAutoRemoveAssignProxy* proxy_ = [ JFFAutoRemoveAssignProxy assignProxyWithTarget: object_ ];
   [ self.mutableArray addObject: proxy_ ];
   [ proxy_ onAddToMutableAssignArray: self ];
}

-(BOOL)containsObject:( id )object_
{
   JFFAutoRemoveAssignProxy* proxy_ = _mutable_array ? [ JFFAutoRemoveAssignProxy assignProxyWithTarget: object_ ] : nil;
   return [ _mutable_array containsObject: proxy_ ];
}

-(void)removeObject:( id )object_
{
   JFFAutoRemoveAssignProxy* proxy_ = _mutable_array ? [ JFFAutoRemoveAssignProxy assignProxyWithTarget: object_ ] : nil;

   proxy_ = [ _mutable_array firstMatch: ^BOOL( id object_ )
   {
      return [ object_ isEqual: proxy_ ];
   } ];

   if ( proxy_ )
   {
      [  proxy_ onRemoveFromMutableAssignArray: self ];
      [ _mutable_array removeObject: proxy_ ];
   }
}

-(void)removeAllObjects
{
   for( JFFAutoRemoveAssignProxy* proxy_ in _mutable_array )
   {
      [  proxy_ onRemoveFromMutableAssignArray: self ];
   }
   [ _mutable_array removeAllObjects ];
}

@end
