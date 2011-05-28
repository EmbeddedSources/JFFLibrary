#import "NSObject+OnDeallocBlock.h"

#import "NSObject+Ownerships.h"
#import "JFFOnDeallocBlockOwner.h"

@implementation NSObject (OnDeallocBlock)

-(void)addOnDeallocBlock:( void(^)( void ) )block_
{
   JFFOnDeallocBlockOwner* owner_ = [ [ JFFOnDeallocBlockOwner alloc ] initWithBlock: block_ ];
   [ self.ownerships addObject: owner_ ];
   [ owner_ release ];
}

@end
