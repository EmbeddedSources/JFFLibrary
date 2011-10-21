#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFAsyncOperationProgressBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface GroupOfAsyncOperationsTest : GHTestCase
@end

@implementation GroupOfAsyncOperationsTest

-(void)setUp
{
   [ JFFCancelAyncOperationBlockHolder     enableInstancesCounting ];
   [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

   [ JFFAsyncOperationManager enableInstancesCounting ];
}

-(void)testNormalFinish
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL group_loader_finished_ = NO;
      loader_( nil, nil, ^( id result_, NSError* error_ )
      {
         if ( result_ && !error_ )
         {
            group_loader_finished_ = YES;
         }
      } );

      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertFalse( group_loader_finished_, @"Group loader not finished yet" );

      second_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( group_loader_finished_, @"Group loader finished already" );

      first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( first_loader_.finished, @"First loader finished already" );
      GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertTrue( group_loader_finished_, @"Group loader finished already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testFinishWithFirstError
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];
      
      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );
      
      __block BOOL group_loader_failed_ = NO;
      loader_( nil, nil, ^( id result_, NSError* error_ )
      {
         if ( !result_ && error_ )
         {
            group_loader_failed_ = YES;
         }
      } );

      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertFalse( group_loader_failed_, @"Group loader not failed yet" );

      second_loader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );

      GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( group_loader_failed_, @"Group loader failed already" );

      first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( first_loader_.finished, @"First loader finished already" );
      GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertTrue( group_loader_failed_, @"Group loader failed already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testFinishWithSecondError
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL group_loader_failed_ = NO;
      loader_( nil, nil, ^( id result_, NSError* error_ )
      {
         if ( !result_ && error_ )
         {
            group_loader_failed_ = YES;
         }
      } );

      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertFalse( group_loader_failed_, @"Group loader not failed yet" );

      second_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( group_loader_failed_, @"Group loader failed already" );

      first_loader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );

      GHAssertTrue( first_loader_.finished, @"First loader finished already" );
      GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertTrue( group_loader_failed_, @"Group loader failed already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelFirstLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];
      
      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL main_canceled_ = NO;
      __block BOOL once_canceled_ = NO;

      loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
      {
         main_canceled_ = YES && !once_canceled_;
         once_canceled_ = YES;
      }, nil );
      
      GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
      GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
      GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

      first_loader_.loaderCancelBlock.onceCancelBlock( YES );

      GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
      GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
      GHAssertTrue( main_canceled_, @"Group loader canceled already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelSecondLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL main_canceled_ = NO;
      __block BOOL once_canceled_ = NO;

      loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
      {
         main_canceled_ = YES && !once_canceled_;
         once_canceled_ = YES;
      }, nil );

      GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
      GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
      GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

      second_loader_.loaderCancelBlock.onceCancelBlock( YES );

      GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
      GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
      GHAssertTrue( main_canceled_, @"Group loader canceled already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelMainLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL main_canceled_ = NO;
      __block BOOL once_canceled_ = NO;

      JFFCancelAsyncOperation cancel_ = loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
      {
         main_canceled_ = YES && !once_canceled_;
         once_canceled_ = YES;
      }, nil );

      GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
      GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
      GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

      cancel_( YES );

      GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
      GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
      GHAssertTrue( main_canceled_, @"Group loader canceled already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

@end
