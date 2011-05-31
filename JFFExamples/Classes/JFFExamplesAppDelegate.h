//
//  JFFExamplesAppDelegate.h
//  JFFExamples
//
//  Created by vgor on 31.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JFFExamplesViewController;

@interface JFFExamplesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    JFFExamplesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet JFFExamplesViewController *viewController;

@end

