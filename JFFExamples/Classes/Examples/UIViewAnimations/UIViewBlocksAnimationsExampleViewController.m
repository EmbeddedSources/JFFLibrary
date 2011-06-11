#import "UIViewBlocksAnimationsExampleViewController.h"

static const CGFloat button_offset_ = 20.f;

@interface UIViewBlocksAnimationsExampleViewController ()
@end

@implementation UIViewBlocksAnimationsExampleViewController

@synthesize animatedButton;

-(id)init
{
   self = [ super initWithNibName: @"UIViewBlocksAnimationsExampleViewController" bundle: nil ];

   if ( self )
   {
      self.title = @"UIView blocks animations";
   }

   return self;
}

+(id)uiViewBlocksAnimationsExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
	return YES;
}

-(void)moveUpAnimation
{
   CGFloat new_y_ = self.animatedButton.frame.origin.y
      - ( self.view.frame.size.height - button_offset_ * 2 )
      + self.animatedButton.frame.size.height;
   self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                          , new_y_
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );
}

-(void)moveDownAnimation
{
   CGFloat new_y_ = self.animatedButton.frame.origin.y
      + ( self.view.frame.size.height - button_offset_ * 2 )
      - self.animatedButton.frame.size.height;
   self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                          , new_y_
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );
}

-(void)moveRightAnimation
{
   CGFloat new_x_ = self.animatedButton.frame.origin.x
   + ( self.view.frame.size.width - button_offset_ * 2 )
   - self.animatedButton.frame.size.width;
   self.animatedButton.frame = CGRectMake( new_x_
                                          , self.animatedButton.frame.origin.y
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );
}

-(void)moveLeftAnimation
{
   CGFloat new_x_ = self.animatedButton.frame.origin.x
   - ( self.view.frame.size.width - button_offset_ * 2 )
   + self.animatedButton.frame.size.width;
   self.animatedButton.frame = CGRectMake( new_x_
                                          , self.animatedButton.frame.origin.y
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );
}

-(IBAction)animateButtonAction:( id )sender_
{
   //
}

@end
