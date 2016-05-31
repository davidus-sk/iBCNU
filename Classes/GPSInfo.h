//
//  GPSInfo.h
//  iBCNU
//
//  Created by David Ponevac on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "APRS.h"
#import "GPS.h"


@interface GPSInfo : UIViewController
{
	// write table view
	IBOutlet UITableView *infoTableView;
	
	// metric switch
	UISwitch *metricSwitch;
	
	// decimal switch
	UISwitch *decimalSwitch;
	
	// gps data array
	NSMutableArray *GPSArray;
	
	// APRS class
	APRS *APRSClass;
	
	// metric flag
	BOOL metricOn;
}

@property (nonatomic, retain) IBOutlet UITableView *infoTableView;
@property (nonatomic, retain) UISwitch *metricSwitch;
@property (nonatomic, retain) UISwitch *decimalSwitch;
@property (nonatomic, retain) NSMutableArray *GPSArray;
@property (nonatomic, assign) APRS *APRSClass;
@property (nonatomic, assign) BOOL metricOn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed;
- (void)newGPSData:(NSNotification *)notif;

@end
