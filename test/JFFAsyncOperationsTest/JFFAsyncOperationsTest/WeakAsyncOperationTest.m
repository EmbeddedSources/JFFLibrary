#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFAsyncOperationProgressBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface WeakAsyncOperationTest : GHTestCase
@end

@implementation WeakAsyncOperationTest

-(void)setUp
{
   [ JFFSimpleBlockHolder                  enableInstancesCounting ];
   [ JFFCancelAyncOperationBlockHolder     enableInstancesCounting ];
   [ JFFAsyncOperationProgressBlockHolder  enableInstancesCounting ];
   [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];
}

-(void)testCancelActionAfterUnsubscribeOnDealloc
{
   @autoreleasepool
   {
      NSObject* obj_ = [ NSObject new ];

      __block BOOL cancel_callback_called_ = NO;

      JFFCancelAsyncOperation cancel_ = nil;

      @autoreleasepool
      {
         JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                                 , JFFCancelAsyncOperationHandler cancel_callback_
                                                                 , JFFDidFinishAsyncOperationHandler done_callback_ )
         {
            cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
            return [ [ ^void( BOOL cancel_ )
            {
               if ( cancel_callback_ )
                  cancel_callback_( cancel_ );
            } copy ] autorelease ];
         };

         operation_ = [ obj_ autoUnsubsribeOnDeallocAsyncOperation: operation_ ];

         cancel_ = operation_( nil, ^( BOOL canceled_ )
         {
            cancel_callback_called_ = YES;
         }, nil );
         [ cancel_ retain ];
      }

      [ obj_ release ];

      GHAssertTrue( cancel_callback_called_, @"Cancel callback should be called" );
      cancel_callback_called_ = NO;

      cancel_( YES );
      [ cancel_ release ];

      GHAssertFalse( cancel_callback_called_, @"Cancel callback should not be called after dealloc" );
   }

   GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testOnceCancelBlockCallingOnDealloc
{
   @autoreleasepool
   {
      NSObject* obj_ = [ NSObject new ];

      __block NSUInteger cancel_callback_call_count_ = 0;

      @autoreleasepool
      {
         NSAutoreleasePool* pool_ = [ NSAutoreleasePool new ];

         JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                                 , JFFCancelAsyncOperationHandler cancel_callback_
                                                                 , JFFDidFinishAsyncOperationHandler done_callback_ )
         {
            cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
            return [ [ ^void( BOOL cancel_ )
            {
               ++cancel_callback_call_count_;
               if ( cancel_callback_ )
                  cancel_callback_( cancel_ );
            } copy ] autorelease ];
         };

         operation_ = [ obj_ autoUnsubsribeOnDeallocAsyncOperation: operation_ ];

         operation_( nil, nil, nil );

         [ pool_ release ];
      }

      [ obj_ release ];

      GHAssertTrue( 1 == cancel_callback_call_count_, @"Cancel callback should not be called after dealloc" );
   }

   GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelCallbackCallingOnCancelBlock
{
   @autoreleasepool
   {
      NSObject* obj_ = [ NSObject new ];

      JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                              , JFFCancelAsyncOperationHandler cancel_callback_
                                                              , JFFDidFinishAsyncOperationHandler done_callback_ )
      {
         cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
         return [ [ ^void( BOOL cancel_ )
         {
            if ( cancel_callback_ )
               cancel_callback_( cancel_ );
         } copy ] autorelease ];
      };

      operation_ = [ obj_ autoUnsubsribeOnDeallocAsyncOperation: operation_ ];

      __block BOOL cancel_callback_called_ = NO;

      JFFCancelAsyncOperation cancel_ = operation_( nil, ^( BOOL canceled_ )
      {
         cancel_callback_called_ = YES;
      }, nil );

      cancel_( YES );

      GHAssertTrue( cancel_callback_called_, @"Cancel callback should not be called after dealloc" );

      [ obj_ release ];
   }

   GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

// When unsubscribe from autoCancelAsyncOperation -> native should not be canceled
-(void)testUnsubscribeFromAutoCancel
{
   @autoreleasepool
   {
      NSObject* operation_owner_ = [ NSObject new ];

      __block BOOL native_cancel_block_called_ = NO;

      JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                              , JFFCancelAsyncOperationHandler cancel_callback_
                                                              , JFFDidFinishAsyncOperationHandler done_callback_ )
      {
         cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
         return [ [ ^void( BOOL cancel_ )
         {
            native_cancel_block_called_ = YES;
         } copy ] autorelease ];
      };

      JFFAsyncOperation auto_cancel_operation_ = [ operation_owner_ autoCancelOnDeallocAsyncOperation: operation_ ];

      __block BOOL deallocated_ = NO;

      NSObject* owned_by_callbacks_ = [ NSObject new ];
      [ owned_by_callbacks_ addOnDeallocBlock: ^void( void )
      {
         deallocated_ = YES;
      } ];

      JFFAsyncOperationProgressHandler progress_callback_ = ^void( id progress_info_ )
      {
         //simulate using object in callback block
         [ owned_by_callbacks_ class ];
      };
      __block BOOL cancel_callback_called_ = NO;
      JFFCancelAsyncOperationHandler cancel_callback_ = ^void( BOOL canceled_ )
      {
         cancel_callback_called_ = !canceled_;
         //simulate using object in callback block
         [ owned_by_callbacks_ class ];
      };
      JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
      {
         //simulate using object in callback block
         [ owned_by_callbacks_ class ];
      };

      JFFCancelAsyncOperation cancel_ = auto_cancel_operation_( progress_callback_, cancel_callback_, done_callback_ );

      [ owned_by_callbacks_ release ];

      GHAssertFalse( deallocated_, @"owned_by_callbacks_ objet should not be deallocated" );

      cancel_( NO );

      GHAssertFalse( native_cancel_block_called_, @"Native cancel block should not be called" );
      GHAssertTrue( deallocated_, @"owned_by_callbacks_ objet should be deallocated" );
      GHAssertTrue( cancel_callback_called_, @"cancel callback should ba called" );
   }

   GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelCallbackCallingForNativeLoaderWhenWeekDelegateRemove
{
   @autoreleasepool
   {
      NSObject* operation_owner_ = [ NSObject new ];
      NSObject* delegate_ = [ NSObject new ];

      __block BOOL native_cancel_block_called_ = NO;

      JFFAsyncOperation operation_ = nil;

      @autoreleasepool
      {
         JFFAsyncOperation operation_ = [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                                     , JFFCancelAsyncOperationHandler cancel_callback_
                                                                     , JFFDidFinishAsyncOperationHandler done_callback_ )
         {
            return [ [ ^void( BOOL cancel_ )
            {
               native_cancel_block_called_ = cancel_;
            } copy ] autorelease ];
         } copy ] autorelease ];
         [ operation_ retain ];//like native operation still living

         JFFAsyncOperation auto_cancel_operation_ = [ operation_owner_ autoCancelOnDeallocAsyncOperation: operation_ ];

         __block id weak_delegate_ = delegate_;
         [ weak_delegate_ autoUnsubsribeOnDeallocAsyncOperation: auto_cancel_operation_ ]( nil, nil, ^void( id result_, NSError* error_ )
         {
            NSLog( @"notify delegate: %@, with owner: %@", weak_delegate_, operation_owner_ );
         } );
      }

      [ operation_owner_ release ];

      GHAssertFalse( native_cancel_block_called_, @"operation_ should not be yet canceled" );

      [ delegate_ release ];

      GHAssertTrue( native_cancel_block_called_, @"operation_ should be canceled here" );

      [ operation_ release ];
   }

   GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

@end
