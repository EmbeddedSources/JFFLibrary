#import "NSObject+AutoCancelAsyncOperation.h"

#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFAsyncOperationContinuity.h"

#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"

#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

@implementation NSObject (WeakAsyncOperation)

-(JFFAsyncOperation)autoUnsibscribeOrCancelAsyncOperation:( JFFAsyncOperation )native_async_op_
                                                   cancel:( BOOL )cancel_native_async_op_
{
   native_async_op_ = [ [ native_async_op_ copy ] autorelease ];
   return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                       , JFFCancelAsyncOperationHandler cancel_callback_
                                       , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL finished_ = NO;
      __block id self_ = self;

      JFFSimpleBlockHolder* ondealloc_block_holder_ = [ [ JFFSimpleBlockHolder new ] autorelease ];

      JFFSimpleBlockHolder* remove_ondealloc_block_holder_ = [ [ JFFSimpleBlockHolder new ] autorelease ];
      remove_ondealloc_block_holder_.simpleBlock = ^void( void )
      {
         finished_ = YES;

         if ( ondealloc_block_holder_.simpleBlock )
         {
            [ self_ removeOnDeallocBlock: ondealloc_block_holder_.simpleBlock ];
            ondealloc_block_holder_.simpleBlock = nil;
         }
      };

      JFFAsyncOperationProgressBlockHolder* progress_callback_holder_ = [ [ JFFAsyncOperationProgressBlockHolder new ] autorelease ];
      progress_callback_holder_.progressBlock = progress_callback_;
      progress_callback_ = ^void( id progress_info_ )
      {
         if ( progress_callback_holder_.progressBlock )
            progress_callback_holder_.progressBlock( progress_info_ );
      };

      JFFCancelAyncOperationBlockHolder* cancel_callback_holder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];
      cancel_callback_holder_.cancelBlock = cancel_callback_;
      cancel_callback_ = ^void( BOOL cancel_op_ )
      {
         remove_ondealloc_block_holder_.onceSimpleBlock();
         cancel_callback_holder_.onceCancelBlock( cancel_op_ );
      };

      JFFDidFinishAsyncOperationBlockHolder* done_callback_holder_ = [ [ JFFDidFinishAsyncOperationBlockHolder new ] autorelease ];
      done_callback_holder_.didFinishBlock = done_callback_;
      done_callback_ = ^void( id result_, NSError* error_ )
      {
         remove_ondealloc_block_holder_.onceSimpleBlock();
         done_callback_holder_.onceDidFinishBlock( result_, error_ );
      };

      JFFCancelAsyncOperation cancel_ = native_async_op_( progress_callback_, cancel_callback_, done_callback_ );

      if ( finished_ )
      {
         return JFFStubCancelAsyncOperationBlock;
      }

      ondealloc_block_holder_.simpleBlock = ^
      {
         cancel_( cancel_native_async_op_ );
      };

      //TODO assert retain count
      [ self addOnDeallocBlock: ondealloc_block_holder_.simpleBlock ];

      JFFCancelAyncOperationBlockHolder* main_cancel_holder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];
      main_cancel_holder_.cancelBlock = ^void( BOOL canceled_ )
      {
         if ( finished_ )
            return;

         if ( canceled_ )
         {
            cancel_( YES );
         }
         else
         {
            progress_callback_holder_.progressBlock = nil;
            done_callback_holder_.didFinishBlock = nil;
            cancel_callback_holder_.onceCancelBlock( NO );
         }
      };

      return main_cancel_holder_.onceCancelBlock;
   } copy ] autorelease ];
}

-(JFFAsyncOperation)autoUnsibscribeAsyncOperation:( JFFAsyncOperation )native_async_op_
{
   return [ self autoUnsibscribeOrCancelAsyncOperation: native_async_op_
                                                cancel: NO ];
}

-(JFFAsyncOperation)autoCancelAsyncOperation:( JFFAsyncOperation )native_async_op_
{
   return [ self autoUnsibscribeOrCancelAsyncOperation: native_async_op_
                                                cancel: YES ];
}

@end
