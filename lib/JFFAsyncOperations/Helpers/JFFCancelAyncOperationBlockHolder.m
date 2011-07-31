#import "JFFCancelAyncOperationBlockHolder.h"

@implementation JFFCancelAyncOperationBlockHolder

@synthesize cancelBlock = _cancel_block;

-(void)dealloc
{
   [ _cancel_block release ];

   [ super dealloc ];
}

+(id)cancelAyncOperationBlockHolder
{
   return [ [ self new ] autorelease ];
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

@end
