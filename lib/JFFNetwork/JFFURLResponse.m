#import "JFFURLResponse.h"

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
   NSMutableString* result_ = [ NSMutableString stringWithFormat: @"<<< JFFUrlResponse. HttpStatusCode = %d \n", self.statusCode ] ;
   [ result_ appendFormat: @"Result length = %lld \n", self.expectedContentLength ];
   [ result_ appendString: @"Headers : \n" ];

   [ self.allHeaderFields enumerateKeysAndObjectsUsingBlock: ^(id key_, id obj_, BOOL* stop_)
                                                             {
                                                                [ result_ appendFormat: @"\t%@ = %@ \n", key_, obj_ ];
                                                             } 
   ];

   return result_;
}

@end
