#import "NSString+UUIDCreation.h"

@implementation NSString (UUIDCreation)

+(NSString*)createUuid
{
   NSString* result_ = nil;
   
   CFUUIDRef uuid_ = CFUUIDCreate( NULL );
   CFStringRef raw_result_ = CFUUIDCreateString( NULL, uuid_ );
   {
      result_ = [ NSString stringWithString: (NSString*)raw_result_ ];
   }
   CFRelease( uuid_ );
   CFRelease( raw_result_ );

   return result_;
}

@end
