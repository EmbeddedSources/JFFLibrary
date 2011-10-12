#import "NSObject+AutoCancelAsyncOperation.h"

#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFAsyncOperationContinuity.h"

#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation NSObject (WeakAsyncOperation)

-(JFFAsyncOperation)autoUnsibscribeOrCancelAsyncOperation:( JFFAsyncOperation )native_async_op_
                                                   cancel:( BOOL )cancel_native_async_op_
{
   NSAssert( native_async_op_, @"native async operation should not be nil" );

   native_async_op_ = [ native_async_op_ copy ];
   return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                   , JFFCancelAsyncOperationHandler cancel_callback_
                                   , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL finished_ = NO;
      __unsafe_unretained id self_ = self;

      JFFSimpleBlockHolder* ondealloc_block_holder_ = [ JFFSimpleBlockHolder new ];

      JFFSimpleBlockHolder* remove_ondealloc_block_holder_ = [ JFFSimpleBlockHolder new ];
      remove_ondealloc_block_holder_.simpleBlock = ^void( void )
      {
         finished_ = YES;

         if ( ondealloc_block_holder_.simpleBlock )
         {
            [ self_ removeOnDeallocBlock: ondealloc_block_holder_.simpleBlock ];
            ondealloc_block_holder_.simpleBlock = nil;
         }
      };

      JFFAsyncOperationProgressBlockHolder* progress_callback_holder_ = [ JFFAsyncOperationProgressBlockHolder new ];
      progress_callback_holder_.progressBlock = progress_callback_;
      JFFAsyncOperationProgressHandler progress_callback_wrapper_ = ^void( id progress_info_ )
      {
         if ( progress_callback_holder_.progressBlock )
            progress_callback_holder_.progressBlock( progress_info_ );
      };

      JFFCancelAyncOperationBlockHolder* cancel_callback_holder_ = [ JFFCancelAyncOperationBlockHolder new ];
      cancel_callback_holder_.cancelBlock = cancel_callback_;
      JFFCancelAsyncOperationHandler cancel_callback_wrapper_ = ^void( BOOL cancel_op_ )
      {
         remove_ondealloc_block_holder_.onceSimpleBlock();
         cancel_callback_holder_.onceCancelBlock( cancel_op_ );
      };

      JFFDidFinishAsyncOperationBlockHolder* done_callback_holder_ = [ JFFDidFinishAsyncOperationBlockHolder new ];
      done_callback_holder_.didFinishBlock = done_callback_;
      JFFDidFinishAsyncOperationHandler done_callback_wrapper_ = ^void( id result_, NSError* error_ )
      {
         remove_ondealloc_block_holder_.onceSimpleBlock();
         done_callback_holder_.onceDidFinishBlock( result_, error_ );
      };

      JFFCancelAsyncOperation cancel_ = native_async_op_( progress_callback_wrapper_
                                                         , cancel_callback_wrapper_
                                                         , done_callback_wrapper_ );

      if ( finished_ )
      {
         return JFFEmptyCancelAsyncOperationBlock;
      }

      ondealloc_block_holder_.simpleBlock = ^void( void )
      {
         cancel_( cancel_native_async_op_ );
      };

      //TODO assert retain count
      [ self addOnDeallocBlock: ondealloc_block_holder_.simpleBlock ];

      JFFCancelAyncOperationBlockHolder* main_cancel_holder_ = [ JFFCancelAyncOperationBlockHolder new ];
      main_cancel_holder_.cancelBlock = ^void( BOOL canceled_ )
      {
         if ( finished_ )
            return;

         progress_callback_holder_.progressBlock = nil;
         done_callback_holder_.didFinishBlock = nil;
         //cancel_callback_holder_.cancelBlock will be nilled here
         cancel_callback_holder_.onceCancelBlock( canceled_ );
      };

      return main_cancel_holder_.onceCancelBlock;
   };
}

-(JFFAsyncOperation)autoUnsubsribeOnDeallocAsyncOperation:( JFFAsyncOperation )native_async_op_
{
   return [ self autoUnsibscribeOrCancelAsyncOperation: native_async_op_
                                                cancel: NO ];
}

-(JFFAsyncOperation)autoCancelOnDeallocAsyncOperation:( JFFAsyncOperation )native_async_op_
{
   return [ self autoUnsibscribeOrCancelAsyncOperation: native_async_op_
                                                cancel: YES ];
}

@end
