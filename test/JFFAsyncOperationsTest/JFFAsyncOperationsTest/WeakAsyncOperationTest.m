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

      operation_ = [ obj_ weakAsyncOperation: operation_ ];

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

   GHAssertFalse( cancel_callback_called_, @"Cancel callback should not be called after dealloc" );
}

@end
