#import "NSDictionary+XQueryComponents.h"

#import "NSString+XQueryComponents.h"

@implementation NSDictionary (XQueryComponents)

-(NSString*)stringFromQueryComponents
{
   NSString* result_;
   for ( __strong NSString* key_ in [ self allKeys ] )
   {
      key_ = [ key_ stringByEncodingURLFormat ];
      NSArray* all_values_ = [ self objectForKey: key_ ];
      if ( [ all_values_ isKindOfClass: [ NSArray class ] ] )
      {
         for ( __strong NSString* value_ in all_values_ )
         {
            value_ = [ [ value_ description ] stringByEncodingURLFormat ];
            if( !result_ )
            {
               result_ = [ NSString stringWithFormat: @"%@=%@", key_, value_ ];
            }
            else 
            {
               result_ = [ result_ stringByAppendingFormat: @"&%@=%@", key_, value_ ];
            }
         }
      }
      else
      {
         NSString* value_ = [ [ all_values_ description ] stringByEncodingURLFormat ];
         if( !result_ )
         {
            result_ = [ NSString stringWithFormat:@"%@=%@", key_, value_ ];
         }
         else 
         {
            result_ = [ result_ stringByAppendingFormat:@"&%@=%@", key_, value_ ];
         }
      }
   }
   return result_;
}

@end
