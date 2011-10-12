#include <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFSimpleBlockHolder : NSObject

@property ( nonatomic, copy ) JFFSimpleBlock simpleBlock;

+(id)simpleBlockHolder;

-(void)performBlockOnce;

@end
