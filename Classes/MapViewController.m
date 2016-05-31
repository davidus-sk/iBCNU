//
//  MapViewController.m
//  iBCNU
//
//  Created by David Ponevac on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController

@synthesize mapView;
@synthesize APRSClass;

static NSString *_TITLE = @"Map";

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
        // Custom initialization
		[self setAPRSClass:APRSFeed];
    }
    return self;
}

/**
 * View did load
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// clear button
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Aprs.fi" style:UIBarButtonItemStylePlain target:self action:@selector(openAprsfi:)];
	
	// initial set page title
	self.title = _TITLE;
	
	// put big loader on screen
	progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[progress setHidesWhenStopped:YES];
	[progress setFrame:CGRectMake(145, 185, 30, 30)];
	[self.view addSubview:progress];
}//func

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationController.navigationBarHidden = NO;
	
	[self.mapView setShowsUserLocation:YES];
}//func	

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
	[progress release];
    [super dealloc];
}

- (void)openAprsfi:(UIBarButtonItem *)sender
{
	[CommonTools openLink:@"http://aprs.fi"];
}//func

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[progress startAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[progress stopAnimating];
	
	[CommonTools showError:_ERR_TITLE_CONN_INVALID message:_ERR_MSG_CONN_INVALID];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[progress stopAnimating];
}


@end
