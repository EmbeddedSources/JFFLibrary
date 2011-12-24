#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface TestClassWithProperties : NSObject

@property ( nonatomic, retain ) NSMutableDictionary* dict;

@end

@implementation TestClassWithProperties

@synthesize dict = _dict;

-(void)dealloc
{
    [ _dict release ];

    [ super dealloc ];
}

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        _dict = [ NSMutableDictionary new ];
    }

    return self;
}

@end

@interface CachedAsyncOperationsTest : GHTestCase
@end

@implementation CachedAsyncOperationsTest

-(void)setUp
{
    [ JFFCancelAyncOperationBlockHolder     enableInstancesCounting ];
    [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

    [ JFFAsyncOperationManager enableInstancesCounting ];
}

-(void)testCachedAsyncOperationsCancel
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* nativeLoader_ = [ [ JFFAsyncOperationManager new ] autorelease ];

        JFFPropertyPath* propertyPath_ = [ JFFPropertyPath propertyPathWithName: @"dict"
                                                                            key: @"1" ];

        JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
        {
            return [ [ JFFPropertyExtractor new ] autorelease ];
        };

        TestClassWithProperties* dataOwner_ = [ [ TestClassWithProperties new ] autorelease ];

        JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                           propertyExtractorFactoryBlock: factory_
                                                                          asyncOperation: nativeLoader_.loader
                                                                  didFinishLoadDataBlock: nil ];

        __block BOOL cancelFlag_ = NO;
        JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL canceled_ )
        {
            cancelFlag_ = canceled_;
        };

        JFFCancelAsyncOperation cancel_ = cachedLoader_( nil, cancel_callback_, nil );

        GHAssertFalse( nativeLoader_.finished  , @"OK" );
        GHAssertFalse( nativeLoader_.canceled  , @"OK" );
        GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

        cancel_( YES );

        GHAssertFalse( nativeLoader_.finished  , @"OK" );
        GHAssertTrue ( nativeLoader_.canceled  , @"OK" );
        GHAssertTrue ( nativeLoader_.cancelFlag, @"OK" );

        GHAssertTrue( cancelFlag_, @"OK" );
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCachedAsyncOperationsUnsibscribe
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* nativeLoader_ = [ [ JFFAsyncOperationManager new ] autorelease ];

        JFFPropertyPath* propertyPath_ = [ JFFPropertyPath propertyPathWithName: @"dict"
                                                                            key: @"1" ];

        JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
        {
            return [ [ JFFPropertyExtractor new ] autorelease ];
        };

        TestClassWithProperties* dataOwner_ = [ [ TestClassWithProperties new ] autorelease ];

        JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                           propertyExtractorFactoryBlock: factory_
                                                                          asyncOperation: nativeLoader_.loader
                                                                  didFinishLoadDataBlock: nil ];

        __block BOOL cancelFlag_ = YES;
        JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL canceled_ )
        {
            cancelFlag_ = canceled_;
        };

        JFFCancelAsyncOperation cancel_ = cachedLoader_( nil, cancel_callback_, nil );

        GHAssertFalse( nativeLoader_.finished  , @"OK" );
        GHAssertFalse( nativeLoader_.canceled  , @"OK" );
        GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

        cancel_( NO );

        GHAssertFalse( nativeLoader_.finished  , @"OK" );
        GHAssertFalse( nativeLoader_.canceled  , @"OK" );
        GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

        GHAssertFalse( cancelFlag_, @"OK" );
        cancelFlag_ = YES;

        nativeLoader_.loaderCancelBlock.onceCancelBlock( NO );

        GHAssertTrue( cancelFlag_, @"OK" );
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCachedAsyncOperationsCancelNative
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* nativeLoader_ = [ [ JFFAsyncOperationManager new ] autorelease ];

      JFFPropertyPath* propertyPath_ = [ JFFPropertyPath propertyPathWithName: @"dict"
                                                                          key: @"1" ];

      JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
      {
         return [ [ JFFPropertyExtractor new ] autorelease ];
      };

      TestClassWithProperties* dataOwner_ = [ [ TestClassWithProperties new ] autorelease ];

      JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                         propertyExtractorFactoryBlock: factory_
                                                                        asyncOperation: nativeLoader_.loader
                                                                didFinishLoadDataBlock: nil ];

      __block BOOL cancelFlag_ = NO;
      JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL canceled_ )
      {
         cancelFlag_ = canceled_;
      };

      JFFCancelAsyncOperation cancel_ = cachedLoader_( nil, cancel_callback_, nil );

      GHAssertFalse( nativeLoader_.finished  , @"OK" );
      GHAssertFalse( nativeLoader_.canceled  , @"OK" );
      GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

      nativeLoader_.loaderCancelBlock.onceCancelBlock( YES );

      GHAssertFalse( nativeLoader_.finished  , @"OK" );
      GHAssertTrue( nativeLoader_.canceled  , @"OK" );
      GHAssertTrue( nativeLoader_.cancelFlag, @"OK" );

      GHAssertTrue( cancelFlag_, @"OK" );
      cancelFlag_ = NO;

      cancel_( YES );

      GHAssertFalse( cancelFlag_, @"OK" );
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
