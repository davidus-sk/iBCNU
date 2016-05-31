//
//  InboxViewController.h
//  iBCNU
//
//  Created by David Ponevac on 4/24/09.
//  Copyright 2009 LUCEON LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APRS.h"
#import "Data.h"


@interface InboxViewController : UIViewController
{
	// table view with messages
	IBOutlet UITableView *messageTableView;
	
	// messages loaded from db
	NSMutableArray *messages;
	
	// link back to navig item
	UITabBarItem *barItem;
	
	// data object
	Data *dataClass;
	
	// aprs object
	APRS *APRSClass;
	
	// loading indicator
	UIActivityIndicatorView *progress;
}

@property (nonatomic, retain) IBOutlet UITableView *messageTableView;
@property (nonatomic, assign) UITabBarItem *barItem;
@property (nonatomic, assign) Data *dataClass;
@property (nonatomic, assign) APRS *APRSClass;

@end
