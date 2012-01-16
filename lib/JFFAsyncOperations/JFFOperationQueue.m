#import "JFFOperationQueue.h"

@interface JFFOperationQueue ()

@property ( nonatomic, retain ) NSOperationQueue* queue;

@end

@implementation JFFOperationQueue

@synthesize queue = _queue;

-(void)dealloc
{
    [ _queue release ];

    [ super dealloc ];
}

-(NSOperationQueue*)queue
{
    if ( !_queue )
    {
        _queue = [ NSOperationQueue new ];
    }

    return _queue;
}

+(id)sharedQueue
{
    static dispatch_once_t once_;
    static id instance_;
    dispatch_once( &once_, ^{ instance_ = [ [ self class ] new ]; } );
    return instance_;
}

-(void)addOperation:( NSOperation* )operation_
{
     [ self.queue addOperation: operation_ ];
}

@end
