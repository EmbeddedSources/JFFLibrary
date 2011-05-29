#include "JFFBlockOperationUtils.h"

#import "JFFBlockOperation.h"

#import <JFFUtils/NSObject/NSObject+PerformBlock.h>

#import <Foundation/Foundation.h>

JFFAsyncOperation asyncLoaderWithLoadBlock( JFFSyncOperation load_data_block_ )
{
   load_data_block_ = [ [ load_data_block_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler pregress_info_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFBlockOperation* operation_ = [ JFFBlockOperation performOperationWithLoadDataBlock: load_data_block_
                                                                             didCancelBlock: cancel_callback_
                                                                           didLoadDataBlock: done_callback_ ];
      return [ [ ^( void ) { [ operation_ cancel ]; } copy ] autorelease ];
   } copy ] autorelease ];
}

JFFAsyncOperation asyncLoaderWithLoadWithProgressBlock( JFFSyncOperationWithProgress progress_load_data_block_ )
{
   progress_load_data_block_ = [ [ progress_load_data_block_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler pregress_info_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFSyncOperation load_data_block_ = ^( NSError** error_ )
      {
         JFFAsyncOperationProgressHandler thread_progress_load_data_block_ = ^( id progress_info_ )
         {
            [ ^
            {
               pregress_info_callback_( progress_info_ );
            } performBlockOnMainThread ];
         };
         return (id)progress_load_data_block_( error_, thread_progress_load_data_block_ );
      };
      JFFBlockOperation* operation_ = [ JFFBlockOperation performOperationWithLoadDataBlock: load_data_block_
                                                                             didCancelBlock: cancel_callback_
                                                                           didLoadDataBlock: done_callback_ ];
      return [ [ ^( void ) { [ operation_ cancel ]; } copy ] autorelease ];
   } copy ] autorelease ];
}
