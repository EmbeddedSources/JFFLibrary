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
   NSArray* components_ = [ [ self path ] componentsSeparatedByString: @"/" ];
   NSUInteger components_count_ = [ components_ count ];
   if ( components_count_ == 1 )
   {
      return [ NSArray array ];
   }

   NSMutableArray* result_ = [ NSMutableArray arrayWithObject: @"/" ];

   NSArray* except_first_components_ = [ components_ subarrayWithRange: NSMakeRange( 1, components_count_ - 1 ) ];
   [ result_ addObjectsFromArray: except_first_components_ ];

   return result_;
}

+(void)load
{
   [ self addMethodIfNeedWithSelector: @selector( pathComponents )
                              toClass: [ NSURL class ] ];
}

@end
