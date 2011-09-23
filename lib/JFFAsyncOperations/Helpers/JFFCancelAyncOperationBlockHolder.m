#import "JFFCancelAyncOperationBlockHolder.h"

@implementation JFFCancelAyncOperationBlockHolder

@synthesize cancelBlock = _cancel_block;

-(void)dealloc
{
   [ _cancel_block release ];

   [ super dealloc ];
}

-(void)performCancelBlockOnceWithArgument:( BOOL )cancel_
{
   if ( !self.cancelBlock )
      return;

   JFFCancelAsyncOperation block_ = [ self.cancelBlock copy ];
   self.cancelBlock = nil;
   block_( cancel_ );
   [ block_ release ];
}

-(JFFCancelAsyncOperation)onceCancelBlock
{
   return [ [ ^( BOOL cancel_ )
   {
      [ self performCancelBlockOnceWithArgument: cancel_ ];
   } copy ] autorelease ];
}

@end
