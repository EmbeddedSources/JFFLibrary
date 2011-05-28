#import <Foundation/Foundation.h>

//use for blocks objects only
@interface NSObject (PerformBlock)

-(void)performBlock;

-(void)performBlockOnMainThread;

-(void)performBlockAfterDelay:( NSTimeInterval )delay_;

@end
