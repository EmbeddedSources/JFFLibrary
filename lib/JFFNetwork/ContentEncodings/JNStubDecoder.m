#import "JNStubDecoder.h"

@implementation JNStubDecoder

-(NSData*)decodeData:( NSData* )encoded_data_
               error:( NSError** )error_
{
   NSAssert( error_, @"[!!! ERROR !!!] : JNStubDecoder -- NULL errors are not acceptible" );
   *error_ = nil;

   //!! dodikk : Just in case
   return [ [ encoded_data_ retain ] autorelease ];
}

@end
