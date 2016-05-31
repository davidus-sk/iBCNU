//
//  SettingsViewController.h
//  iBCNU
//
//  Created by David Ponevac on 5/21/09.
//  Copyright 2009 LUCEON LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTools.h"
#import "Data.h"
#import "APRS.h"
#import "ControlCenterViewController.h"


@interface SettingsViewController : UIViewController <UITextFieldDelegate>
{
	NSArray *settingsComponents;
	
	Data *dataClass;
	APRS *APRSClass;
	ControlCenterViewController *ccClass;
	
	// icon needs to change
	UIImageView *callsignIcon;
}

@property (nonatomic, retain) NSArray *settingsComponents;
@property (nonatomic, assign) Data *dataClass;
@property (nonatomic, assign) APRS *APRSClass;
@property (nonatomic, assign) ControlCenterViewController *ccClass;
@property (nonatomic, retain) UIImageView *callsignIcon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed dataFeed:(Data *)dataFeed ccFeed:(ControlCenterViewController *)ccFeed;

@end
