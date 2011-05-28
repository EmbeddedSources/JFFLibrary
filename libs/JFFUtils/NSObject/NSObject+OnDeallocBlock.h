#import <Foundation/Foundation.h>

@interface NSObject (OnDeallocBlock)

-(void)addOnDeallocBlock:( void(^)( void ) )block_;

@end
