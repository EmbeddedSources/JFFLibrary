#ifndef ES_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
#define ES_NETWORK_BLOCKS_FUNCTIONS_INCLUDED

#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

@class NSURL, NSData, NSString;


JFFAsyncOperation genericChunkedURLResponseLoader(
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_
   , BOOL use_live_connection_ );

JFFAsyncOperation genericDataURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ 
   , BOOL use_live_connection_);


// Backward compatibility versions
JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ );

JFFAsyncOperation dataURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ );

JFFAsyncOperation liveChunkedURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ );

JFFAsyncOperation liveDataURLResponseLoader(
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ );

#endif //ES_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
