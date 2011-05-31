#import "JFFExamplesAppDelegate.h"
#import "JFFExamplesViewController.h"

@implementation JFFExamplesAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

-(BOOL)application:( UIApplication* )application_ didFinishLaunchingWithOptions:( NSDictionary* )launch_options_
{    
   // Override point for customization after app launch.

	// Set the view controller as the window's root view controller and display.
   self.window.rootViewController = self.viewController;
   [ self.window makeKeyAndVisible ];

	return YES;
}


-(void)applicationWillResignActive:( UIApplication* )application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
