#import <Foundation/Foundation.h>

@interface JFFMutableAssignArray : NSObject

@property ( nonatomic, copy, readonly ) NSArray* array;

-(void)addObject:( id )object_;
-(BOOL)containsObject:( id )object_;
-(void)removeObject:( id )object_;
-(void)removeAllObjects;

@end
