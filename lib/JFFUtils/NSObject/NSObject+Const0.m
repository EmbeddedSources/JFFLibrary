#import "NSObject+Const0.h"

@interface JFFConst0 : NSObject
@end

@implementation JFFConst0

-(void)forwardInvocation:( NSInvocation* )invocation_
{
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
   return [ [ self class ] instanceMethodSignatureForSelector: @selector( doNothing ) ];
}

-(NSUInteger)doNothing
{
   return 0;
}

@end

@implementation NSObject (Const0)

+(id)objectThatAlwaysReturnZeroForAnyMethod
{
   return [ [ JFFConst0 new ] autorelease ];
}

@end
