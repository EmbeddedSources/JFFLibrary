#import "JFFAlertButton.h"

@implementation JFFAlertButton

@synthesize title = _title;
@synthesize action = _action;

-(void)dealloc
{
   [ _title release ];
   [ _action release ];

   [ super dealloc ];
}

-(id)initButton:( NSString* )title_ action:( JFFSimpleBlock )action_
{
   self = [ super init ];

   if ( self )
   {
      self.title = title_;
      self.action = action_;
   }

   return self;
}

+(id)alertButton:( NSString* )title_ action:( JFFSimpleBlock )action_
{
   return [ [ [ self alloc ] initButton: title_ action: action_ ] autorelease ];
}

@end
