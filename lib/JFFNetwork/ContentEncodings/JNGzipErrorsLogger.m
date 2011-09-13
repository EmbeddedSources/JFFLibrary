#import "JNGzipErrorsLogger.h"

@implementation JNGzipErrorsLogger

+(NSString*)zipErrorFromCode:(int)error_code_
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


@end
