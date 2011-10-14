#import "NSString+Trimm.h"

@implementation NSString (Trimm)

-(NSString*)stringByTrimmingWhitespaces
{
   return [ self stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ] ];
}

-(NSString*)stringByTrimmingPunctuation
{
   return [ self stringByTrimmingCharactersInSet: [ NSCharacterSet punctuationCharacterSet ] ];
}

@end
