#import "NSObject+WeakAsyncOperation.h"

#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

@implementation NSObject (WeakAsyncOperation)

-(JFFAsyncOperation)weakAsyncOperation:( JFFAsyncOperation )async_op_
{
   async_op_ = [ [ async_op_ copy ] autorelease ];
   return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                       , JFFCancelAsyncOperationHandler cancel_callback_
                                       , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      __block BOOL finished_ = NO;
      __block id self_ = self;

      JFFSimpleBlockHolder* ondealloc_block_holder_ = [ JFFSimpleBlockHolder simpleBlockHolder ];

      cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
      cancel_callback_ = ^void( BOOL cancel_op_ )
      {
         finished_ = YES;

         if ( ondealloc_block_holder_.simpleBlock )
         {
            [ self_ removeOnDeallocBlock: ondealloc_block_holder_.simpleBlock ];
            ondealloc_block_holder_.simpleBlock = nil;
         }

         if ( cancel_callback_ )
            cancel_callback_( cancel_op_ );
      };

      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      done_callback_ = ^void( id result_, NSError* error_ )
      {
         finished_ = YES;

         if ( ondealloc_block_holder_.simpleBlock )
         {
            [ self_ removeOnDeallocBlock: ondealloc_block_holder_.simpleBlock ];
            ondealloc_block_holder_.simpleBlock = nil;
         }

         if ( done_callback_ )
            done_callback_( result_, error_ );
      };

      JFFCancelAsyncOperation cancel_ = async_op_( progress_callback_, cancel_callback_, done_callback_ );

      if ( finished_ )
      {
         return JFFEmptyCancelAsyncOperationBlock;
      }

      ondealloc_block_holder_.simpleBlock = ^
      {
         cancel_( NO );
      };

      //TODO assert retain count
      [ self addOnDeallocBlock: ondealloc_block_holder_.simpleBlock ];

      return cancel_;
   } copy ] autorelease ];
}

@end
