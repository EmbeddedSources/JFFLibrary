@interface WeakAsyncOperationTest : GHTestCase
@end

@implementation WeakAsyncOperationTest

-(void)testCancelActionAfterUnsubscribeOnDealloc
{
   NSObject* obj_ = [ NSObject new ];

   __block BOOL cancel_callback_called_ = NO;

   JFFCancelAsyncOperation cancel_ = nil;

   {
      NSAutoreleasePool* pool_ = [ NSAutoreleasePool new ];

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

      [ pool_ release ];
   }

   [ obj_ release ];

   GHAssertTrue( cancel_callback_called_, @"Cancel callback should be called" );
   cancel_callback_called_ = NO;

   cancel_( YES );
   [ cancel_ release ];

   GHAssertFalse( cancel_callback_called_, @"Cancel callback should not be called after dealloc" );
}

-(void)testOnceCancelBlockCallingOnDealloc
{
   NSObject* obj_ = [ NSObject new ];

   __block NSUInteger cancel_callback_call_count_ = 0;

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

-(void)testCancelCallbackCallingOnCancelBlock
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

// When unsubscribe from autoCancelAsyncOperation -> native should not be canceled
-(void)testUnsubscribeFromAutoCancel
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
      [ owned_by_callbacks_ description ];
   };
   __block BOOL cancel_callback_called_ = NO;
   JFFCancelAsyncOperationHandler cancel_callback_ = ^void( BOOL canceled_ )
   {
      cancel_callback_called_ = !canceled_;
      //simulate using object in callback block
      [ owned_by_callbacks_ description ];
   };
   JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
   {
      //simulate using object in callback block
      [ owned_by_callbacks_ description ];
   };

   JFFCancelAsyncOperation cancel_ = auto_cancel_operation_( progress_callback_, cancel_callback_, done_callback_ );

   [ owned_by_callbacks_ release ];

   GHAssertFalse( deallocated_, @"owned_by_callbacks_ objet should not be deallocated" );

   cancel_( NO );

   GHAssertFalse( native_cancel_block_called_, @"Native cancel block should not be called" );
   GHAssertTrue( deallocated_, @"owned_by_callbacks_ objet should be deallocated" );
   GHAssertTrue( cancel_callback_called_, @"cancel callback should ba called" );
}

-(void)testCancelCallbackCallingForNativeLoaderWhenWeekDelegateRemove
{
   NSObject* operation_owner_ = [ NSObject new ];
   NSObject* delegate_ = [ NSObject new ];

   __block BOOL native_cancel_block_called_ = NO;

   JFFAsyncOperation operation_ = nil;

   {
      NSAutoreleasePool* pool_ = [ NSAutoreleasePool new ];

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

      [ pool_ release ];
   }

   [ operation_owner_ release ];

   GHAssertFalse( native_cancel_block_called_, @"operation_ should not be yet canceled" );

   [ delegate_ release ];

   GHAssertTrue( native_cancel_block_called_, @"operation_ should be canceled here" );

   [ operation_ release ];
}

@end
