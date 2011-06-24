#import "NSObject+RuntimeExtensions.h"

#include <objc/runtime.h>

@implementation NSObject (RuntimeExtensions)

+(void)addMethodIfNeedWithSelector:( SEL )selector_
                           toClass:( Class )class_
{
   if ( ![ class_ instancesRespondToSelector: selector_ ] )
   {
      Method prototype_method_ = class_getInstanceMethod( self, selector_ );
      const char* type_encoding_ = method_getTypeEncoding( prototype_method_ );
      BOOL result_ = class_addMethod( class_
                                     , selector_
                                     , method_getImplementation( prototype_method_ )
                                     , type_encoding_ );
      NSAssert( result_, @"method should be added" );
   }
}

@end
