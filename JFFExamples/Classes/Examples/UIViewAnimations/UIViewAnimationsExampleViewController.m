#import "UIViewAnimationsExampleViewController.h"

static const CGFloat button_offset_ = 20.f;

@interface UIViewAnimationsExampleViewController ()
@end

@interface JFFNextAnimation : NSObject

@property ( nonatomic, retain ) UIViewAnimationsExampleViewController* controller;
@property ( nonatomic, assign ) SEL nextAnimationSelector;

@end

@implementation JFFNextAnimation

@synthesize controller;
@synthesize nextAnimationSelector;

-(void)dealloc
{
   [ controller release ];

   [ super dealloc ];
}

@end

@implementation UIViewAnimationsExampleViewController

@synthesize animatedButton;

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

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
	return YES;
}

-(void)moveUpAnimation
{
   JFFNextAnimation* next_animation_ = [ JFFNextAnimation new ];
   next_animation_.controller = self;
   next_animation_.nextAnimationSelector = @selector( moveRightAnimation );
   [ UIView beginAnimations: nil context: next_animation_ ];

   CGFloat new_y_ = self.animatedButton.frame.origin.y
      - ( self.view.frame.size.height - button_offset_ * 2 )
      + self.animatedButton.frame.size.height;
   self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                          , new_y_
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );

   [ UIView setAnimationDelegate: self ];

   [ UIView commitAnimations ];
}

-(void)moveDownAnimation
{
   JFFNextAnimation* next_animation_ = [ JFFNextAnimation new ];
   next_animation_.controller = self;
   next_animation_.nextAnimationSelector = @selector( moveLeftAnimation );
   [ UIView beginAnimations: nil context: next_animation_ ];

   CGFloat new_y_ = self.animatedButton.frame.origin.y
      + ( self.view.frame.size.height - button_offset_ * 2 )
      - self.animatedButton.frame.size.height;
   self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                          , new_y_
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );

   [ UIView setAnimationDelegate: self ];

   [ UIView commitAnimations ];
}

-(void)moveRightAnimation
{
   JFFNextAnimation* next_animation_ = [ JFFNextAnimation new ];
   next_animation_.controller = self;
   next_animation_.nextAnimationSelector = @selector( moveDownAnimation );
   [ UIView beginAnimations: nil context: next_animation_ ];

   CGFloat new_x_ = self.animatedButton.frame.origin.x
      + ( self.view.frame.size.width - button_offset_ * 2 )
      - self.animatedButton.frame.size.width;
   self.animatedButton.frame = CGRectMake( new_x_
                                          , self.animatedButton.frame.origin.y
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );

   [ UIView setAnimationDelegate: self ];

   [ UIView commitAnimations ];
}

-(void)moveLeftAnimation
{
   [ UIView beginAnimations: nil context: nil ];

   CGFloat new_x_ = self.animatedButton.frame.origin.x
      - ( self.view.frame.size.width - button_offset_ * 2 )
      + self.animatedButton.frame.size.width;
   self.animatedButton.frame = CGRectMake( new_x_
                                          , self.animatedButton.frame.origin.y
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );

   [ UIView setAnimationDelegate: self ];

   [ UIView commitAnimations ];
}

-(IBAction)animateButtonAction:( id )sender_
{
   [ self moveUpAnimation ];
}

-(void)animationDidStop:( NSString* )animation_id_ finished:( NSNumber* )finished_ context:( void* )context_
{
   if ( [ finished_ boolValue ] )
   {
      JFFNextAnimation* context_object_ = context_;
      [ context_object_.controller performSelector: context_object_.nextAnimationSelector ];
      [ context_object_ release ];
   }
}

@end
