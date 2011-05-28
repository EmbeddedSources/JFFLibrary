#include <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

@class NSError;

typedef void (^JFFAsyncOperationProgressHandler)( id progress_info_ );

typedef id (^JFFSyncOperation)( NSError** error_ );
typedef id (^JFFSyncOperationWithProgress)( NSError** error_
                                           , JFFAsyncOperationProgressHandler progress_callback_ );

typedef void (^JFFDidFinishAsyncOperationHandler)( id result_, NSError* error_ );

typedef JFFSimpleBlock JFFCancelAsyncOpration;
typedef JFFSimpleBlock JFFCancelHandler;

//@@ progress_callback_ -- nil | valid block
//@@ cancel_callback_   -- nil | valid block
//@@ done_callback_     -- nil | valid block
typedef JFFCancelAsyncOpration (^JFFAsyncOperation)( JFFAsyncOperationProgressHandler progress_callback_
                                                    , JFFCancelHandler cancel_callback_
                                                    , JFFDidFinishAsyncOperationHandler done_callback_ );

typedef void (^JFFDidFinishAsyncOperationHook)( id result_
                                               , NSError* error_
                                               , JFFDidFinishAsyncOperationHandler done_callback_ );
