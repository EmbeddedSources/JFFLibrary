#import <Foundation/Foundation.h>

@interface JFFMutableAssignDictionary : NSObject

-(NSUInteger)count;
-(id)objectForKey:( id )key_;

-(void)removeObjectForKey:( id )key_;
-(void)setObject:( id )object_ forKey:( id )key_;

-(void)removeAllObjects;

@end
