#import "NSString+Format.h"

@implementation NSString ( Format )

+(id)stringWithFormatCheckNill:( NSString* )format_, ... 
{
   if ( [ format_ length ] == 0 )
      return nil;
   
   id eachObject = nil;
   va_list argument_list_;

   va_start(argument_list_, format_ );
   eachObject = va_arg( argument_list_, id);
   
   while ( eachObject )
   {
      if ( ![ eachObject isKindOfClass:[ NSObject class ] ] )
             return nil;
             
      if ( [ [ eachObject description ] length ] == 0 )
         return nil;
      
      eachObject = va_arg( argument_list_, id);
   }
   va_start(argument_list_, format_ );
   return [ [ [ NSString alloc] initWithFormat: format_ arguments: argument_list_ ] autorelease ];
}

-(BOOL)hasSymbols
{
   return ![ self isEqualToString: @"" ];
}

@end
