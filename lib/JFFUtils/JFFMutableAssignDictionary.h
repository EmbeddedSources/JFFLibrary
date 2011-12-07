#import <Foundation/Foundation.h>

@interface JFFMutableAssignDictionary : NSObject

@property ( nonatomic, copy, readonly ) NSDictionary* dictionary;

-(NSUInteger)count;
-(id)objectForKey:( id )key_;

-(void)removeObjectForKey:( id )key_;
-(void)setObject:( id )object_ forKey:( id )key_;

-(void)removeAllObjects;

-(NSArray*)allKeys;
-(NSArray*)allValues;

@end
