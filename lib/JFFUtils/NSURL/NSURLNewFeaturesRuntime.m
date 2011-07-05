#import "NSObject+RuntimeExtensions.h"

#import <Foundation/Foundation.h>

@interface NSURLNewFeaturesRuntime : NSObject

@end

@implementation NSURLNewFeaturesRuntime

-(NSString*)path
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(NSArray*)pathComponents
{
   return [ [ self path ] pathComponents ];
}

+(void)load
{
   //for ios 3.x only
   [ self addMethodIfNeedWithSelector: @selector( pathComponents )
                              toClass: [ NSURL class ] ];
}

@end
