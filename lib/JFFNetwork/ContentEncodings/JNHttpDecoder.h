#import <Foundation/Foundation.h>


@protocol JNHttpDecoder < NSObject >

-(NSData*)decodeData:( NSData* )encoded_data_;

@end
