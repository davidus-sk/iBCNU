//
//  iBCNUAppDelegate.h
//  iBCNU
//
//  Created by David Ponevac on 4/3/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlCenterViewController.h"
#import "InboxViewController.h"
#import "OutboxViewController.h"
#import "WriteMessageViewController.h"
#import "AboutViewController.h"
#import "LogViewController.h"
#import "NewsViewController.h"
#import "StationListViewController.h"
#import "HelpViewController.h"
#import "CommonTools.h"
#import "APRS.h"
#import "Data.h"
#import "AudioToolbox/AudioServices.h"


@interface iBCNUAppDelegate : NSObject <UIApplicationDelegate>
{
	// main window
	UIWindow *window;
	
	// tab bar
	IBOutlet UITabBarController *tabBarController;
	
	// INBOX navi controller - for tracking
	UINavigationController *inboxNaviController;
	
	// APRS object to be fed to other classes
	APRS *aprsClass;
	
	// Data and msg management class
	Data *dataClass;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end

