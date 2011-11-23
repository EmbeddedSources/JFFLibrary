#import "JFFMutableAssignDictionary.h"

#import "JFFAssignProxy.h"
#import "NSObject+OnDeallocBlock.h"

#include "JFFUtilsBlockDefinitions.h"

@interface JFFAutoRemoveFromDictAssignProxy : JFFAssignProxy

@property ( nonatomic, copy ) JFFSimpleBlock onDeallocBlock;

@end

@implementation JFFAutoRemoveFromDictAssignProxy

@synthesize onDeallocBlock = _onDeallocBlock;

-(void)dealloc
{
   [ _onDeallocBlock release ];

   [ super dealloc ];
}

-(void)onAddToMutableAssignDictionary:( JFFMutableAssignDictionary* )dict_
                                  key:( id )key_
{
   __unsafe_unretained JFFMutableAssignDictionary* assign_dict_ = dict_;
   onDeallocBlock = ^void( void )
   {
      [ assign_dict_ removeObjectForKey: key_ ];
   };
   [ self.target addOnDeallocBlock: onDeallocBlock ];
}

-(void)onRemoveFromMutableAssignDictionary:( JFFMutableAssignDictionary* )array_
{
   [ self.target removeOnDeallocBlock: onDeallocBlock ];
   onDeallocBlock = nil;
}

@end

@interface JFFMutableAssignDictionary ()

@property ( nonatomic, retain ) NSMutableDictionary* mutableDictionary;

@end

@implementation JFFMutableAssignDictionary

@synthesize mutableDictionary = _mutableDictionary;

-(void)dealloc
{
   [ self removeAllObjects ];
   [ _mutableDictionary release ];

   [ super dealloc ];
}

-(void)removeAllObjects
{
   for( JFFAutoRemoveFromDictAssignProxy* proxy_ in [ mutableDictionary allValues ] )
   {
      [  proxy_ onRemoveFromMutableAssignDictionary: self ];
   }
   [ mutableDictionary removeAllObjects ];
}

-(NSMutableDictionary*)mutableDictionary
{
   if ( !mutableDictionary )
   {
      mutableDictionary = [ NSMutableDictionary new ];
   }
   return mutableDictionary;
}

-(NSUInteger)count
{
   return [ mutableDictionary count ];
}

-(id)objectForKey:( id )key_
{
   JFFAutoRemoveFromDictAssignProxy* proxy_ = [ mutableDictionary objectForKey: key_ ];
   return proxy_.target;
}

-(void)removeObjectForKey:( id )key_
{
   JFFAutoRemoveFromDictAssignProxy* proxy_ = [ mutableDictionary objectForKey: key_ ];
   [ proxy_ onRemoveFromMutableAssignDictionary: self ];
   [ mutableDictionary removeObjectForKey: key_ ];
}

-(void)setObject:( id )object_ forKey:( id )key_
{
   id previous_object_ = [ self objectForKey: key_ ];
   if ( previous_object_ )
   {
      [ self removeObjectForKey: key_ ];
   }

   JFFAutoRemoveFromDictAssignProxy* proxy_ = [ [ JFFAutoRemoveFromDictAssignProxy alloc ] initWithTarget: object_ ];
   [ self.mutableDictionary setObject: proxy_ forKey: key_ ];
   [ proxy_ onAddToMutableAssignDictionary: self key: key_ ];
   [ proxy_ release ];
}

-(NSString*)description
{
   return [ mutableDictionary description ];
}

-(NSArray*)allKeys
{
   return [ mutableDictionary allKeys ];
}

@end
