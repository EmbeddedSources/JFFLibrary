#import "UIViewAnimationsExampleViewController.h"

@implementation UIViewAnimationsExampleViewController

-(id)init
{
   self = [ super initWithNibName: @"UIViewAnimationsExampleViewController" bundle: nil ];

   if ( self )
   {
      self.title = @"UIView animations";
   }

   return self;
}

+(id)uiViewAnimationsExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

#pragma mark - View lifecycle

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
	return YES;
}

@end
