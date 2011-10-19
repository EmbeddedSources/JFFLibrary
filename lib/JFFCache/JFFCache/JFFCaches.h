#import <Foundation/Foundation.h>

@protocol JFFCacheDB;

@interface JFFCaches : NSObject
{
@private
   NSMutableDictionary* _mutable_cache_db_by_name;
}

@property ( nonatomic, strong, readonly ) NSDictionary* cacheDbByName;

+(JFFCaches*)sharedCaches;

-(id< JFFCacheDB >)cacheByName:( NSString* )name_;

-(id< JFFCacheDB >)thumbnailDB;

@end
