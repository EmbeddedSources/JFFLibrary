#import "JNGzipDecoder.h"


@implementation JNGzipDecoder

static const NSUInteger max_buffer_size_ = 4096;

-(NSString*)zipErrorFromCode:(int)error_code_
{
   NSArray* zip_errors_ = [ NSArray arrayWithObjects: 
                             @"Z_VERSION_ERROR"
                           , @"Z_BUF_ERROR"                              
                           , @"Z_MEM_ERROR"                             
                           , @"Z_DATA_ERROR"
                           , @"Z_STREAM_ERROR"                           
                           , @"Z_ERRNO"
                           , nil ];

   NSUInteger error_index_     = error_code_ + abs( Z_VERSION_ERROR );
   NSUInteger max_error_index_ = Z_ERRNO     + abs( Z_VERSION_ERROR );
   
   if ( error_index_ > max_error_index_ )
   {
      return @"Z_UnknownError";
   }

   return [ zip_errors_ objectAtIndex: error_index_ ];
}

-(NSData*)decodeData:( NSData* )encoded_data_
{
   Bytef decoded_buffer_[ 4096 ] = {0};
   uLongf decoded_size_ = max_buffer_size_;
   
   int uncompress_result_ = uncompress( decoded_buffer_    , &decoded_size_        ,
                                        encoded_data_.bytes,  encoded_data_.length );
   
   if ( Z_OK != uncompress_result_ )
   {
      NSLog( @"[!!! WARNING !!!] JNGzipDecoder -- unzip action has failed.\n Zip error code -- %d\n Zip error -- %@"
             , uncompress_result_
             , [ self zipErrorFromCode: uncompress_result_ ] );

      return nil;
   }
   
   NSData* result_ = [ NSData dataWithBytes: decoded_buffer_
                                     length: decoded_size_ ];
   
   return result_;
}

@end
