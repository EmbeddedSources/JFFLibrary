#import "NSError+Alert.h"

#import "ESAlertView.h"

@implementation NSError (Alert)

-(void)showAlertWithTitle:( NSString* )title_
{
   [ self writeErrorToNSLog ];
   [ ESAlertView showAlertWithTitle: title_ description: [ self localizedDescription ] ];
}

-(void)showErrorAlert
{
   [ self writeErrorToNSLog ];
   [ ESAlertView showErrorWithDescription: [ self localizedDescription ] ];
}

-(void)writeErrorToNSLog
{
   NSLog( @"NSError : %@, domain : %@ code : %d", [ self localizedDescription ], [ self domain ], [ self code ] );
}

@end
