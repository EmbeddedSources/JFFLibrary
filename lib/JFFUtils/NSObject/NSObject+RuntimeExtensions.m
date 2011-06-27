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

+(void)hookMethodForClass:( Class )class_
             withSelector:( SEL )target_selector_
  prototypeMethodSelector:( SEL )prototype_selector_
       hookMethodSelector:( SEL )hook_selector_
{
   Method target_method_ = class_getInstanceMethod( class_, target_selector_ );
   Method prototype_method_ = class_getInstanceMethod( [ self class ], prototype_selector_ );
   const char* type_encoding_ = method_getTypeEncoding( prototype_method_ );
   BOOL method_added_ = class_addMethod( class_
                                        , hook_selector_
                                        , method_getImplementation( prototype_method_ )
                                        , type_encoding_ );
   NSAssert( method_added_, @"should be added" );
   Method hook_method_ = class_getInstanceMethod( class_, hook_selector_ );

   method_exchangeImplementations( target_method_, hook_method_ );
}

@end
