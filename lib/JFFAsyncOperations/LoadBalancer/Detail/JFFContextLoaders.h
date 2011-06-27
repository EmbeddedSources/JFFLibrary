#import <Foundation/Foundation.h>

@interface JFFContextLoaders : NSObject

@property ( nonatomic, assign ) NSUInteger activeLoadersNumber;
@property ( nonatomic, retain ) NSMutableArray* pendingLoaders;
@property ( nonatomic, retain ) NSString* name;

@end
