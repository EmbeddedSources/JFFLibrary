#import "ExamplesViewController.h"

#import "UIAlertViewExampleViewController.h"
#import "JFFAlertViewExampleViewController.h"

@implementation ExamplesViewController

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
   return YES;
}

-(IBAction)showUIAlertViewExampleAction:( id )sender_
{
   UIViewController* controller_ = [ UIAlertViewExampleViewController uiAlertViewExampleViewController ];
   [ self.navigationController pushViewController: controller_ animated: YES ];
}

-(IBAction)showJFFAlertViewExampleAction:( id )sender_
{
   UIViewController* controller_ = [ JFFAlertViewExampleViewController jffAlertViewExampleViewController ];
   [ self.navigationController pushViewController: controller_ animated: YES ];
}

@end
