#import "JFFCancelAyncOperationBlockHolder.h"

@implementation JFFCancelAyncOperationBlockHolder

@synthesize simpleBlock = _simple_block;

-(void)dealloc
{
   [ _simple_block release ];

   [ super dealloc ];
}

+(id)simpleBlockHolder
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(void)performCancelBlockOnceWithArgument:( BOOL )cancel_
{
   if ( !self.simpleBlock )
      return;

   JFFCancelAsyncOperation block_ = [ self.simpleBlock copy ];
   self.simpleBlock = nil;
   block_( cancel_ );
   [ block_ release ];
}

@end
