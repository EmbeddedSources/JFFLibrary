#import "JFFCastFunctions.hpp"

#import <objc/runtime.h>

BOOL class_srcIsSuperclassOfDest( Class src, Class dest )
{
   if ( dest == src ) 
   {
      return YES;
   }

   Class super_dest_ = class_getSuperclass( dest );
   if ( Nil == super_dest_ )
   {
      return NO;
   }
   
   return class_srcIsSuperclassOfDest( src, super_dest_ );
}
