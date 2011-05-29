#import <Foundation/Foundation.h>

@interface NSError (Alert)

-(void)showAlertWithTitle:( NSString* )title_;
-(void)showErrorAlert;

-(void)writeErrorToNSLog;

@end
