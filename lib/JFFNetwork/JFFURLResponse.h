#import <Foundation/Foundation.h>

@interface JFFURLResponse : NSObject

@property ( nonatomic, assign ) NSInteger statusCode;
@property ( nonatomic, retain ) NSDictionary* allHeaderFields;

@end
