//
//  StationListViewController.h
//  iBCNU
//
//  Created by David Ponevac on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTools.h"
#import "APRS.h"

@interface StationListViewController : UIViewController
{
	// table view with messages
	IBOutlet UITableView *stationTableView;
	
	// list of stations
	NSArray *stations;
	
	// APRS class
	APRS *APRSClass;
}

@property (nonatomic, retain) IBOutlet UITableView *stationTableView;
@property (nonatomic, retain) NSArray *stations;
@property (nonatomic, assign) APRS *APRSClass;

@end
