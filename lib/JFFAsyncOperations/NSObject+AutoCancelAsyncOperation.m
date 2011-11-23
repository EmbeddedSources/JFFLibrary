#import "NSObject+AutoCancelAsyncOperation.h"

#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"

#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

@implementation NSObject (WeakAsyncOperation)

-(JFFAsyncOperation)weakAsyncOperation:( JFFAsyncOperation )native_async_op_
{
   NSAssert( native_async_op_, @"native async operation should not be nil" );

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
      JFFAsyncOperationProgressHandler progress_callback_wrapper_ = ^void( id progress_info_ )
      {
         if ( progress_callback_holder_.progressBlock )
         {
            progress_callback_holder_.progressBlock( progress_info_ );
         }
      };

      JFFCancelAyncOperationBlockHolder* cancel_callback_holder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];
      cancel_callback_holder_.cancelBlock = cancel_callback_;
      JFFCancelAsyncOperationHandler cancel_callback_wrapper_ = ^void( BOOL cancel_op_ )
      {
         remove_ondealloc_block_holder_.onceSimpleBlock();
         cancel_callback_holder_.onceCancelBlock( cancel_op_ );
      };

      JFFDidFinishAsyncOperationBlockHolder* done_callback_holder_ = [ [ JFFDidFinishAsyncOperationBlockHolder new ] autorelease ];
      done_callback_holder_.didFinishBlock = done_callback_;
      JFFDidFinishAsyncOperationHandler done_callback_wrapper_ = ^void( id result_
                                                                       , NSError* error_ )
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
         cancel_( NO );
      };

      //JTODO assert retain count
      [ self addOnDeallocBlock: ondealloc_block_holder_.simpleBlock ];

      JFFCancelAyncOperationBlockHolder* main_cancel_holder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];
      main_cancel_holder_.cancelBlock = ^void( BOOL canceled_ )
      {
         cancel_( canceled_ );
      };

      return main_cancel_holder_.onceCancelBlock;
   } copy ] autorelease ];
}

@end
