#import <Foundation/Foundation.h>

@interface NSObject (RuntimeExtensions)

+(void)addMethodIfNeedWithSelector:( SEL )selector_
                           toClass:( Class )class_;

@end
