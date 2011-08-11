#import "JFFURLResponse.h"

@implementation JFFURLResponse

@synthesize statusCode = _status_code;
@synthesize allHeaderFields = _all_header_fields;

-(void)dealloc
{
   [ _all_header_fields release ];

   [ super dealloc ];
}

@end
