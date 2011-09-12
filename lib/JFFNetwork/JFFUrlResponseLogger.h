#import <Foundation/Foundation.h>


@interface JFFUrlResponseLogger : NSObject 

+(NSString*)descriptionStringForUrlResponse:(id)url_response_;
+(NSString*)dumpHttpHeaderFields:(NSDictionary*)all_header_fields_;


@end
