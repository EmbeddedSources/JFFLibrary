#import "JFFContextLoaders.h"

@implementation JFFContextLoaders

@synthesize activeLoadersNumber = _active_loaders_number;
@synthesize pendingLoaders = _pending_loaders;
@synthesize name = _name;

-(void)dealloc
{
   [ _pending_loaders release ];
   [ _name release ];

   [ super dealloc ];
}

-(NSMutableArray*)pendingLoaders
{
   if ( !_pending_loaders )
   {
      _pending_loaders = [ NSMutableArray new ];
   }
   return _pending_loaders;
}

@end
