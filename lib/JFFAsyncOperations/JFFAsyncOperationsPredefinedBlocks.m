#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "JFFCancelAyncOperationBlockHolder.h"

#import <JFFScheduler/JFFScheduler.h>

//JTODO rename to JFFStubCancelAsyncOperationBlock
JFFCancelAsyncOperation JFFEmptyCancelAsyncOperationBlock = ^void( BOOL cancel_ ){ /*do nothing*/ };

JFFAsyncOperation JFFAsyncOperationBlockWithSuccessResult =
^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                         , JFFCancelAsyncOperationHandler cancel_callback_
                         , JFFDidFinishAsyncOperationHandler done_callback_ )
{
   done_callback_( [ NSNull null ], nil );
   return ^void( BOOL cancel_ ){ /*do nothing*/ };
};
