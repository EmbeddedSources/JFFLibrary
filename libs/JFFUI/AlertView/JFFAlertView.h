#import <UIKit/UIKit.h>

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

@interface JFFAlertView : UIAlertView

@property ( nonatomic, assign ) BOOL dismissBeforeEnterBackground;

//cancelButtonTitle, otherButtonTitles - pass NSString or ESAlertButton
+(id)alertWithTitle:( NSString* )title_
            message:( NSString* )message_
  cancelButtonTitle:( id )cancel_button_title_
  otherButtonTitles:( id )other_button_titles_, ...;

-(void)addAlertButton:( id )alert_button_id_;

-(void)addAlertButtonWithTitle:( NSString* )title_ ation:( JFFSimpleBlock )action_;

+(void)dismissAllAlertViews;

+(void)showAlertWithTitle:( NSString* )title_
              description:( NSString* )description_;

+(void)showErrorWithDescription:( NSString* )description_;
+(void)showInformationWithDescription:( NSString* )description_;

-(void)exclusiveShow;

@end
