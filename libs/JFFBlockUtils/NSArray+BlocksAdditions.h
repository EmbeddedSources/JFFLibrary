#import <Foundation/Foundation.h>

@interface NSArray (BlocksAdditions)

#pragma mark -
#pragma mark block typedefs
typedef BOOL (^PredicateBlock)( id object_ );
typedef void (^ActionBlock)( id object_ );
typedef id (^MappingBlock)( id object_ );
typedef id (^ProducerBlock)( NSUInteger index_ );
typedef NSArray* (^FlattenBlock)( id object_ );

typedef void (^TransformBlock)( id first_object_, id second_object_ );

#pragma mark -
#pragma mark BlocksAdditions
+(id)arrayWithSize:( NSUInteger )size_
          producer:( ProducerBlock )block_;

-(void)each:( ActionBlock )block_;
-(NSArray*)map:( MappingBlock )block_;
-(NSArray*)select:( PredicateBlock )predicate_;
-(NSArray*)flatten:( FlattenBlock )block_;
-(NSUInteger)count:( PredicateBlock )predicate_;
-(id)firstMatch:( PredicateBlock )predicate_;

-(void)transformWithArray:( NSArray* )other_
                withBlock:( TransformBlock )block_;

@end
