#import "UITableView+BlocksAdditions.h"

@implementation UITableView (BlocksAdditions)

-(void)withinUpdates:( void (^)( void ) )block_
{
   [ self beginUpdates ];

   @try
   {
      block_();
   }
   @finally
   {
      [ self endUpdates ];
   }
}

@end
