#import "JFFNetworkBlocksFunctions.h"

#import "JFFURLConnection.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFResultContext.h>

static const NSTimeInterval timeout_ = 60.0;

JFFAsyncOperation chunkedURLResponseLoader( NSURL* url_
                                           , NSData* post_data_
                                           , NSDictionary* headers_ )
{
   return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                       , JFFCancelAsyncOperationHandler cancel_callback_
                                       , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFURLConnection* connection_ = [ JFFURLConnection connectionWithURL: url_
                                                                  postData: post_data_
                                                                   headers: headers_ ];

      progress_callback_ = [ [ progress_callback_ copy ] autorelease ];
      connection_.didReceiveDataBlock = ^void( NSData* data_ )
      {
         if ( progress_callback_ )
            progress_callback_( data_ );
      };

      JFFResultContext* result_context_ = [ JFFResultContext resultContext ];

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      connection_.didFinishLoadingBlock = ^void( NSError* error_ )
      {
         if ( done_callback_ )
            done_callback_( error_ ? nil : result_context_.result, error_ );
      };

      connection_.didReceiveResponseBlock = ^void( JFFURLResponse* response_ )
      {
         result_context_.result = response_;
      };

      JFFCancelAyncOperationBlockHolder* cancel_callback_block_holder_ = [ JFFCancelAyncOperationBlockHolder cancelAyncOperationBlockHolder ];
      cancel_callback_block_holder_.cancelBlock = cancel_callback_;

      [ connection_ start ];

      return [ [ ^void( BOOL canceled_ )
      {
         if ( canceled_ )
            [ connection_ cancel ];

         [ cancel_callback_block_holder_ performCancelBlockOnceWithArgument: canceled_ ];
      } copy ] autorelease ];
   } copy ] autorelease ];
}

JFFAsyncOperation dataURLResponseLoader( NSURL* url_
                                        , NSData* post_data_
                                        , NSDictionary* headers_ )
{
   return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                       , JFFCancelAsyncOperationHandler cancel_callback_
                                       , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFAsyncOperation loader_ = chunkedURLResponseLoader( url_, post_data_, headers_ );

      NSMutableData* response_data_ = [ NSMutableData data ];
      JFFAsyncOperationProgressHandler data_progress_callback_ = ^void( id progress_info_ )
      {
         [ response_data_ appendData: progress_info_ ];
      };

      if ( done_callback_ )
      {
         done_callback_ = [ [ done_callback_ copy ] autorelease ];
         done_callback_ = ^void( id result_, NSError* error_ )
         {
            done_callback_( result_ ? response_data_ : nil, error_ );
         };
      }

      return loader_( data_progress_callback_, cancel_callback_, done_callback_ );
   } copy ] autorelease ];
}
