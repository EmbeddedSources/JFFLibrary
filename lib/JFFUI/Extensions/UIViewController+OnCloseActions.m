#import "UIViewController+OnCloseActions.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

typedef void (^ESCloseSelfBlock) ( BOOL animated_ );

static char close_action_key_;
static char will_close_action_key_;
static char did_close_action_key_;

@interface UIViewController (OnCloseActionsPrivate)

@property ( nonatomic, copy ) ESCloseSelfBlock closeAction;
@property ( nonatomic, retain, readonly ) UIViewController* actController;

@end

@implementation UIViewController (OnCloseActions)

-(void)setCloseAction:( ESCloseSelfBlock )close_action_
{
   objc_setAssociatedObject( self, &close_action_key_, close_action_, OBJC_ASSOCIATION_COPY_NONATOMIC ) ;   
}

-(ESCloseSelfBlock)closeAction
{
   return ( ESCloseSelfBlock )objc_getAssociatedObject( self, &close_action_key_ );
}

-(void)setWillCloseAction:( JFFWillCloseActionBlock )will_close_action_
{
   objc_setAssociatedObject( self.actController, &will_close_action_key_, will_close_action_, OBJC_ASSOCIATION_COPY_NONATOMIC ) ;   
}

-(JFFWillCloseActionBlock)willCloseAction
{
   return ( JFFWillCloseActionBlock )objc_getAssociatedObject( self.actController, &will_close_action_key_ );
}

-(void)setDidCloseAction:( JFFDidCloseActionBlock )did_close_action_
{
   objc_setAssociatedObject( self.actController, &did_close_action_key_, did_close_action_, OBJC_ASSOCIATION_COPY_NONATOMIC ) ;   
}

-(JFFDidCloseActionBlock)didCloseAction
{
   return ( JFFDidCloseActionBlock )objc_getAssociatedObject( self.actController, &did_close_action_key_ );
}

-(UIViewController*)actController
{
   UIViewController* controller_ = ( self.navigationController.topViewController == self )
      ? self.navigationController
      : self;
   NSAssert( controller_, @"act Controller should be set" );
   return controller_;
}

-(void)closeControllerWithReason:( BOOL )ok_
{
   JFFWillCloseActionBlock will_close_block_ = self.actController.willCloseAction;

   JFFDidCloseActionBlock did_close_block_ = [ self.actController.didCloseAction copy ];
   self.actController.didCloseAction = nil;

   ESCloseSelfBlock close_action_ = [ self.actController.closeAction copy ];
   self.actController.closeAction = nil;

   if ( close_action_ )
   {
      close_action_( will_close_block_ ? will_close_block_() : YES );
      [ close_action_ release ];
      self.actController.willCloseAction = nil;
   }

   if ( did_close_block_ )
   {
      did_close_block_( ok_ );
      [ did_close_block_ release ];
   }
}

@end

@interface ESPresentViewControllerHooks : NSObject
@end

@implementation ESPresentViewControllerHooks

-(void)presentModalViewControllerPrototype:( UIViewController* )modal_view_controller_ animated:( BOOL )animated_
{
   __block UIViewController* controller_to_close_ = modal_view_controller_;
   controller_to_close_.closeAction = ^void( BOOL animated_ )
   {
      [ controller_to_close_ dismissModalViewControllerAnimated: animated_ ];
   };

   objc_msgSend( self, @selector( presentModalViewControllerHook:animated: ), modal_view_controller_, animated_ );
}

-(void)pushViewControllerPrototype:( UIViewController* )view_controller_ animated:( BOOL )animated_
{
   if ( view_controller_.navigationController.topViewController )
   {
      __block UIViewController* controller_to_close_ = view_controller_;
      controller_to_close_.closeAction = ^void( BOOL animated_ )
      {
         [ controller_to_close_.navigationController popViewControllerAnimated: animated_ ];
      };
   }

   objc_msgSend( self, @selector( pushViewControllerHook:animated: ), view_controller_, animated_ );
}

+(void)load
{
   [ self hookInstanceMethodForClass: [ UINavigationController class ]
                        withSelector: @selector( pushViewController:animated: )
             prototypeMethodSelector: @selector( pushViewControllerPrototype:animated: )
                  hookMethodSelector: @selector( pushViewControllerHook:animated: ) ];

   [ self hookInstanceMethodForClass: [ UIViewController class ]
                        withSelector: @selector( presentModalViewController:animated: )
             prototypeMethodSelector: @selector( presentModalViewControllerPrototype:animated: )
                  hookMethodSelector: @selector( presentModalViewControllerHook:animated: ) ];
}

@end
