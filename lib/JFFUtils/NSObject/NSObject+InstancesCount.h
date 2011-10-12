#import <Foundation/Foundation.h>

@interface NSObject (InstancesCount)

//TODO hook also copy methods
+(void)enableInstancesCounting;

+(NSUInteger)instancesCount;

@end
