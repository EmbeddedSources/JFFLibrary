#import <Foundation/Foundation.h>

@interface NSArray (BlocksAdditions)

#pragma mark -
#pragma mark block typedefs
typedef BOOL (^PredicateBlock)( id object_ );
typedef void (^ActionBlock)( id object_ );
typedef id (^MappingBlock)( id object_ );
typedef NSArray* (^FlattenBlock)( id object_ );

typedef void (^TransformBlock)( id first_object_, id second_object_ );


#pragma mark -
#pragma mark BlocksAdditions
+(id)arrayWithSize:( NSUInteger )size_
          producer:( id (^)( NSUInteger index_ ) )block_;

-(void)each:( void (^)( id object_ ) )block_;
-(NSArray*)map:( id (^)( id object_ ) )block_;
-(NSArray*)select:( BOOL (^)( id object_ ) )predicate_;
-(NSArray*)flatten:( NSArray* (^)( id object_ ) )block_;
-(NSUInteger)count:( BOOL (^)( id object_ ) )predicate_;
-(id)firstMatch:( BOOL (^)( id object_ ) )predicate_;

-(void)transformWithArray:( NSArray* )other_
                withBlock:( void (^)( id first_object_, id second_object_ ) )block_;

@end
