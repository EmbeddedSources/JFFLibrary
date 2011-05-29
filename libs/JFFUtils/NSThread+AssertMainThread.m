#import "NSThread+AssertMainThread.h"

@implementation NSThread (AssertMainThread)

+(void)assertMainThread
{
   NSAssert( [ NSThread currentThread ].isMainThread, @"should be called only from main thread" );
}

@end
