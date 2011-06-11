#import "UIViewBlocksAnimationsExampleViewController.h"

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

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

-(JFFSimpleBlock)moveUpAnimationBlock
{
   return [ [ ^
   {
      CGFloat new_y_ = self.animatedButton.frame.origin.y
         - ( self.view.frame.size.height - button_offset_ * 2 )
         + self.animatedButton.frame.size.height;
      self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                             , new_y_
                                             , self.animatedButton.frame.size.width
                                             , self.animatedButton.frame.size.height );
   } copy ] autorelease ];
}

-(JFFSimpleBlock)moveDownAnimationBlock
{
   return [ [ ^
   {
      CGFloat new_y_ = self.animatedButton.frame.origin.y
         + ( self.view.frame.size.height - button_offset_ * 2 )
         - self.animatedButton.frame.size.height;
      self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                             , new_y_
                                             , self.animatedButton.frame.size.width
                                             , self.animatedButton.frame.size.height );
   } copy ] autorelease ];
}

-(JFFSimpleBlock)moveRightAnimationBlock
{
   return [ [ ^
   {
      CGFloat new_x_ = self.animatedButton.frame.origin.x
         + ( self.view.frame.size.width - button_offset_ * 2 )
         - self.animatedButton.frame.size.width;
      self.animatedButton.frame = CGRectMake( new_x_
                                             , self.animatedButton.frame.origin.y
                                             , self.animatedButton.frame.size.width
                                             , self.animatedButton.frame.size.height );
   } copy ] autorelease ];
}

-(JFFSimpleBlock)moveLeftAnimationBlock
{
   return [ [ ^
   {
      CGFloat new_x_ = self.animatedButton.frame.origin.x
         - ( self.view.frame.size.width - button_offset_ * 2 )
         + self.animatedButton.frame.size.width;
      self.animatedButton.frame = CGRectMake( new_x_
                                             , self.animatedButton.frame.origin.y
                                             , self.animatedButton.frame.size.width
                                             , self.animatedButton.frame.size.height );
   } copy ] autorelease ];
}

-(JFFSimpleBlock)animationBlockWithAnimations:( JFFSimpleBlock )animations_
                                   completion:( JFFSimpleBlock )completion_
{
   completion_ = [ [ completion_ copy ] autorelease ];
   return [ [ ^
   {
      [ UIView animateWithDuration: 0.2
                        animations: animations_
                        completion: ^( BOOL finished_ )
      {
         if ( completion_ )
            completion_();
      } ];
   } copy ] autorelease ];
}

-(IBAction)animateButtonAction:( id )sender_
{
   JFFSimpleBlock move_left_animation_block_ = [ self moveLeftAnimationBlock ];
   move_left_animation_block_ = [ self animationBlockWithAnimations: move_left_animation_block_
                                                         completion: nil ];

   JFFSimpleBlock move_down_animation_block_ = [ self moveDownAnimationBlock ];
   move_down_animation_block_ = [ self animationBlockWithAnimations: move_down_animation_block_
                                                         completion: move_left_animation_block_ ];

   JFFSimpleBlock move_right_animation_block_ = [ self moveRightAnimationBlock ];
   move_right_animation_block_ = [ self animationBlockWithAnimations: move_right_animation_block_
                                                          completion: move_down_animation_block_ ];

   JFFSimpleBlock move_up_animation_block_ = [ self moveUpAnimationBlock ];
   move_up_animation_block_ = [ self animationBlockWithAnimations: [ self moveUpAnimationBlock ]
                                                       completion: move_right_animation_block_ ];

   move_up_animation_block_();
}

@end
