#import "JFFScheduler.h"

#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

@interface JFFScheduler ()

@property ( nonatomic, retain ) NSMutableArray* cancelBlocks;

@end

@implementation JFFScheduler

@synthesize cancelBlocks = _cancel_blocks;

-(id)init
{
   self = [ super init ];

   if ( self )
   {
      self.cancelBlocks = [ NSMutableArray array ];
   }

   return self;
}

+(id)scheduler
{
   return [ [ self new ] autorelease ];
}

+(id)sharedScheduler
{
   static id instance_ = nil;
   if ( !instance_ )
   {
      instance_ = [ self new ];
   }
   return instance_;
}

-(void)dealloc
{
   [ self cancelAllScheduledOperations ];

   [ _cancel_blocks release ];

   [ super dealloc ];
}

-(JFFCancelScheduledBlock)addBlock:( JFFScheduledBlock )action_block_
                          duration:( NSTimeInterval )duration_
{
   NSAssert( action_block_, @"It has no sense to use nil block for scheduler" );
   if ( !action_block_ )
      return [ [ ^(){ /* do nothing */ } copy ] autorelease ];

   dispatch_queue_t queue_ = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );

   dispatch_source_t timer_ = dispatch_source_create( DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue_ );

   dispatch_source_set_timer( timer_
                             , dispatch_time( DISPATCH_TIME_NOW, duration_ * NSEC_PER_SEC )
                             , DISPATCH_TIME_FOREVER
                             , 0 );

   __block JFFScheduler* self_ = self;

   JFFSimpleBlockHolder* cancel_timer_block_holder_ = [ [ JFFSimpleBlockHolder new ] autorelease ];
   __block JFFSimpleBlockHolder* weak_cancel_timer_block_holder_ = cancel_timer_block_holder_;
   cancel_timer_block_holder_.simpleBlock = ^void( void )
   {
      dispatch_source_cancel( timer_ );
      dispatch_release( timer_ );
      [ self_.cancelBlocks removeObject: weak_cancel_timer_block_holder_.simpleBlock ];
   };

   [ self.cancelBlocks addObject: cancel_timer_block_holder_.simpleBlock ];

   action_block_ = [ [ action_block_ copy ] autorelease ];
   dispatch_block_t event_handler_block_ = [ [ ^void( void )
   {
      action_block_( cancel_timer_block_holder_.onceSimpleBlock );
   } copy ] autorelease ];

   dispatch_source_set_event_handler( timer_, event_handler_block_ );

   dispatch_resume( timer_ );

   return cancel_timer_block_holder_.onceSimpleBlock;
}

-(void)cancelAllScheduledOperations
{
   NSMutableSet* cancel_blocks_ = [ self.cancelBlocks copy ];
   self.cancelBlocks = nil;
   for ( JFFCancelScheduledBlock cancel_ in cancel_blocks_ )
      cancel_();
   [ cancel_blocks_ release ];
}

@end
