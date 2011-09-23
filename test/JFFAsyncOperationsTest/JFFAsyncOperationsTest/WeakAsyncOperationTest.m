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

      operation_ = [ obj_ autoUnsibscribeAsyncOperation: operation_ ];

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

      operation_ = [ obj_ autoUnsibscribeAsyncOperation: operation_ ];

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

   operation_ = [ obj_ autoUnsibscribeAsyncOperation: operation_ ];

   __block BOOL cancel_callback_called_ = NO;

   JFFCancelAsyncOperation cancel_ = operation_( nil, ^( BOOL canceled_ )
   {
      cancel_callback_called_ = YES;
   }, nil );

   cancel_( YES );

   GHAssertTrue( cancel_callback_called_, @"Cancel callback should not be called after dealloc" );

   [ obj_ release ];
}

@end
