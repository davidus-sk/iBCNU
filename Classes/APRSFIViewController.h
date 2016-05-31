//
//  APRSFIViewController.h
//  iBCNU
//
//  Created by David Ponevac on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APRS.h"
#import "CommonTools.h"


@interface APRSFIViewController : UIViewController
{
	IBOutlet UIWebView *webView;
	
	APRS *APRSClass;
	
	// loading indicator
	UIActivityIndicatorView *progress;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, assign) APRS *APRSClass;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed;

@end
