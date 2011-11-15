#import <Foundation/Foundation.h>

@interface JFFAssignProxy : NSProxy

@property ( nonatomic, assign, readonly ) id target;

-(id)initWithTarget:( id )target_;

@end
