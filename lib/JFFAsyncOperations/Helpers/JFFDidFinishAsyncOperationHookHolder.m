#import "JFFDidFinishAsyncOperationHookHolder.h"

@implementation JFFDidFinishAsyncOperationHookHolder

@synthesize finishHookBlock = _finishHookBlock;

-(void)dealloc
{
    [ _finishHookBlock release ];

    [ super dealloc ];
}

@end
