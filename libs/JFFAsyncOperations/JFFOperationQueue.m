#import "JFFOperationQueue.h"

static JFFOperationQueue* instance_ = nil;

static NSUInteger max_operations_for_current_context_ = 5;
static NSUInteger max_operations_for_background_context_ = 1;

@interface NSObject (SetOperationQueue)

-(void)setOperationQueue:( NSOperationQueue* )queue_;

@end

@implementation NSObject (SetOperationQueue)

-(void)setOperationQueue:( NSOperationQueue* )queue_
{
}

@end

@interface JFFOperationQueue ()

@property ( nonatomic, retain ) NSMutableDictionary* queues;
@property ( nonatomic, retain ) NSOperationQueue* globalQueue;
@property ( nonatomic, retain ) NSOperationQueue* currentQueue;

@end

@implementation JFFOperationQueue

@synthesize queues = _queues;
@synthesize globalQueue = _global_queue;
@synthesize currentQueue = _current_queue;

-(void)dealloc
{
   [ _queues release ];
   [ _global_queue release ];
   [ _current_queue release ];

   [ super dealloc ];
}

-(NSMutableDictionary*)queues
{
   if ( !_queues )
   {
      _queues = [ [ NSMutableDictionary alloc ] init ];
   }

   return _queues;
}

-(NSOperationQueue*)globalQueue
{
   if ( !_global_queue )
   {
      _global_queue = [ [ NSOperationQueue alloc ] init ];
   }

   return _global_queue;
}

-(NSOperationQueue*)queueForContextName:( NSString* )context_name_
{
   NSAssert( context_name_, @"context name can't be nil" );

   NSOperationQueue* queue_ = [ self.queues objectForKey: context_name_ ];
   if ( !queue_ )
   {
      queue_ = [ [ [ NSOperationQueue alloc ] init ] autorelease ];
      [ self.queues setObject: queue_ forKey: context_name_ ];
   }

   return queue_;
}

-(void)setCurrentContextQueue:( NSOperationQueue* )queue_
{
   if ( self.currentQueue != queue_ )
   {
      [ self.currentQueue setMaxConcurrentOperationCount: max_operations_for_background_context_ ];
      self.currentQueue = queue_;
      [ self.currentQueue setMaxConcurrentOperationCount: max_operations_for_current_context_ ];
   }
}

-(void)setContextName:( NSString* )context_name_
{
   NSOperationQueue* queue_ = [ self queueForContextName: context_name_ ];
   
   [ self setCurrentContextQueue: queue_ ];
}

-(NSOperationQueue*)currentContextQueue
{
   return self.currentQueue ? self.currentQueue : self.globalQueue;
}

+(id)sharedQueue
{
   if ( !instance_ )
   {
      instance_ = [ [ self alloc ] init ];
   }

   return instance_;
}

-(void)addOperation:( NSOperation* )operation_
{
   NSOperationQueue* queue_ = [ self currentContextQueue ];
   [ operation_ setOperationQueue: queue_ ];
   [ queue_ addOperation: operation_ ];
}

-(void)addOperationToGlobalQueue:( NSOperation* )operation_
{
   [ operation_ setOperationQueue: self.globalQueue ];
   [ self.globalQueue addOperation: operation_ ];
}

@end
