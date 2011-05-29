#import <Foundation/Foundation.h>

@interface JFFPropertyPath : NSObject
{
@private
   NSString* _name;
   id< NSCopying, NSObject > _key;
}

@property ( nonatomic, retain, readonly ) NSString* name;
@property ( nonatomic, retain, readonly ) id< NSCopying, NSObject > key;

+(id)propertyPathWithName:( NSString* )name_
                      key:( id< NSCopying, NSObject > )key_;

@end
