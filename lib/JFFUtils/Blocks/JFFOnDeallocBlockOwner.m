#import "JFFOnDeallocBlockOwner.h"

@implementation JFFOnDeallocBlockOwner

@synthesize block = _block;

-(id)initWithBlock:( JFFSimpleBlock )block_
{
   self = [ super init ];

   NSAssert( block_, @"should not be nil" );
   _block = block_;

   return self;
}

-(void)dealloc
{
   if ( self.block )
   {
      self.block();
      self.block = nil;//JTODO may be bug
   }
}

@end
