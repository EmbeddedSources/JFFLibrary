#import <Foundation/Foundation.h>

@interface JFFResultContext : NSObject
{
@private
   id _result;
   NSError* _error;
}

@property ( nonatomic, retain ) id result;
@property ( nonatomic, retain ) NSError* error;

@end
