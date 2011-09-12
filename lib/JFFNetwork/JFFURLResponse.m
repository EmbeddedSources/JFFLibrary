#import "JFFURLResponse.h"

#import "JFFUrlResponseLogger.h"

@implementation JFFURLResponse

@synthesize statusCode = _status_code;
@synthesize allHeaderFields = _all_header_fields;

-(void)dealloc
{
   [ _all_header_fields release ];

   [ super dealloc ];
}

-(long long)expectedContentLength
{
   return [ [ _all_header_fields objectForKey: @"Content-Length" ] longLongValue ];
}

#pragma mark -
#pragma mark NSObject
-(NSString*)description
{
   return [ JFFUrlResponseLogger descriptionStringForUrlResponse: self ];
}

@end
