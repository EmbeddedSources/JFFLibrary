#import <UIKit/UIKit.h>

@interface JFFExamplesAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
   UIWindow* window;
   UITabBarController* tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
