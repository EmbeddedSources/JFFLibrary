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
   static id instance_ = nil;

   if ( !instance_ )
   {
      instance_ = [ self new ];
   }

   return instance_;
}

-(void)addOperation:( NSOperation* )operation_
{
   [ self.queue addOperation: operation_ ];
}

@end
