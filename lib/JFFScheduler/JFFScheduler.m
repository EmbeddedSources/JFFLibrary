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

-(JFFCancelScheduledBlock)addBlock:( JFFScheduledBlock )block_
                          duration:( NSTimeInterval )duration_
{
   JFFSimpleBlockHolder* cancel_block_holder_ = [ [ JFFSimpleBlockHolder new ] autorelease ];

   block_ = [ [ block_ copy ] autorelease ];
   void (^schedule_block_) ( void ) = [ [ ^
   {
      block_( cancel_block_holder_.simpleBlock );
   } copy ] autorelease ];

   __block NSTimer* timer_ = [ NSTimer scheduledTimerWithTimeInterval: duration_
                                                               target: schedule_block_
                                                             selector: @selector( performBlock )
                                                             userInfo: nil
                                                              repeats: YES ];

   __block NSObject* cancel_ptr_ = nil;
   __block JFFScheduler* scheduler_ = self;

   cancel_block_holder_.simpleBlock = ^
   {
      if ( scheduler_ )
      {
         [ timer_ invalidate ];
         [ scheduler_.cancelBlocks removeObject: cancel_ptr_ ];
         scheduler_ = nil;
      }
   };

   cancel_ptr_ = (id)cancel_block_holder_.simpleBlock;
   [ self.cancelBlocks addObject: cancel_ptr_ ];

   return cancel_block_holder_.simpleBlock;
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
