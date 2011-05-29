#import "JFFAlertView.h"

#import "JFFAlertButton.h"

#define UI_APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION @"UIApplicationDidEnterBackgroundNotification"

static NSMutableArray* active_alerts_ = nil;

@interface NSObject (ESAlertView)

-(JFFAlertButton*)toAlertButton;

@end

@implementation NSObject (ESAlertView)

-(JFFAlertButton*)toAlertButton
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

@end

@implementation NSString (ESAlertView)

-(JFFAlertButton*)toAlertButton
{
   return [ JFFAlertButton alertButton: self action: (JFFSimpleBlock)^(){} ];
}

@end

@implementation JFFAlertButton (ESAlertView)

-(JFFAlertButton*)toAlertButton
{
   return self;
}

@end

@interface JFFAlertView ()

@property ( nonatomic, assign ) BOOL exclusive;
@property ( nonatomic, retain ) NSMutableArray* alertButtons;

+(void)activeAlertsAddAlert:( UIAlertView* )alert_view_;
+(void)activeAlertsRemoveAlert:( UIAlertView* )alert_view_;

@end

@implementation JFFAlertView

@synthesize dismissBeforeEnterBackground = _dismiss_before_enter_background;
@synthesize exclusive = _exclusive;
@synthesize alertButtons = _alert_buttons;

+(void)activeAlertsAddAlert:( UIAlertView* )alert_view_
{
   if ( !active_alerts_ )
   {
      active_alerts_ = [ [ NSMutableArray alloc ] initWithCapacity: 1 ];
   }

   [ active_alerts_ addObject: alert_view_ ];
}

+(void)activeAlertsRemoveAlert:( UIAlertView* )alert_view_
{
   if ( !active_alerts_ )
      return;

   [ active_alerts_ removeObject: alert_view_ ];

   if ( ![ active_alerts_ count ] )
   {
      [ active_alerts_ release ];
      active_alerts_ = nil;
   }
}

-(void)forceDismiss
{
   [ self dismissWithClickedButtonIndex: [ self cancelButtonIndex ] animated: NO ];
   [ self dismissWithClickedButtonIndex: [ self cancelButtonIndex ] animated: NO ];
}

+(void)dismissAllAlertViews
{
   if ( !active_alerts_)
      return;

   NSArray* temporary_active_alerts_ = [ [ NSArray alloc ] initWithArray: active_alerts_ ];

   for ( ESAlertView* alert_view_ in temporary_active_alerts_ )
   {
      [ alert_view_ forceDismiss ];
   }

   [ temporary_active_alerts_ release ];

   [ active_alerts_ release ];
   active_alerts_ = nil;
}

+(void)showAlertWithTitle:( NSString* )title_
              description:( NSString* )description_
{
   ESAlertView* alert_ = [ ESAlertView alertWithTitle: title_
                                              message: description_
                                    cancelButtonTitle: NSLocalizedString( @"OK", nil )
                                    otherButtonTitles: nil ];

   [ alert_ show ];
}

+(void)showErrorWithDescription:( NSString* )description_
{
   [ self showAlertWithTitle: NSLocalizedString( @"ERROR", nil ) description: description_ ];
}

+(void)showInformationWithDescription:( NSString* )description_
{
   [ self showAlertWithTitle: NSLocalizedString( @"INFORMATION", nil ) description: description_ ];
}

-(void)dealloc
{
   [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];

   [ _alert_buttons release ];

   [ super dealloc ];
}

-(id)initWithTitle:( NSString* )title_
           message:( NSString* )message_
 cancelButtonTitle:( NSString* )cancel_button_title_
otherButtonTitlesArray:( NSArray* )other_button_titles_
{
   self = [ super initWithTitle: title_
                        message: message_ 
                       delegate: self
              cancelButtonTitle: cancel_button_title_
              otherButtonTitles: nil, nil ];

   if ( self )
   {
      for ( NSString* button_title_ in other_button_titles_ )
      {
         [ super addButtonWithTitle: button_title_ ];
      }

      [ [ NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector( applicationDidEnterBackground: )
                                                     name: UI_APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION 
                                                   object: nil ];
   }

   return self;
}

-(NSInteger)addAlertButtonWithIndex:( id )alert_button_id_
{
   ESAlertButton* alert_button_ = [ alert_button_id_ toAlertButton ];
   NSInteger index_ = [ super addButtonWithTitle: alert_button_.title ];
   [ self.alertButtons insertObject: alert_button_ atIndex: index_ ];
   return index_;
}

-(void)addAlertButton:( id )alert_button_id_
{
   [ self addAlertButtonWithIndex: alert_button_id_ ];
}

-(void)addAlertButtonWithTitle:( NSString* )title_ ation:( JFFSimpleBlock )action_
{
   [ self addAlertButton: [ JFFAlertButton alertButton: title_ action: action_ ] ];
}

-(NSInteger)addButtonWithTitle:( NSString* )title_
{
   return [ self addAlertButtonWithIndex: title_ ];
}

+(id)alertWithTitle:( NSString* )title_
            message:( NSString* )message_
  cancelButtonTitle:( id )cancel_button_title_
  otherButtonTitles:( id )other_button_titles_, ...
{
   JFFAlertButton* cancel_alert_button_title_ = [ cancel_button_title_ toAlertButton ];

   NSMutableArray* other_alert_buttons_ = [ NSMutableArray array ];
   NSMutableArray* other_alert_string_titles_ = [ NSMutableArray array ];

   va_list args;
   va_start( args, other_button_titles_ );
   for ( NSString* button_title_ = other_button_titles_; button_title_ != nil; button_title_ = va_arg( args, NSString* ) )
   {
      JFFAlertButton* alert_button_ = [ button_title_ toAlertButton ];
      [ other_alert_buttons_ addObject: alert_button_ ];
      [ other_alert_string_titles_ addObject: alert_button_.title ];
   }
   va_end( args );

   if ( cancel_alert_button_title_ )
      [ other_alert_buttons_ insertObject: cancel_alert_button_title_ atIndex: 0 ];

   ESAlertView* alert_view_ = [ [ [ self alloc ] initWithTitle: title_
                                                       message: message_
                                             cancelButtonTitle: cancel_button_title_
                                        otherButtonTitlesArray: other_alert_string_titles_ ] autorelease ];

   alert_view_.alertButtons = other_alert_buttons_;

   return alert_view_;
}

-(void)show
{
   [ ESAlertView activeAlertsAddAlert: self ];

   [ super show ];
}

-(void)exclusiveShow
{
   self.exclusive = YES;

   NSPredicate* predicate_ = [ NSPredicate predicateWithFormat: @"SELF.exclusive = %d", YES ];
   if ( [ [ active_alerts_ filteredArrayUsingPredicate: predicate_ ] count ] == 0 )
   {
      [ self show ];
   }
}

-(void)applicationDidEnterBackground:( id )sender_
{
   if ( self.dismissBeforeEnterBackground )
   {
      [ self forceDismiss ];
   }
}

#pragma mark UIAlertViewDelegate

-(void)alertView:( UIAlertView* )alert_view_ clickedButtonAtIndex:( NSInteger )button_index_
{
   JFFAlertButton* alert_button_ = [ self.alertButtons objectAtIndex: button_index_ ];
   if ( alert_button_ )
      alert_button_.action();
}

-(void)alertView:( UIAlertView* )alert_view_ didDismissWithButtonIndex:( NSInteger )button_index_
{
   [ ESAlertView activeAlertsRemoveAlert: self ];
}

@end
