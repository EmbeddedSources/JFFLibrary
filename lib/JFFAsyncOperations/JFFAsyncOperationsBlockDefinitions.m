#import "JFFAsyncOperationsBlockDefinitions.h"

JFFCancelAsyncOperation JFFEmptyCancelAsyncOperationBlock = ^void( BOOL cancel_ ){ /*do nothing*/ };

JFFCancelAsyncOperation JFFAsyncOperationBlockWithSuccessResult =
   (JFFCancelAsyncOperation)^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                     , JFFCancelAsyncOperationHandler cancel_callback_
                                                     , JFFDidFinishAsyncOperationHandler done_callback_ )
{
   done_callback_( [ NSNull null ], nil );
   return ^void( BOOL cancel_ ){ /*do nothing*/ };
};
