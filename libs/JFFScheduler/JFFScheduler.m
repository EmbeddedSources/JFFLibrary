#import "JFFScheduler.h"

@interface JFFScheduler ()

@property ( nonatomic, retain ) NSMutableSet* cancelBlocks;

@end

@implementation JFFScheduler

@synthesize cancelBlocks = _cancel_blocks;

-(id)init
{
   self = [ super init ];

   self.cancelBlocks = [ NSMutableSet set ];

   return self;
}

+(id)scheduler
{
   return [ [ [ self alloc ] init ] autorelease ];
}

+(id)sharedScheduler
{
   static id instance_ = nil;
   if ( !instance_ )
   {
      instance_ = [ [ self alloc ] init ];
   }
   return instance_;
}

-(void)dealloc
{
   [ self cancelAllScheduledOperations ];

   [ _cancel_blocks release ];

   [ super dealloc ];
}

-(JFFCancelScheduledBlock)addBlock:( JFFScheduledBlock )block_
                          duration:( NSTimeInterval )duration_
{
   __block JFFCancelScheduledBlock cancel_block_ = nil;

   block_ = [ [ block_ copy ] autorelease ];
   void (^schedule_block_) ( void ) = [ [ ^
   {
      block_( cancel_block_ );
   } copy ] autorelease ];

   __block NSTimer* refresh_timer_ = [ NSTimer scheduledTimerWithTimeInterval: duration_
                                                                       target: schedule_block_
                                                                     selector: @selector( perform )
                                                                     userInfo: nil
                                                                      repeats: YES ];

   __block NSObject* cancel_ptr_ = nil;
   __block JFFScheduler* scheduler_ = self;

   cancel_block_ = [ [ ^
   {
      if ( scheduler_ )
      {
         [ refresh_timer_ invalidate ];
         [ scheduler_.cancelBlocks removeObject: cancel_block_ ];
         scheduler_ = nil;
      }
   } copy ] autorelease ];

   [ self.cancelBlocks addObject: cancel_block_ ];

   return cancel_block_;
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
