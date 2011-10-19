#import <Foundation/Foundation.h>

@class JFFSQLiteDB;

@interface JFFBaseDB : NSObject
{
@private
   JFFSQLiteDB* _db;
}

@property ( nonatomic, strong, readonly ) JFFSQLiteDB* db;
@property ( nonatomic, strong, readonly ) NSString* name;

-(id)initWithDBName:( NSString* )db_name_
          cacheName:( NSString* )cache_name_;

-(NSData*)dataForKey:( id )key_;
-(NSData*)dataForKey:( id )key_ lastUpdateTime:( NSDate** )date_;

-(void)setData:( NSData* )data_ forKey:( id )key_;

-(void)removeRecordsToUpdateDate:( NSDate* )date_;
-(void)removeRecordsToAccessDate:( NSDate* )date_;

-(void)removeRecordsForKey:( id )key_;

-(void)removeAllRecords;

@end
