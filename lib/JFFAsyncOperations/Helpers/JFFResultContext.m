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

@end
