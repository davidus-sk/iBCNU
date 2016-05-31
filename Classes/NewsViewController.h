//
//  NewsViewController.h
//  iBCNU
//
//  Created by David Ponevac on 5/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewsViewController : UIViewController
{
	// table view with messages
	IBOutlet UITableView *newsTableView;
	
	NSMutableArray *rootData;
	
	NSMutableDictionary *currentItem;
	NSMutableString *currentContents;
	
	UIActivityIndicatorView *progress;	
}

@property (nonatomic, retain) IBOutlet UITableView *newsTableView;
@property (nonatomic, retain) NSMutableArray *rootData;

@end
