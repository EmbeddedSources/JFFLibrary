#import "JFFResultContext.h"

@implementation JFFResultContext

@synthesize result;
@synthesize error;

-(void)dealloc
{
   [ result release ];
   [ error release ];

   [ super dealloc ];
}

@end
