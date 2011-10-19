#import <Foundation/Foundation.h>

@interface JFFDBCompositeKey : NSObject 
{
@private
   NSMutableArray* _keys;
}

+(id)compositeKeyWithKeys:( NSString* )key_, ...;
+(id)compositeKeyWithKey:( JFFDBCompositeKey* )composite_key_ forIndexes:( NSIndexSet* )indexes_;

-(NSString*)toCompositeKey;

@end

