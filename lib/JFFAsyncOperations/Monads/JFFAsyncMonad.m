#import "JFFAsyncMonad.h"

#import "JFFAsyncOperationContinuity.h"

@interface NSObject (JFFAsyncMonad)
@end

@implementation NSObject (JFFAsyncMonad)

-(void)checkAsyncMonadClass
{
    NSAssert( [ self isKindOfClass: [ JFFAsyncMonad class ] ], @"Invalid monad class" );
}

@end

@interface JFFAsyncMonad ()

@property ( nonatomic, copy ) JFFAsyncOperation asyncOp;

@end

@implementation JFFAsyncMonad

@synthesize asyncOp = _asyncOp;

-(void)dealloc
{
    _asyncOp = nil;
}

-(id)initWithAsyncOp:( JFFAsyncOperation )asyncOp_
{
    self = [ super init ];

    if ( self )
    {
        self.asyncOp = asyncOp_
            ? asyncOp_
            : asyncOperationWithResult( [ NSNull null ] );
    }

    return self;
}

+(id< SCMonad >)construct:( id )value_
{
    return [ [ self alloc ] initWithAsyncOp: value_ ];
}

+(JFFAsyncMonad*)monadWithAsyncOp:( JFFAsyncOperation )asyncOp_
{
    return [ self construct: asyncOp_ ];
}

+(JFFAsyncMonad*)monadWithValue:( id )value_
{
    NSAssert( value_, @"should not be nil" );
    JFFAsyncOperation asyncOp_ = asyncOperationWithResult( [ NSNull null ] );
    return [ self monadWithAsyncOp: asyncOp_ ];
}

+ (JFFAsyncMonad *)monadWithError:( NSError* )error_
{
    NSAssert( error_, @"should not be nil" );
    JFFAsyncOperation asyncOp_ = asyncOperationWithError( error_ );
    return [ self monadWithAsyncOp: asyncOp_ ];
}

-(void)checkMonadClass:( id )monad_
{
    NSAssert( [ monad_ isKindOfClass: [ JFFAsyncMonad class ] ], @"Invalid monad class" );
}

-(id< SCMonad >)bind:( SCNextOp )nextOp_
{
    __block id firstResult_ = nil;

    JFFDidFinishAsyncOperationHandler finishCallbackBlock_ = ^( id result_, NSError* error_ )
    {
        firstResult_ = result_;
    };
    JFFAsyncOperation asyncOp1_ = asyncOperationWithFinishCallbackBlock( self.asyncOp
                                                                        , finishCallbackBlock_ );

    JFFAsyncOperation asyncOp2_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                                           , JFFCancelAsyncOperationHandler cancelCallback_
                                                           , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        JFFAsyncMonad* nextMonad_ = (JFFAsyncMonad*)nextOp_( firstResult_ );
        [ nextMonad_ checkAsyncMonadClass ];
        return nextMonad_.asyncOp( progressCallback_, cancelCallback_, doneCallback_ );
    };

    JFFAsyncOperation newOp_ = sequenceOfAsyncOperations( asyncOp1_, asyncOp2_, nil );

    return [ [ self class ] construct: newOp_ ];
}

@end
