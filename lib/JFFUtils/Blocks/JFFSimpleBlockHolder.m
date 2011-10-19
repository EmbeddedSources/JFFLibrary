#import "JFFSimpleBlockHolder.h"

@implementation JFFSimpleBlockHolder

@synthesize simpleBlock = _simple_block;

-(void)dealloc
{
   [ _simple_block release ];

   [ super dealloc ];
}

-(void)performBlockOnce
{
   if ( !self.simpleBlock )
      return;

   JFFSimpleBlock block_ = [ self.simpleBlock copy ];
   self.simpleBlock = nil;
   block_();
   [ block_ release ];
}

-(JFFSimpleBlock)onceSimpleBlock
{
   return [ [ ^void( void )
   {
      [ self performBlockOnce ];
   } copy ] autorelease ];
}

@end
