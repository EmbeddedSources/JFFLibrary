#include <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFSimpleBlockHolder : NSObject

@property ( nonatomic, copy ) JFFSimpleBlock simpleBlock;
@property ( nonatomic, copy, readonly ) JFFSimpleBlock onceSimpleBlock;

+(id)simpleBlockHolder;

-(void)performBlockOnce;

@end
