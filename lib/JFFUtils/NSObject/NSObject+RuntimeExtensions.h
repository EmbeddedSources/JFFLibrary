#import <Foundation/Foundation.h>

@interface NSObject (RuntimeExtensions)

+(void)addMethodIfNeedWithSelector:( SEL )selector_
                           toClass:( Class )class_;

+(void)hookMethodForClass:( Class )class_
             withSelector:( SEL )target_selector_
  prototypeMethodSelector:( SEL )prototype_selector_
       hookMethodSelector:( SEL )hook_selector_;

@end
