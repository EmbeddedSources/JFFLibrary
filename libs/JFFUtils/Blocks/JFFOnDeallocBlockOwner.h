#include <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFOnDeallocBlockOwner : NSObject
{
@private
   JFFSimpleBlock _block;
}

@property ( nonatomic, copy ) JFFSimpleBlock block;

-(id)initWithBlock:( JFFSimpleBlock )block_;

@end
