#import "UIAlertViewExampleViewController.h"

@implementation UIAlertViewExampleViewController

-(void)dealloc
{
   [ super dealloc ];
}

-(id)init
{
   self = [ super initWithNibName: @"UIAlertViewExampleViewController" bundle: nil ];

   if ( self )
   {
       self.title = @"UIAlertView example";
   }

   return self;
}

+(id)uiAlertViewExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)viewDidUnload
{
   [ super viewDidUnload ];
}

//UIAlertViewDelegate
-(IBAction)showAlertView1Action:( id )sender_
{
   UIAlertView* alert_ = [ [ UIAlertView alloc ] initWithTitle: @"Alert1"
                                                       message: @"test"
                                                      delegate: self
                                             cancelButtonTitle: @"cancel"
                                             otherButtonTitles: @"button1", nil ];
   [ alert_ show ];
   [ alert_ release ];
}

-(IBAction)showAlertView2Action:( id )sender_
{
}

-(IBAction)showAlertView3Action:( id )sender_
{
}

#pragma mark UIAlertViewDelegate

-(void)alertView:( UIAlertView* )alert_view_ clickedButtonAtIndex:( NSInteger )button_index_
{
}

@end
