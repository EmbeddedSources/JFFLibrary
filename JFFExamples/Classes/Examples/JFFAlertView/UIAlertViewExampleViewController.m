#import "UIAlertViewExampleViewController.h"

static NSString* const cancel_button_title_ = @"cancel";
static NSString* const button1_button_title_ = @"button1";

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
                                             cancelButtonTitle: cancel_button_title_
                                             otherButtonTitles: button1_button_title_, nil ];
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
   if ( alert_view_.cancelButtonIndex == button_index_ )
   {
      NSLog( @"Alert1 \"%@\" button selected", cancel_button_title_ );
   }
   else
   {
      NSLog( @"Alert1 \"%@\" button selected", button1_button_title_ );
   }
}

@end
