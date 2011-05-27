#import <UIKit/UIKit.h>

@interface UITableView (BlocksAdditions)

-(void)withinUpdates:( void (^)( void ) )block_;

@end
