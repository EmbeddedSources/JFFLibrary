#import "JFFResultContext.h"

@implementation JFFResultContext

@synthesize result = _result;
@synthesize error = _error;

-(void)dealloc
{
   [ _result release ];
   [ _error release ];

   [ super dealloc ];
}

+(id)resultContext
{
   return [ [ [ self alloc ] init ] autorelease ];
}

@end
