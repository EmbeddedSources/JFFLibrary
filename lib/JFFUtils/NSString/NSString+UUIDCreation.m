#import "NSString+UUIDCreation.h"

@implementation NSString (UUIDCreation)

+(NSString*)createUuid
{
   CFUUIDRef uuid_ = CFUUIDCreate( NULL );
   NSString* result_ = [ (NSString*)CFUUIDCreateString( NULL, uuid_ ) retain ];
   CFRelease( uuid_ );

   return [ result_ autorelease ];
}

@end
