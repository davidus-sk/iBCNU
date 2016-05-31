//
//  OutboxViewController.h
//  iBCNU
//
//  Created by David Ponevac on 4/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTools.h"
#import "Data.h"


@interface OutboxViewController : UIViewController
{
	// table view with messages
	IBOutlet UITableView *messageTableView;
	
	// messages loaded from db
	NSMutableArray *messages;
	
	// loading indicator
	UIActivityIndicatorView *progress;
}

@property (nonatomic, retain) IBOutlet UITableView *messageTableView;

@end
