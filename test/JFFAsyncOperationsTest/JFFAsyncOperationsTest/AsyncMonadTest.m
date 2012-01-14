#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface AsyncMonadTest : GHTestCase

@end

@implementation AsyncMonadTest

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
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperation secondLoaderBlock_ = secondLoader_.loader;

        __block id monadResult_ = nil;

        JFFAsyncMonad* monad_ = [ [ JFFAsyncMonad monadWithAsyncOp: firstLoader_.loader ] bind: ^id<SCMonad>( id result_ )
        {
            monadResult_ = result_;
            return [ JFFAsyncMonad monadWithAsyncOp: secondLoaderBlock_ ];
        } ];

        __block id finalResult_ = nil;

        monad_.asyncOp( nil, nil, ^( id result_, NSError* error_ )
        {
            finalResult_ = result_;
        } );

        id firstResult_ = [ NSNumber numberWithInt: 1 ];
        firstLoader_.loaderFinishBlock.didFinishBlock( firstResult_, nil );

        GHAssertTrue( monadResult_ == firstResult_, @"OK" );
        GHAssertFalse( secondLoader_.finished, @"OK" );
        GHAssertNil( finalResult_, @"OK" );

        id secondResult_ = [ NSNumber numberWithInt: 2 ];
        secondLoader_.loaderFinishBlock.didFinishBlock( secondResult_, nil );

        GHAssertTrue( secondLoader_.finished, @"OK" );
        GHAssertTrue( finalResult_ == secondResult_, @"OK" );

        [ firstLoader_  release ];
        [ secondLoader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
