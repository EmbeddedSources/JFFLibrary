#import "JNStubDecoder.h"


@implementation JNStubDecoder

-(NSData*)decodeData:( NSData* )encoded_data_
{
   return [ [ encoded_data_ retain ] autorelease ];
}

@end
