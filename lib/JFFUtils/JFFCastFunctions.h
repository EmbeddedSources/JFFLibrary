#import <Foundation/Foundation.h>


template < class DESTINATION >
DESTINATION* objc_kind_of_cast( id nsObject )
{
   Class destination_class_ = [ DESTINATION class ];
   if ( ![ nsObject isKindOfClass: destination_class_ ] )
   {
      NSLog( @"[!!!ERROR!!!] kind_of_cast class mismatch. Expected : %@. Received : %@", destination_class_, [ nsObject class ]  );
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
      NSLog( @"[!!!ERROR!!!] member_of_cast class mismatch. Expected : %@. Received : %@", destination_class_, [ nsObject class ]  );
      return nil;
   }
   
   return (DESTINATION*)nsObject;
}

// A tiny code duplication is by design


