#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

@interface JFFSimpleBlockHolderTest : GHTestCase
@end

@implementation JFFSimpleBlockHolderTest

-(void)testSimpleBlockHolderBehavior
{
   __block BOOL block_holder_deallocated_ = NO;

   @autoreleasepool
   {
      JFFSimpleBlockHolder* holder_ = [ JFFSimpleBlockHolder new ];
      [ holder_ addOnDeallocBlock: ^void( void )
      {
         block_holder_deallocated_ = YES;
      } ];

      __block BOOL block_context_deallocated_ = NO;
      __block NSUInteger perform_block_count_ = 0;

      @autoreleasepool
      {
         NSObject* block_context_ = [ NSObject new ];
         [ block_context_ addOnDeallocBlock: ^void( void )
         {
            block_context_deallocated_ = YES;
         } ];

         holder_.simpleBlock = ^void( void )
         {
            if ( [ block_context_ class ] && [ holder_ class ] )
               ++perform_block_count_;
         };

         holder_.onceSimpleBlock();
         holder_.onceSimpleBlock();

         [ block_context_ release ];
      }

      GHAssertTrue( block_context_deallocated_, @"Block context should be dealloced" );
      GHAssertTrue( 1 == perform_block_count_, @"Block was called once" );
      GHAssertTrue( nil == holder_.simpleBlock, @"Block is nil after call" );

      [ holder_ release ];
   }

   GHAssertTrue( block_holder_deallocated_, @"Block holder should be dealloced" );
}

@end
