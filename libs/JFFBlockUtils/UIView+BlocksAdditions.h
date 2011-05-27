#import <UIKit/UIView.h>

@interface UIView (BlocksAdditions)

+(void)animateWithAnimations:( void (^)( void ) )animations_;

+(void)animateWithOptions:( UIViewAnimationOptions )options_
               animations:( void (^)( void ) )animations_;

@end
