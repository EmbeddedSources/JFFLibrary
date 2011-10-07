#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation load_data_block_ )
{
   load_data_block_ = [ [ load_data_block_ copy ] autorelease ];
   JFFSyncOperationWithProgress progress_load_data_block_ = ^id( NSError** error_
                                                                , JFFAsyncOperationProgressHandler progress_callback_ )
   {
      return load_data_block_( error_ );
   };

   return asyncOperationWithSyncOperationWithProgressBlock( progress_load_data_block_ );
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progress_load_data_block_ )
{
   progress_load_data_block_ = [ [ progress_load_data_block_ copy ] autorelease ];
   return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler pregress_info_callback_
                                       , JFFCancelAsyncOperationHandler cancel_callback_
                                       , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      dispatch_queue_t current_queue_ = dispatch_get_current_queue();
      dispatch_retain( current_queue_ );

      JFFAsyncOperationProgressBlockHolder* pregress_holder_ = nil;
      if ( pregress_info_callback_ )
      {
         pregress_holder_ = [ [ JFFAsyncOperationProgressBlockHolder new ] autorelease ];
         pregress_info_callback_ = [ [ pregress_info_callback_ copy ] autorelease ];
         pregress_holder_.progressBlock = ^void( id progress_info_ )
         {
            dispatch_async( current_queue_,
                           ^void( void )
                           {
                              pregress_info_callback_( progress_info_ );
                           } );
         };
      }

      JFFSyncOperation load_data_block_ = ^id( NSError** error_ )
      {
         JFFAsyncOperationProgressHandler thread_progress_load_data_block_ = ^void( id progress_info_ )
         {
            if ( pregress_holder_.progressBlock )
               pregress_holder_.progressBlock( progress_info_ );
         };
         return progress_load_data_block_( error_, thread_progress_load_data_block_ );
      };

      JFFCancelAyncOperationBlockHolder* cancel_holder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];

      JFFDidFinishAsyncOperationBlockHolder* finish_folder_ = [ [ JFFDidFinishAsyncOperationBlockHolder new ] autorelease ];
      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      finish_folder_.didFinishBlock = ^void( id result_, NSError* error_ )
      {
         cancel_holder_.cancelBlock = nil;
         dispatch_release( current_queue_ );

         if ( done_callback_ )
            done_callback_( result_, error_ );
      };

      JFFBlockOperation* operation_ = [ JFFBlockOperation performOperationWithLoadDataBlock: load_data_block_
                                                                           didLoadDataBlock: finish_folder_.onceDidFinishBlock ];

      cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
      cancel_holder_.cancelBlock = ^void( BOOL cancel_ )
      {
         if ( cancel_callback_ )
            cancel_callback_( cancel_ );

         pregress_holder_.progressBlock = nil;
         finish_folder_.didFinishBlock = nil;
         dispatch_release( current_queue_ );

         [ operation_ cancel: cancel_ ];
      };

      return cancel_holder_.onceCancelBlock;
   } copy ] autorelease ];
}
