#import <Foundation/Foundation.h>

@interface JFFMutableAssignArray : NSObject

//JTODO remove
//should return native object, not assign wrapper
@property ( nonatomic, copy, readonly ) NSArray* array;

//compare elements by pointers only
-(void)addObject:( id )object_;
-(BOOL)containsObject:( id )object_;
-(void)removeObject:( id )object_;
-(void)removeAllObjects;

-(NSUInteger)count;

@end
