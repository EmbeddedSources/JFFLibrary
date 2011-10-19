#import "JFFActionSheet.h"

#import "JFFAlertButton.h"
#import "NSObject+JFFAlertButton.h"

#define UI_APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION @"UIApplicationDidEnterBackgroundNotification"

static NSMutableArray* active_action_sheets_ = nil;
static NSInteger first_action_index_ = 1;

@interface JFFActiveActionSheet : NSObject

@property( nonatomic, retain ) JFFActionSheet* actionSheet;
@property( nonatomic, retain ) UIView* view;

+(id)activeActionSheet:( JFFActionSheet* )action_sheet_ withView:( UIView* )view_;
-(id)initActionSheet:( JFFActionSheet* )action_sheet_ withView:( UIView* )view_;

@end

@implementation JFFActiveActionSheet

@synthesize actionSheet = _action_sheet;
@synthesize view = _view;


-(void)dealloc
{
   [ _action_sheet release ];
   [ _view release ];
   
   [ super dealloc ];
}

-(id)initActionSheet:( JFFActionSheet* )action_sheet_ withView:( UIView* )view_
{
   self = [ super init ];
   
   if ( self )
   {
      self.actionSheet = action_sheet_;
      self.view = view_;
   }
   
   return self;
}

+(id)activeActionSheet:( JFFActionSheet* )action_sheet_ withView:( UIView* )view_
{
   return [ [ [ self alloc ] initActionSheet: action_sheet_ withView: view_ ] autorelease ];
}

@end

@interface JFFActionSheet () < UIActionSheetDelegate >

@property ( nonatomic, retain ) NSMutableArray* alertButtons;

+(void)activeActionSheetsAddSheet:( JFFActionSheet* )action_sheet_ withView:( UIView* )view_;
+(void)activeActionSheetsRemoveSheet:( UIActionSheet* )action_sheet_;
+(JFFActiveActionSheet*)objectToRemove:( UIActionSheet* )action_sheet_;
-(void)forceShowInView:( UIView* )view_;

@end

@implementation JFFActionSheet

@synthesize dismissBeforeEnterBackground = _dismiss_before_enter_background;
@synthesize alertButtons = _alert_buttons;

-(void)dealloc
{
   [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];

   [ _alert_buttons release ];

   [ super dealloc ];
}

+(void)activeActionSheetsAddSheet:( JFFActionSheet* )action_sheet_ withView:( UIView* )view_
{
   if ( !active_action_sheets_ )
   {
      active_action_sheets_ = [ [ NSMutableArray alloc ] initWithCapacity: 1 ];
   }
   
   JFFActiveActionSheet* action_sheets_struct_ = [ JFFActiveActionSheet activeActionSheet: action_sheet_ withView: view_ ];

   [ active_action_sheets_ addObject: action_sheets_struct_ ];
}

+(void)activeActionSheetsRemoveSheet:( UIActionSheet* )action_sheet_
{
   if ( !active_action_sheets_ )
      return;

   [ active_action_sheets_ removeObject: [ JFFActionSheet objectToRemove:action_sheet_ ] ];

   if ( ![ active_action_sheets_ count ] )
   {
      [ active_action_sheets_ release ];
      active_action_sheets_ = nil;
   }
}

+(JFFActiveActionSheet*)objectToRemove:( UIActionSheet* )action_sheet_
{
   if ( !active_action_sheets_ )
      return nil;
   
   for( JFFActiveActionSheet* action_sheets_struct_ in active_action_sheets_ )
   {
      if ( action_sheets_struct_.actionSheet ==  action_sheet_ )
      {
         return action_sheets_struct_;
      }
   }
   
   return nil;
}

+(void)dismissAllActionSheets
{
   if ( !active_action_sheets_)
      return;

   NSArray* temporary_active_action_sheets_ = [ [ NSArray alloc ] initWithArray: active_action_sheets_ ];

   for ( JFFActionSheet* action_sheet_ in temporary_active_action_sheets_ )
   {
      [ action_sheet_ dismissWithClickedButtonIndex: [ action_sheet_ cancelButtonIndex ] animated: NO ];
   }

   [ temporary_active_action_sheets_ release ];
}

-(id)initWithTitle:( NSString* )title_
 cancelButtonTitle:( NSString* )cancel_button_title_
destructiveButtonTitle:( NSString* )destructive_button_title_
otherButtonTitlesArray:( NSArray* )other_button_titles_
{
   self = [ super initWithTitle: title_
                       delegate: self
              cancelButtonTitle: nil
         destructiveButtonTitle: destructive_button_title_
              otherButtonTitles: nil ];

   if ( self )
   {
      for ( NSString* button_title_ in other_button_titles_ )
      {
         [ super addButtonWithTitle: button_title_ ];
      }

      if ( cancel_button_title_ )
      {
         [ super addButtonWithTitle: cancel_button_title_ ];
      }

      [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                  selector: @selector( applicationDidEnterBackground: )
                                                      name: UI_APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION 
                                                    object: nil ];
   }

   return self;
}

-(NSInteger)addActionButtonWithIndex:( id )alert_button_id_
{
   JFFAlertButton* alert_button_ = [ alert_button_id_ toAlertButton ];
   NSInteger index_ = [ super addButtonWithTitle: alert_button_.title ];
   [ self.alertButtons insertObject: alert_button_ atIndex: index_ ];
   return index_;
}

-(void)addActionButton:( id )alert_button_
{
   [ self addActionButtonWithIndex: alert_button_ ];
}

-(void)addActionButtonWithTitle:( NSString* )title_ ation:( JFFSimpleBlock )action_
{
   [ self addActionButton: [ JFFAlertButton alertButton: title_ action: action_ ] ];
}

-(NSInteger)addButtonWithTitle:( NSString* )title_
{
   return [ self addActionButtonWithIndex: title_ ];
}

+(id)actionSheetWithTitle:( NSString* )title_
        cancelButtonTitle:( id )cancel_button_title_
   destructiveButtonTitle:( id )destructive_button_title_
        otherButtonTitles:( id )other_button_titles_, ...
{
   NSMutableArray* other_action_buttons_ = [ NSMutableArray array ];
   NSMutableArray* other_action_string_titles_ = [ NSMutableArray array ];

   if ( destructive_button_title_ )
   {
      JFFAlertButton* destructive_button_ = [ destructive_button_title_ toAlertButton ];
      [ other_action_buttons_ insertObject: destructive_button_ atIndex: 0 ];
   }

   va_list args;
   va_start( args, other_button_titles_ );
   for ( NSString* button_title_ = other_button_titles_; button_title_ != nil; button_title_ = va_arg( args, NSString* ) )
   {
      JFFAlertButton* alert_button_ = [ button_title_ toAlertButton ];
      [ other_action_buttons_ addObject: alert_button_ ];
      [ other_action_string_titles_ addObject: alert_button_.title ];
   }
   va_end( args );

   JFFAlertButton* cancel_button_ = [ cancel_button_title_ toAlertButton ];

   JFFActionSheet* action_sheet_ = [ [ [ self alloc ] initWithTitle: title_
                                                  cancelButtonTitle: cancel_button_.title
                                             destructiveButtonTitle: destructive_button_title_
                                             otherButtonTitlesArray: other_action_string_titles_ ] autorelease ];

   if ( cancel_button_ )
   {
      [ other_action_buttons_ addObject: cancel_button_ ];
      action_sheet_.cancelButtonIndex = action_sheet_.numberOfButtons - 1;
   }

   action_sheet_.alertButtons = other_action_buttons_;

   return action_sheet_;
}

-(void)showInView:( UIView* )view_
{
   [ [ self class ] activeActionSheetsAddSheet: self withView: view_ ];

   if ( [ active_action_sheets_ count ] == first_action_index_ )
   {
      [ self forceShowInView: view_ ];
   }
}

-(void)applicationDidEnterBackground:( id )sender_
{
   if ( self.dismissBeforeEnterBackground )
   {
      [ self dismissWithClickedButtonIndex: [ self cancelButtonIndex ] animated: NO ];
   }
}

#pragma mark UIActionSheetDelegate

-(void)actionSheet:( UIActionSheet* )action_sheet_ clickedButtonAtIndex:( NSInteger )button_index_
{
   JFFAlertButton* alert_button_ = [ self.alertButtons objectAtIndex: button_index_ ];
   if ( alert_button_ )
      alert_button_.action();
}

-(void)actionSheet:( UIActionSheet* )action_sheet_ didDismissWithButtonIndex:( NSInteger )button_index_
{
   [ [ self class ] activeActionSheetsRemoveSheet: self ];
   
   if ( [ active_action_sheets_ count ] <= 0 )
      return;
   
   JFFActiveActionSheet* action_sheets_struct_ = [ active_action_sheets_ objectAtIndex: 0 ];
   [ action_sheets_struct_.actionSheet forceShowInView: action_sheets_struct_.view ];
}

-(void)forceShowInView:( UIView* )view_
{
   [ super showInView: view_ ];
}

@end
