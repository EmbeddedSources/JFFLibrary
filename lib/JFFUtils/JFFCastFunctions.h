#import <Foundation/Foundation.h>
#import <objc/Runtime.h>


#pragma mark -
#pragma mark NSObject casts
template < class DESTINATION >
DESTINATION* objc_kind_of_cast( id nsObject )
{
   Class destination_class_ = [ DESTINATION class ];
   if ( ![ nsObject isKindOfClass: destination_class_ ] )
   {
      NSLog( @"[!!!ERROR!!!] objc_kind_of_cast class mismatch. Expected : %@. Received : %@", destination_class_, [ nsObject class ]  );
      return nil;
   }
   
   return (DESTINATION*)nsObject;
}


template < class DESTINATION >
DESTINATION* objc_member_of_cast( id nsObject )
{
   Class destination_class_ = [ DESTINATION class ];
   if ( ![ nsObject isMemberOfClass: destination_class_ ] )
   {
      NSLog( @"[!!!ERROR!!!] objc_member_of_cast class mismatch. Expected : %@. Received : %@", destination_class_, [ nsObject class ]  );
      return nil;
   }
   
   return (DESTINATION*)nsObject;
}


#pragma mark -
#pragma mark dynamic cast
BOOL objc_srcIsSuperclassOfDest( Class src, Class dest )
{
   if ( dest == src ) 
   {
      return YES;
   }
   
   Class super_dest_ = class_getSuperclass();
   if ( Nil == super_dest_ )
   {
      return NO;
   }

   return objc_srcIsSuperclassOfDest( src, super_dest_ );
}

template < class DESTINATION >
DESTINATION* objc_dynamic_cast( id nsObject )
{
   BOOL is_same_hierarchy_ = 
      objc_srcIsSuperclassOfDest( [ nsObject class ], [ DESTINATION class ] ) ||
      objc_srcIsSuperclassOfDest( [ DESTINATION class ], [ nsObject class ] ) ;
   
   if ( !is_same_hierarchy_ )
   {
      NSLog( @"[!!!ERROR!!!] objc_dynamic_cast class mismatch. Expected : %@. Received : %@", [ DESTINATION class ], [ nsObject class ]  );
      return nil;
   }
   
   return (DESTINATION*)nsObject;
}

// A tiny code duplication is by design


