//
//  LogViewController.h
//  iBCNU
//
//  Created by David Ponevac on 4/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTools.h"
#import "APRS.h"


@interface LogViewController : UIViewController
{
	// write table view
	IBOutlet UITableView *logTableView;
	
	// APRS object
	APRS *APRSClass;
	
	// num log messages
	NSInteger count;
}

@property (nonatomic, retain) IBOutlet UITableView *logTableView;
@property (nonatomic, assign) APRS *APRSClass;

@end
