#import "NSObject+PerformBlock.h"

#import "JFFBlocksDefinitions.h"

@implementation NSObject (PerformBlock)

-(void)performBlock
{
   void* self_ = self;
   JFFSimpleBlock block_ = (JFFSimpleBlock)self_;
   block_();
}

-(void)performBlockOnMainThread
{
   self = [ [ self copy ] autorelease ];
   [ self performSelectorOnMainThread: @selector( performBlock ) withObject: nil waitUntilDone: NO ];
}

-(void)performBlockAfterDelay:( NSTimeInterval )delay_
{
   self = [ [ self copy ] autorelease ];
   [ self performSelector: @selector( performBlock ) withObject: nil afterDelay: delay_ ];
}

@end
