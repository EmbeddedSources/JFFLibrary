#import "example.h"

#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>

@interface Element : NSObject

@property ( nonatomic, retain, readonly ) NSArray* subElements;

@end

@implementation Element

@synthesize subElements = _sub_elements;

-(void)dealloc
{
   [ _sub_elements release ];

   [ super dealloc ];
}

@end

NSArray* allSubElements( NSArray* elements_ )
{
   return [ elements_ flatten: ^( id element_ )
   {
      return [ element_ subElements ];
   } ];
}

@implementation example

-(void)example
{
   //[ self stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ] ]
//   NSArray* strings_ = [ NSArray arrayWithObjects: @" a ", @" b ", @" c ", nil ];
//   allSubElements( strings_ );
   //trimm all strings
}

@end
