//
//  iBCNUAppDelegate.m
//  iBCNU
//
//  Created by David Ponevac on 4/3/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iBCNUAppDelegate.h"


@implementation iBCNUAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// init classes
	aprsClass = [[APRS alloc] init];
	[aprsClass retain];
	
	dataClass = [[Data alloc] init];
	[dataClass setCallsign:[aprsClass callsign]];
	[dataClass retain];
	
	// set status bar color
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	// create the tab bar controller
	tabBarController = [[UITabBarController alloc] init];
	tabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	// CONTROL CENTER view controller
	ControlCenterViewController *ccViewController = [[ControlCenterViewController alloc] initWithNibName:@"ControlCenterViewController" bundle:nil];
	[ccViewController setDataClass:dataClass];
	[ccViewController setAPRSClass:aprsClass];
	UINavigationController *ccNaviController = [[[UINavigationController alloc] initWithRootViewController:ccViewController] autorelease];
	ccNaviController.navigationBarHidden = YES;
	ccNaviController.title = @"iBCNU";
	ccNaviController.tabBarItem.image = [UIImage imageNamed:@"setup.tab.png"];
	[ccViewController release];

	// INBOX view controller - needs to be tracked for badge
	InboxViewController *inboxViewController = [[InboxViewController alloc] initWithNibName:@"InboxViewController" bundle:nil];
	[inboxViewController setAPRSClass:aprsClass];
	inboxNaviController = [[[UINavigationController alloc] initWithRootViewController:inboxViewController] autorelease];
	inboxNaviController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	inboxNaviController.title = @"Inbox";
	inboxNaviController.tabBarItem.image = [UIImage imageNamed:@"inbox.tab.png"];
	[inboxViewController setBarItem:[inboxNaviController tabBarItem]];
	[inboxViewController release];

	// OUTBOX view controller
	OutboxViewController *outboxViewController = [[OutboxViewController alloc] initWithNibName:@"OutboxViewController" bundle:nil];
	UINavigationController *outboxNaviController = [[[UINavigationController alloc] initWithRootViewController:outboxViewController] autorelease];
	outboxNaviController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	outboxNaviController.title = @"Outbox";
	outboxNaviController.tabBarItem.image = [UIImage imageNamed:@"outbox.tab.png"];
	[outboxViewController release];

	// WRITE view controller
	WriteMessageViewController *writeViewController = [[WriteMessageViewController alloc] initWithNibName:@"WriteMessageViewController" bundle:nil];
	[writeViewController setAPRSClass:aprsClass];
	UINavigationController *writeNaviController = [[[UINavigationController alloc] initWithRootViewController:writeViewController] autorelease];
	writeNaviController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	writeNaviController.title = @"Compose";
	writeNaviController.tabBarItem.image = [UIImage imageNamed:@"compose.tab.png"];
	[writeViewController release];

	// ABOUT view controller
	AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	UINavigationController *aboutNaviController = [[[UINavigationController alloc] initWithRootViewController:aboutViewController] autorelease];
	aboutNaviController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	aboutNaviController.title = @"About";
	aboutNaviController.tabBarItem.image = [UIImage imageNamed:@"about.tab.png"];
	[aboutViewController release];
	
	// NEWS view controller
	NewsViewController *newsViewController = [[NewsViewController alloc] initWithNibName:@"NewsViewController" bundle:nil];
	UINavigationController *newsNaviController = [[[UINavigationController alloc] initWithRootViewController:newsViewController] autorelease];
	newsNaviController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	newsNaviController.title = @"iBCNU News";
	newsNaviController.tabBarItem.image = [UIImage imageNamed:@"news.tab.png"];
	[newsViewController release];
	
	// STATION view controller
	StationListViewController *stationViewController = [[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil];
	[stationViewController setAPRSClass:aprsClass];
	UINavigationController *stationNaviController = [[[UINavigationController alloc] initWithRootViewController:stationViewController] autorelease];
	stationNaviController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	stationNaviController.title = @"Stations";
	stationNaviController.tabBarItem.image = [UIImage imageNamed:@"stations.tab.png"];
	[stationViewController release];
	
	// HELP view controller
	HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
	UINavigationController *helpNaviController = [[[UINavigationController alloc] initWithRootViewController:helpViewController] autorelease];
	helpNaviController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	helpNaviController.title = @"Help";
	helpNaviController.tabBarItem.image = [UIImage imageNamed:@"help.tab.png"];
	[helpViewController release];
	
	// add the to tab bar
	tabBarController.viewControllers = [NSArray arrayWithObjects:
										ccNaviController,
										writeNaviController,
										inboxNaviController,
										stationNaviController,
										outboxNaviController,
										aboutNaviController,
										newsNaviController,
										helpNaviController,
										nil];

	// configure and show the win
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
	// notification receiver from APRS class
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgsReceived:) name:@"_NOTIFY_NEW_MSG_RCVD" object:nil];
}//func

/**
 * Execute on new notification
 */
- (void) msgsReceived:(NSNotification *)notif
{	
	int messages = 0;
	
	if ([Data connectToDB])
	{
		messages = [Data countNewMessages:@"tblInbox"];
		[Data closeDB];
	}//if
	
	// update badge indicator
	NSArray *ctrl = [tabBarController viewControllers];
	NSUInteger index = [ctrl indexOfObject:inboxNaviController];
	UINavigationController *inboxCtrl = [ctrl objectAtIndex:index];
	inboxCtrl.tabBarItem.badgeValue = messages == 0 ? nil : [NSString stringWithFormat:@"%d", messages];
	
	// vibrate the device
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}//func

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	if ([aprsClass lastPing] != nil)
	{
		NSDate *now = [[NSDate alloc] init];
		NSTimeInterval interval =  [now timeIntervalSinceDate:[aprsClass lastPing]];
		
		if (interval > 60)
		{
			// try to connect via new thread
			[NSThread detachNewThreadSelector:@selector(connectToAPRSThreaded) toTarget:self withObject:nil];

			// removed the threaded above
			//[self connectToAPRSThreaded];
		}//if
		
		[now release];
	}//if
}//func

/**
 * call aprs connect in new thread
 */
- (void)connectToAPRSThreaded
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[aprsClass insertIntoLog:@"Waking up... Connecting..."];
	
	[aprsClass connectToAPRS];
	
	[pool release];
}//func


- (void)applicationWillTerminate:(UIApplication *)application
{
	// Save data if appropriate
	[CommonTools saveToFile:[NSDate date] forTag:@"lastUse"];
}


- (void)dealloc
{
	[aprsClass release];
	[dataClass release];
	[tabBarController release];
	[inboxNaviController release];
	[window release];
	
	[super dealloc];
}

@end
