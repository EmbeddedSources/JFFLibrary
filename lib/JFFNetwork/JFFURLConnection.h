#import <Foundation/Foundation.h>

@class JFFURLResponse;

typedef void (^ESDidReceiveResponseHandler)( JFFURLResponse* response_ );
typedef void (^ESDidFinishLoadingHandler)( NSError* error_ );
typedef void (^ESDidReceiveDataHandler)( NSData* data_ );

//ESURLConnection can not be reused after cancel or finish
//all callbacks cleared after cancel or finish action
@interface JFFURLConnection : NSObject
{
@private
   NSData* _post_data;
   NSDictionary* _headers;

   BOOL _response_handled;
   CFReadStreamRef _read_stream;
   NSURL* _url;

   ESDidReceiveResponseHandler _did_receive_response_block;
   ESDidReceiveDataHandler _did_receive_data_block;
   ESDidFinishLoadingHandler _did_finish_loading_block;
}

//callbacks cleared after finish of loading
@property ( nonatomic, copy ) ESDidReceiveResponseHandler didReceiveResponseBlock;
@property ( nonatomic, copy ) ESDidReceiveDataHandler didReceiveDataBlock;
@property ( nonatomic, copy ) ESDidFinishLoadingHandler didFinishLoadingBlock;

+(id)connectionWithURL:( NSURL* )url_
              postData:( NSData* )data_
           contentType:( NSString* )content_type_;

+(id)connectionWithURL:( NSURL* )url_
              postData:( NSData* )data_
               headers:( NSDictionary* )headers_;

-(void)start;
-(void)cancel;

@end
