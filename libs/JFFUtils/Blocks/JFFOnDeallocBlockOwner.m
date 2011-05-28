#import "JFFOnDeallocBlockOwner.h"

@implementation JFFOnDeallocBlockOwner

@synthesize block = _block;

-(id)initWithBlock:( JFFSimpleBlock )block_
{
   self = [ super init ];

   NSAssert( block_, @"should not be nil" );
   self.block = block_;

   return self;
}

-(void)dealloc
{
   _block();
   [ _block release ];

   [ super dealloc ];
}

@end
