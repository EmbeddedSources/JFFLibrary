#import "JNGzipDecoder.h"

#import "JNGzipErrorsLogger.h"
#import "JNGzipCustomErrors.h"
#import "JNConstants.h"

NSString* GZIP_ERROR_DOMAIN = @"gzip.error";

@implementation JNGzipDecoder

//http://www.cocoadev.com/index.pl?NSDataCategory
-(NSData*)decodeData:( NSData*   )encoded_data_
               error:( NSError** )error_
{
   NSAssert( error_, @"[!!! ERROR !!!] : JNGzipDecoder -- NULL errors are not acceptible" );
   *error_ = nil;

   NSUInteger encoded_data_length_ = [ encoded_data_ length ];
   if ( 0 == [ encoded_data_ length ] ) 
   {
      return encoded_data_;
   }

   unsigned full_length_ = encoded_data_length_;
   unsigned half_length_ = encoded_data_length_ / 2;

   NSMutableData* decompressed_ = [ NSMutableData dataWithLength: full_length_ + half_length_ ];
   BOOL done_   = NO;
   int  status_ = 0 ;

   z_stream strm  = {0};
   strm.next_in   = (Bytef *)[ encoded_data_ bytes ];
   strm.avail_in  = [ encoded_data_ length ];
   strm.total_out = 0;
   strm.zalloc    = Z_NULL;
   strm.zfree     = Z_NULL;

   //!! dodikk -- WTF Magic
   if ( inflateInit2( &strm, (15 + 32) ) != Z_OK ) 
   {
      NSLog( @"[!!! ERROR !!!] : JNGzipDecoder -- inflateInit2 failed" );

      *error_ = [ NSError errorWithDomain: GZIP_ERROR_DOMAIN
                                     code: JNGzipInitFailed
                                 userInfo: nil ];
      return nil;
   }
   while (!done_)
   {
      // Make sure we have enough room and reset the lengths.
      if ( strm.total_out >= [ decompressed_ length ] )
      {
         [ decompressed_ increaseLengthBy: half_length_ ];
      }
      strm.next_out  = [ decompressed_ mutableBytes ] + strm.total_out;
      strm.avail_out = [ decompressed_ length       ] - strm.total_out;

      // Inflate another chunk.
      status_ = inflate( &strm, Z_SYNC_FLUSH );
      if ( status_ == Z_STREAM_END ) 
      {
         done_ = YES;
      }
      else if ( status_ != Z_OK )
      {
         break;
      }
	}
	if ( inflateEnd( &strm ) != Z_OK ) 
   {
      NSLog( @"[!!! WARNING !!!] JNZipDecoder -- unexpected EOF" );
      
      *error_ = [ NSError errorWithDomain: GZIP_ERROR_DOMAIN
                                     code: JNGzipUnexpectedEOF
                                 userInfo: nil ];

      return nil;
   }
	
	// Set real length.
	if ( done_ )
	{
		[ decompressed_ setLength: strm.total_out ];
		return [ NSData dataWithData: decompressed_ ];
	}
	else 
   {
      NSLog( @"[!!! WARNING !!!] JNZipDecoder -- unzip action has failed.\n Zip error code -- %d\n Zip error -- %@"
            , status_
            , [ JNGzipErrorsLogger zipErrorFromCode: status_ ] );
      
      *error_ = [ NSError errorWithDomain: GZIP_ERROR_DOMAIN
                                     code: status_
                                 userInfo: nil ];
      
      return nil;
   }

   return nil;
}

@end
