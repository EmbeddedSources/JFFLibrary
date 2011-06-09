#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <UIKit/UIKit.h>

@interface JFFActionSheet : UIActionSheet
{
@private
   BOOL _dismiss_before_enter_background;
}

@property ( nonatomic, assign ) BOOL dismissBeforeEnterBackground;

//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+(id)actionSheetWithTitle:( NSString* )title_
        cancelButtonTitle:( id )cancel_button_title_
   destructiveButtonTitle:( id )destructive_button_title_
        otherButtonTitles:( id )other_button_titles_, ...;

//pass NSString(button title) or JFFAlertButton
-(void)addActionButton:( id )action_button_;

-(void)addActionButtonWithTitle:( NSString* )title_ ation:( JFFSimpleBlock )action_;

+(void)dismissAllActionSheets;

@end
