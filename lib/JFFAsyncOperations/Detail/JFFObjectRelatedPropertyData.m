#import "JFFObjectRelatedPropertyData.h"

@implementation JFFObjectRelatedPropertyData

@synthesize delegates = _delegates;
@synthesize asyncLoader = _async_loader;
@synthesize didFinishBlock = _did_finish_block;
@synthesize cancelBlock = _cancel_block;

+(id)extractPropertyData
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(void)dealloc
{
   [ _delegates release ];
   [ _async_loader release ];
   [ _did_finish_block release ];
   [ _cancel_block release ];

   [ super dealloc ];
}

@end