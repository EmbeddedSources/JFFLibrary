#import "JFFPropertyPath.h"

@interface JFFPropertyPath ()

@property ( nonatomic, retain ) NSString* name;
@property ( nonatomic, retain ) id< NSCopying, NSObject > key;

@end

@implementation JFFPropertyPath

@synthesize name = _name;
@synthesize key = _key;

-(id)initWithName:( NSString* )name_
              key:( id< NSCopying, NSObject > )key_
{
   self = [ super init ];

   if ( self )
   {
      self.name = name_;
      self.key = key_;
   }

   return self;
}

+(id)propertyPathWithName:( NSString* )name_
                      key:( id< NSCopying, NSObject > )key_
{
   return [ [ [ self alloc ] initWithName: name_ key: key_ ] autorelease ];
}

-(void)dealloc
{
   [ _name release ];
   [ _key release ];

   [ super dealloc ];
}

-(NSString*)description
{
   return [ NSString stringWithFormat: @"<JFFPropertyPath name: %@ key: %@>", self.name, self.key ];
}

@end
