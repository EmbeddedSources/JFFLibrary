#import <Foundation/Foundation.h>

@class NSError;

typedef void (^JFFAsyncOperationProgressHandler)( id progress_info_ );

//Synchronous block which can take a lot of time
typedef id (^JFFSyncOperation)( NSError** error_ );

//This block should call progress_callback_ block only from own thread
typedef id (^JFFSyncOperationWithProgress)( NSError** error_
                                           , JFFAsyncOperationProgressHandler progress_callback_ );

typedef void (^JFFDidFinishAsyncOperationHandler)( id result_, NSError* error_ );

typedef void (^JFFCancelAsyncOperation)( BOOL unsubscribe_only_if_no_ );

typedef JFFCancelAsyncOperation JFFCancelAsyncOperationHandler;

//@@ progress_callback_ -- nil | valid block
//@@ cancel_callback_   -- nil | valid block
//@@ done_callback_     -- nil | valid block
typedef JFFCancelAsyncOperation (^JFFAsyncOperation)( JFFAsyncOperationProgressHandler progress_callback_
                                                     , JFFCancelAsyncOperationHandler cancel_callback_
                                                     , JFFDidFinishAsyncOperationHandler done_callback_ );

typedef void (^JFFDidFinishAsyncOperationHook)( id result_
                                               , NSError* error_
                                               , JFFDidFinishAsyncOperationHandler done_callback_ );
