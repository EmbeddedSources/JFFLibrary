#import "JFFDBInfo.h"

static JFFDBInfo* shared_info_ = nil;

static NSString* const time_to_live_in_hours_ = @"timeToLiveInHours";

@interface JFFDBInfo ()

@property ( nonatomic, strong ) NSDictionary* dbInfo;

@end

@implementation JFFDBInfo

@synthesize dbInfo = _db_info;

-(id)initWithInfoPath:( NSString* )info_path_
{
   self = [ super init ];

   if ( self )
   {
      self.dbInfo = [ NSDictionary dictionaryWithContentsOfFile: info_path_ ];
   }

   return self;
}

+(JFFDBInfo*)sharedDBInfo
{
   if ( !shared_info_ )
   {
      NSString* default_path_ = [ [ NSBundle mainBundle ] pathForResource: @"DBInfo" ofType: @"plist" ];
      shared_info_ = [ [ self alloc ] initWithInfoPath: default_path_ ];
   }

   return shared_info_;
}

+(void)setSharedDBInfo:( JFFDBInfo* )db_info_
{
   shared_info_ = db_info_;
}


+(NSString*)currentDBInfoFilePath
{
   return [ NSString documentsPathByAppendingPathComponent: @"JFFCurrentDBInfo.data" ];
}

-(NSDictionary*)currentDbInfo
{
   if ( !_current_db_info )
   {
      _current_db_info = [ [ NSDictionary alloc ] initWithContentsOfFile: [ [ self class ] currentDBInfoFilePath ] ];
   }

   return _current_db_info;
}

-(void)setCurrentDbInfo:( NSDictionary* )current_db_info_
{
   if ( _current_db_info == current_db_info_ )
      return;

   _current_db_info = current_db_info_;

   [ _current_db_info writeToFile: [ [ self class ] currentDBInfoFilePath ] atomically: YES ];
}

@end

@implementation NSDictionary (DBInfo)

-(NSString*)fileNameForDBWithName:( NSString* )name_
{
   return [ [ self objectForKey: name_ ] objectForKey: @"fileName" ];
}

-(NSTimeInterval)timeToLiveForDBWithName:( NSString* )name_
{
   NSTimeInterval hours_ = [ [ [ self objectForKey: name_ ] objectForKey: time_to_live_in_hours_ ] doubleValue ];
   return hours_ * 3600.;
}

-(NSTimeInterval)autoRemoveByLastAccessDateForDBWithName:( NSString* )name_
{
   NSNumber* number_ = [ [ self objectForKey: name_ ] objectForKey: @"autoRemoveByLastAccessDateInHours" ];
   return number_ ? [ number_ doubleValue ] * 3600. : 0.;
}

-(NSUInteger)versionForDBWithName:( NSString* )name_
{
   return [ [ [ self objectForKey: name_ ] objectForKey: @"version" ] intValue ];
}

-(BOOL)hasExpirationDateDBWithName:( NSString* )name_
{
   return [ [ self objectForKey: name_ ] objectForKey: time_to_live_in_hours_ ] != nil;
}

@end
