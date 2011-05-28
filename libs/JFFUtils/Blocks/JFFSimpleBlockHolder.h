#include <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFSimpleBlockHolder : NSObject
{
@private
   JFFSimpleBlock _simple_block;
}

@property ( nonatomic, copy ) JFFSimpleBlock simpleBlock;

+(id)simpleBlockHolder;

-(void)performBlockOnce;

@end
