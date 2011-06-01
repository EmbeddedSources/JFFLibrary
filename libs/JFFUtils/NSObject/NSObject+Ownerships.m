#import "NSObject+Ownerships.h"

#include <objc/runtime.h>

static char ownerships_key_;

@implementation NSObject (Ownerships)

-(NSMutableArray*)ownerships
{
   NSMutableArray* ownerships_ = objc_getAssociatedObject( self, &ownerships_key_ );
   if ( !ownerships_ )
   {
      ownerships_ = [ [ NSMutableArray alloc ] init ];
      objc_setAssociatedObject( self, &ownerships_key_, ownerships_, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
      [ ownerships_ release ];
   }
   return ownerships_;
}

@end
