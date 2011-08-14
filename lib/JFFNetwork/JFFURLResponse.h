#import <Foundation/Foundation.h>

@interface JFFURLResponse : NSObject

@property ( nonatomic, assign ) NSInteger statusCode;
@property ( nonatomic, retain ) NSDictionary* allHeaderFields;

@property ( nonatomic, assign, readonly ) long long expectedContentLength;

@end
