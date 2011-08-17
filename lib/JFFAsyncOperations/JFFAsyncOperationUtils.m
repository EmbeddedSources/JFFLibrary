#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationProgressBlockHolder.h"

#import <JFFUtils/NSObject/NSObject+PerformBlock.h>

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation load_data_block_ )
{
   load_data_block_ = [ [ load_data_block_ copy ] autorelease ];
   return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler pregress_info_callback_
                                       , JFFCancelAsyncOperationHandler cancel_callback_
                                       , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFBlockOperation* operation_ = [ JFFBlockOperation performOperationWithLoadDataBlock: load_data_block_
                                                                             didCancelBlock: cancel_callback_
                                                                           didLoadDataBlock: done_callback_ ];
      return [ [ ^void( BOOL cancel_ )
      {
         [ operation_ cancel: cancel_ ];
      } copy ] autorelease ];
   } copy ] autorelease ];
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progress_load_data_block_ )
{
   progress_load_data_block_ = [ [ progress_load_data_block_ copy ] autorelease ];
   return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler pregress_info_callback_
                                       , JFFCancelAsyncOperationHandler cancel_callback_
                                       , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFAsyncOperationProgressBlockHolder* holder_ = [ JFFAsyncOperationProgressBlockHolder asyncOperationProgressBlockHolder ];
      holder_.progressBlock = ^void( id progress_info_ )
      {
         [ ^void( void )
         {
            pregress_info_callback_( progress_info_ );
         } performBlockOnMainThread ];
      };

      JFFSyncOperation load_data_block_ = ^id( NSError** error_ )
      {
         JFFAsyncOperationProgressHandler thread_progress_load_data_block_ = ^void( id progress_info_ )
         {
            if ( holder_.progressBlock )
               holder_.progressBlock( progress_info_ );
         };
         return progress_load_data_block_( error_, thread_progress_load_data_block_ );
      };
      JFFBlockOperation* operation_ = [ JFFBlockOperation performOperationWithLoadDataBlock: load_data_block_
                                                                             didCancelBlock: cancel_callback_
                                                                           didLoadDataBlock: done_callback_ ];
      return [ [ ^void( BOOL cancel_ )
      {
         holder_.progressBlock = nil;
         [ operation_ cancel: cancel_ ];
      } copy ] autorelease ];
   } copy ] autorelease ];
}
