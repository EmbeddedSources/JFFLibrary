#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFAsyncOperationProgressBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface SequenceOfAsyncOperationsTest : GHTestCase
@end

@implementation SequenceOfAsyncOperationsTest

-(void)setUp
{
//   [ JFFSimpleBlockHolder                  enableInstancesCounting ];
   [ JFFCancelAyncOperationBlockHolder     enableInstancesCounting ];
//   [ JFFAsyncOperationProgressBlockHolder  enableInstancesCounting ];
   [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];
}

-(void)testSequenceOfAsyncOperations
{
   @autoreleasepool
   {
      JFFDidFinishAsyncOperationBlockHolder* first_loader_finish_ = [ JFFDidFinishAsyncOperationBlockHolder new ];

      JFFAsyncOperation loader1_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                            , JFFCancelAsyncOperationHandler cancel_callback_
                                                            , JFFDidFinishAsyncOperationHandler done_callback_ )
      {
         first_loader_finish_.didFinishBlock = done_callback_;
         return JFFEmptyCancelAsyncOperationBlock;
      };

      __block BOOL first_loader_finished_ = NO;
      loader1_ = asyncOperationWithDoneBlock( loader1_, ^()
      {
         first_loader_finished_ = YES;
      } );

      JFFAsyncOperation loader2_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                            , JFFCancelAsyncOperationHandler cancel_callback_
                                                            , JFFDidFinishAsyncOperationHandler done_callback_ )
      {
         GHAssertTrue( first_loader_finished_, @"First loader finished already" );
         if ( done_callback_ )
            done_callback_( [ NSNull null ], nil );
         return JFFEmptyCancelAsyncOperationBlock;
      };

      JFFAsyncOperation loader_ = sequenceOfAsyncOperations( loader1_, loader2_, nil );

      __block BOOL sequence_loader_finished_ = NO;
      loader_( nil, nil, ^( id result_, NSError* error_ )
      {
         if ( result_ && !error_ )
         {
            sequence_loader_finished_ = YES;
         }
      } );

      GHAssertFalse( first_loader_finished_, @"First loader not finished yet" );
      GHAssertFalse( sequence_loader_finished_, @"Sequence loader not finished yet" );

      first_loader_finish_.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( first_loader_finished_, @"First loader finished already" );
      GHAssertTrue( sequence_loader_finished_, @"Sequence loader finished already" );

      [ first_loader_finish_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

@end
