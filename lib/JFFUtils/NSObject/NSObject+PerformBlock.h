#import <Foundation/Foundation.h>

//use those methods for blocks objects only
@interface NSObject (PerformBlock)

//Invokes self-block
-(void)performBlock;

//Invokes self-block on the main thread.
-(void)performBlockOnMainThread;

//Invokes self-block on the current thread.
-(void)performBlockOnCurrentThread;

//Invokes self-block on the current thread using the default mode after a delay.
-(void)performBlockAfterDelay:( NSTimeInterval )delay_;

@end
