//
//  APRSFIViewController.m
//  iBCNU
//
//  Created by David Ponevac on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APRSFIViewController.h"


@implementation APRSFIViewController

@synthesize webView;
@synthesize APRSClass;

static NSString *_TITLE = @"Map";

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
        // Custom initialization
		[self setAPRSClass:APRSFeed];
    }
    return self;
}//func

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// initial set page title
	self.title = _TITLE;
	
	// put big loader on screen
	progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[progress setHidesWhenStopped:YES];
	[progress setFrame:CGRectMake(145, 185, 30, 30)];
	[self.view addSubview:progress];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationController.navigationBarHidden = NO;
	
	// load aprs.fi site
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://aprs.fi/?lat=%f&lng=%f&mt=m&z=12&timerange=3600", [APRSClass latitude], [APRSClass longitude]]];
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	[webView loadRequest:request];
	
	request = nil;
	url = nil;
}//func	

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{	
	[progress release];
	webView.delegate = nil;
	webView = nil;
	
    [super dealloc];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[progress startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[progress stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[CommonTools showError:_ERR_TITLE_CONN_INVALID message:_ERR_MSG_CONN_INVALID];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[progress stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
