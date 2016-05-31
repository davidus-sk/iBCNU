//
//  ControlCenterViewController.m
//  iBCNU
//
//  Created by David Ponevac on 5/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ControlCenterViewController.h"
#import "SettingsViewController.h"
#import "APRSFIViewController.h"
#import "LogViewController.h"
#import "GPSInfo.h"


@implementation ControlCenterViewController

// GUI
@synthesize callsignLabel;
@synthesize coordsLabel;
@synthesize locatorLabel;
@synthesize UTCLabel;
@synthesize beaconsLabel;
@synthesize cdownLabel;

@synthesize busyIndicator;
@synthesize linkIndicator;
@synthesize locIndicator;
@synthesize msgIndicator;
@synthesize posIndicator;
@synthesize loaderIndicator;
@synthesize speedIndicator;

@synthesize beaconNowButton;
@synthesize linkNowButton;
@synthesize beaconOffButton;
@synthesize int1Button;
@synthesize int2Button;
@synthesize int3Button;

@synthesize cDownBar;

@synthesize speedLabel;
@synthesize speedUnitLabel;

@synthesize settingsButton;
@synthesize locButton;
@synthesize posButton;
@synthesize cintButton;
@synthesize mapButton;
@synthesize logButton;
@synthesize dscrButton;
@synthesize afskButton;
@synthesize filButton;
@synthesize gpsButton;
@synthesize prsButton;

// times
@synthesize UTCTimer;
@synthesize cDownTimer;

// misc
@synthesize beaconInterval;
@synthesize customInterval;
@synthesize cDownInterval;
@synthesize beaconOn;
@synthesize sendOnPos;
@synthesize scrDisabled;
@synthesize afskOut;
@synthesize metricOn;

// external classes
@synthesize dataClass;
@synthesize APRSClass;

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Instance methods

/**
 * The designated initializer. Override to perform setup that is required before the view is loaded.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
        // start UTC timer
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(fireUTCTimer:) userInfo:nil repeats:YES];
		[self setUTCTimer:timer];
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// stat GPS service
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.distanceFilter = 50.0;
		[locationManager startUpdatingLocation];
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// read settings if any
		NSDictionary *appSettings;
		NSArray *appSettingsKeys = [[NSArray alloc] init];
		NSString *filePath = [CommonTools getDataFilePath:_DATA_FILE];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		{
			appSettings = [[NSDictionary alloc] initWithContentsOfFile:filePath];
			if ([appSettings count] > 0)
			{
				appSettingsKeys = [appSettings allKeys];
			}//if
		}//if
		
		// see if metric system is to be used
		self.metricOn = [appSettingsKeys containsObject:_TAG_METRIC] ? [[appSettings objectForKey:_TAG_METRIC] boolValue] : YES;
		
		// set initial beacon status
		self.beaconOn = [appSettingsKeys containsObject:_TAG_BEACON] ? [[appSettings objectForKey:_TAG_BEACON] boolValue] : NO;
		
		// set whether to send location on position change
		self.sendOnPos = [appSettingsKeys containsObject:@"_SEND_ON_POS"] ? [[appSettings objectForKey:@"_SEND_ON_POS"] boolValue] : NO;
		
		// set disable screen
		self.scrDisabled = [appSettingsKeys containsObject:@"_SCR_DISABLED"] ? [[appSettings objectForKey:@"_SCR_DISABLED"] boolValue] : NO;
		
		// set stored interval
		self.beaconInterval = [appSettingsKeys containsObject:_TAG_INTERVAL] ? [appSettings objectForKey:_TAG_INTERVAL] : [NSNumber numberWithInt:60];
		self.beaconInterval = [self.beaconInterval intValue] < 10 ? [NSNumber numberWithInt:60] : self.beaconInterval;
		
		// set stored custom interval
		self.customInterval = [appSettingsKeys containsObject:_TAG_CINTERVAL] ? [appSettings objectForKey:_TAG_CINTERVAL] : nil;
		self.customInterval = [self customInterval] == nil || [self.customInterval intValue] < 10 ? nil : [self customInterval];
		
		// cleanup
		filePath = nil;
		appSettings = nil;
		appSettingsKeys = nil;
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// notification receiver
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconsSent:) name:@"_NOTIFY_NEW_BCN_SNT" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotify:) name:@"_NOTIFY_CONN_CHANGED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusMsgChange:) name:@"_NOTIFY_STATUS_MSG_CHANGED" object:nil];
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
    }//if

    return self;
}//func

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationBarHidden = YES;
	
	// load some settings that can be changed in settings panel
	
	// show callsign on display
	[callsignLabel setText:[APRSClass callsign] == nil ? @"NO CALL" : [APRSClass callsign]];
	
	// set core loc distance filter
	locationManager.distanceFilter = [[APRSClass distanceRange] intValue];
	
	// set stored msg if any
	if (([APRSClass statusMessage] == nil) || [[APRSClass statusMessage] isEqualToString:@""])
	{
		[msgIndicator setImage:[UIImage imageNamed:@"msg.off.png"]];
	}
	else
	{
		[msgIndicator setImage:[UIImage imageNamed:@"msg.on.png"]];
	}//if
	
	// disable cint button
	if ([self customInterval] == nil)
	{
		[self.cintButton setEnabled:NO];
	}
	else
	{
		[self.cintButton setEnabled:YES];
	}//if
	
	// set color for dscr button if activated
	if ([self scrDisabled])
	{
		[self.dscrButton setTitleColor:[UIColor colorWithRed:0.0 green:0.682 blue:0.937 alpha:1.0] forState:UIControlStateNormal];
		
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}//if
	
	// sanity check - if callsign empty, disable manipulation buttons
	if ([APRSClass callsign] == nil)
	{
		[beaconNowButton setEnabled:NO];
		[linkNowButton setEnabled:NO];
		[beaconOffButton setEnabled:NO];
	}
	else
	{
		[beaconNowButton setEnabled:YES];
		[beaconOffButton setEnabled:YES];
		
		if (![APRSClass connected])
		{
			[linkNowButton setImage:[UIImage imageNamed:@"link_now.on.png"] forState:UIControlStateNormal];
			[linkNowButton setEnabled:YES];
		}//if
	}//if
	
}//func

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// fire first UTC timer
	[self fireUTCTimer:nil];
	
	// init some base vars
	[coordsLabel setText:@"Acquiring..."];
	[locatorLabel setText:@"Acquiring..."];
	
	// set initial beacon status
	if ([self beaconOn])
	{
		[beaconOffButton setImage:[UIImage imageNamed:@"bcn_off.on.png"] forState:UIControlStateNormal];
	}//if
	
	// set whether to send locator
	if ([APRSClass sendLoc])
	{
		[locIndicator setImage:[UIImage imageNamed:@"loc.on.png"]];
	}//if
	
	// set whether to send location on position change
	if ([self sendOnPos])
	{
		[posIndicator setImage:[UIImage imageNamed:@"pos.on.png"]];
	}//if
	
	// launch the beacon timer
	switch ([self.beaconInterval intValue])
	{
		case 60:
			[self toggleInterval:int1Button];
			break;
		case 120:
			[self toggleInterval:int2Button];
			break;
		case 300:
			[self toggleInterval:int3Button];
			break;
		default:
			[self toggleInterval:nil];
			break;
	}//switch
	
	// nastav speed indicator
	self.speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, 82, 55)];
	[self.speedLabel setTextAlignment:UITextAlignmentCenter];
	[self.speedLabel setFont:[UIFont boldSystemFontOfSize:50]];
	[self.speedLabel setAdjustsFontSizeToFitWidth:YES];
	[self.speedLabel setBackgroundColor:[UIColor clearColor]];
	[self.speedLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
	
	self.speedUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 50, 82, 15)];
	[self.speedUnitLabel setTextAlignment:UITextAlignmentCenter];
	[self.speedUnitLabel setFont:[UIFont boldSystemFontOfSize:15]];
	[self.speedUnitLabel setBackgroundColor:[UIColor clearColor]];
	[self.speedUnitLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
	
	[self.speedIndicator addSubview:self.speedLabel];
	[self.speedIndicator addSubview:self.speedUnitLabel];
}//func

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
    [super dealloc];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Notify methods

/**
 * Notification after connection status change
 */
- (void)beaconsSent:(NSNotification *)notif
{
	[beaconsLabel setText:[NSString stringWithFormat:@"%04d",[APRSClass numBeaconsSent]]];
}//if

/**
 * Notification after connection status change
 */
- (void)connectionNotify:(NSNotification *)notif
{
	if ([APRSClass connected])
	{
		// APRS connected icon
		[linkIndicator setImage:[UIImage imageNamed:@"link.on.png"]];
		
		// show disconnect button
		[linkNowButton setImage:[UIImage imageNamed:@"link_disc.on.png"] forState:UIControlStateNormal];
		
		// enable custom filter
		[self.filButton setEnabled:YES];
	}
	else
	{
		// APRS connected icon
		[linkIndicator setImage:[UIImage imageNamed:@"link.off.png"]];
		
		// show button
		[linkNowButton setImage:[UIImage imageNamed:@"link_now.on.png"] forState:UIControlStateNormal];
		
		// enable custom filter
		[self.filButton setEnabled:NO];
	}//if
	
	[busyIndicator setImage:[UIImage imageNamed:@"busy.off.png"]];
	[loaderIndicator stopAnimating];
	
	// make sure callsign is not empty
	if (![APRSClass validateCallsign:[callsignLabel text]])
	{
		[callsignLabel setText:@"NO CALL"];
		[linkNowButton setImage:[UIImage imageNamed:@"link_now.off.png"] forState:UIControlStateNormal];
		
		[APRSClass disconnectFromAPRS];
	}//if
}//func

/**
 * Notification after connection status change
 */
- (void)statusMsgChange:(NSNotification *)notif
{
	if (([APRSClass statusMessage] == nil) || ([APRSClass.statusMessage compare:@""] == NSOrderedSame))
	{
		[msgIndicator setImage:[UIImage imageNamed:@"msg.off.png"]];
	}
	else
	{
		[msgIndicator setImage:[UIImage imageNamed:@"msg.on.png"]];
	}//if
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Location methods

/**
 * GPS is reporting new location, update needed fields
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	CLLocationCoordinate2D curCoords = newLocation.coordinate;
	
	// set all GPS data
	[APRSClass setGPSData:newLocation];
	
	// update coord labels
	[coordsLabel setText:[NSString stringWithFormat:@"%@,%@", [GPS latitude2String:curCoords.latitude APRSFormat:NO], [GPS longitude2String:curCoords.longitude APRSFormat:NO]]];
	[locatorLabel setText:[GPS getGridSquare:1 longitude:curCoords.longitude latitude:curCoords.latitude]];
	
	// set coords for APRS
	[APRSClass setHorizontalAccuracy:newLocation.horizontalAccuracy];
	[APRSClass setLatitude:curCoords.latitude];
	[APRSClass setLongitude:curCoords.longitude];
	
	// convert mps to knots
	[APRSClass setSpeed:newLocation.speed > 0 ? (newLocation.speed * 1.9438444924406) : 0];
	[APRSClass setCourse:newLocation.course > 0 ? newLocation.course : 0];
	
	// show speed on-screen indicator
	if (newLocation.speed > 0)
	{
	//	[APRSClass insertIntoLog:[NSString stringWithFormat:@"Detected speed of %4.0fm/s (%4.0fknots).", newLocation.speed, (newLocation.speed * 1.9438444924406)]];
		[self.speedLabel setText:[NSString stringWithFormat:@"%.0f", self.metricOn ? newLocation.speed * 3.6 : newLocation.speed * 2.23693629]];
		[self.speedUnitLabel setText:self.metricOn ? @"kmh" : @"mph"];
		[self.speedIndicator setHidden:NO];
	}
	else
	{
		[self.speedIndicator setHidden:YES];
	}
	
	// convert meters to feet
	[APRSClass setAltitudeAccuracy:newLocation.verticalAccuracy];
	[APRSClass setAltitude:(newLocation.altitude * 3.2808399)];
	
	// post new data notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"_NOTIFY_NEW_GPS_DATA" object:nil];
	
	// enable GPS button
	[self.gpsButton setEnabled:YES];
	
	// send out beacon on first fix but avoid duplicate messages
	if ([self beaconOn] && ([APRSClass numBeaconsSent] == 0) && (oldLocation == NULL))
	{
		[APRSClass insertIntoLog:@"First fix..."];
		
		[NSThread detachNewThreadSelector:@selector(sendAPRSBeaconThreaded) toTarget:self withObject:nil];
		
		return;
	}//if
	
	// send out beacon on possition change but dont interfere with the first interval beacon
	if (oldLocation != NULL)
	{
		if ([self sendOnPos] && ([newLocation getDistanceFrom:oldLocation] >= manager.distanceFilter) && ![APRSClass beaconing])
		{
			[APRSClass insertIntoLog:[NSString stringWithFormat:@"Position change of %.0f %s.", self.metricOn ? manager.distanceFilter : manager.distanceFilter * 3.2808399, self.metricOn ? "m" : "ft"]];
			
			[NSThread detachNewThreadSelector:@selector(sendAPRSBeaconThreaded) toTarget:self withObject:nil];
		}//if
	}//if
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Thread methods

- (void)startAcvityIndicator
{
	[loaderIndicator startAnimating];
	[busyIndicator setImage:[UIImage imageNamed:@"busy.on.png"]];
}//if

- (void)stopAcvityIndicator
{
	[loaderIndicator stopAnimating];
	[busyIndicator setImage:[UIImage imageNamed:@"busy.off.png"]];
}//if

/**
 * call aprs connect in new thread
 */
- (void)sendAPRSBeaconThreaded
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self performSelectorOnMainThread:@selector(startAcvityIndicator) withObject:nil waitUntilDone:false];

	[APRSClass sendAPRSBeacon];
	
	[self performSelectorOnMainThread:@selector(stopAcvityIndicator) withObject:nil waitUntilDone:false];
	
	[pool release];
}//func

/**
 * call aprs connect in new thread
 */
- (void)connectToAPRSThreaded
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self performSelectorOnMainThread:@selector(startAcvityIndicator) withObject:nil waitUntilDone:false];
	
	[APRSClass connectToAPRS];
	
	[self performSelectorOnMainThread:@selector(stopAcvityIndicator) withObject:nil waitUntilDone:false];
	
	[pool release];
}//func


#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark GUI methods

- (IBAction)sendBeaconNow:(UIButton *)sender
{
	[NSThread detachNewThreadSelector:@selector(sendAPRSBeaconThreaded) toTarget:self withObject:nil];
}//func

- (IBAction)reconnectNow:(UIButton *)sender
{
	// dual functionality - connect/disconnect
	if ([APRSClass connected])
	{
		[APRSClass disconnectFromAPRS];
	}
	else
	{
		[NSThread detachNewThreadSelector:@selector(connectToAPRSThreaded) toTarget:self withObject:nil];
	}//if
}//func

/**
 * Turn beacon on and off
 */
- (IBAction)toggleBeacon:(UIButton *)sender
{
	[self setBeaconOn: [self beaconOn] ? NO : YES];

	if ([self beaconOn])
	{
		[beaconOffButton setImage:[UIImage imageNamed:@"bcn_off.on.png"] forState:UIControlStateNormal];
		
		// set reset the interval
		cDownInterval = [beaconInterval intValue];

		[self startCDownTimer];
	}
	else
	{
		[beaconOffButton setImage:[UIImage imageNamed:@"bcn_off.off.png"] forState:UIControlStateNormal];
		
		[self stopCDownTimer];
	}//if
	
	// store the new settings
	[CommonTools saveToFile:[self beaconOn] ? @"YES" : @"NO" forTag:_TAG_BEACON];
}//func

/**
 * Change beacon interval
 */
- (IBAction)toggleInterval:(UIButton *)sender
{
	int interval = sender == nil ? [self.customInterval intValue] : sender.tag;
	
	if ([self customInterval] == nil)
	{
		[self.cintButton setEnabled:NO];
	}
	else
	{
		[self.cintButton setTitleColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0] forState:UIControlStateNormal];
	}//if

	// highlight clicked button
	switch (interval)
	{
		case 60:
			[int1Button setImage:[UIImage imageNamed:@"int1.on.png"] forState:UIControlStateNormal];
			[int2Button setImage:[UIImage imageNamed:@"int2.off.png"] forState:UIControlStateNormal];
			[int3Button setImage:[UIImage imageNamed:@"int3.off.png"] forState:UIControlStateNormal];
			
			[self setBeaconInterval:[NSNumber numberWithInt:60]];
			cDownInterval = [beaconInterval intValue];
			break;
		case 120:
			[int1Button setImage:[UIImage imageNamed:@"int1.off.png"] forState:UIControlStateNormal];
			[int2Button setImage:[UIImage imageNamed:@"int2.on.png"] forState:UIControlStateNormal];
			[int3Button setImage:[UIImage imageNamed:@"int3.off.png"] forState:UIControlStateNormal];
			
			[self setBeaconInterval:[NSNumber numberWithInt:2*60]];
			cDownInterval = [beaconInterval intValue];
			break;
		case 300:
			[int1Button setImage:[UIImage imageNamed:@"int1.off.png"] forState:UIControlStateNormal];
			[int2Button setImage:[UIImage imageNamed:@"int2.off.png"] forState:UIControlStateNormal];
			[int3Button setImage:[UIImage imageNamed:@"int3.on.png"] forState:UIControlStateNormal];
			
			[self setBeaconInterval:[NSNumber numberWithInt:5*60]];
			cDownInterval = [beaconInterval intValue];
			break;
		default:
			self.beaconInterval = self.customInterval;
			if ([self.beaconInterval intValue] < 10)
			{
				return;
			}//if

			[int1Button setImage:[UIImage imageNamed:@"int1.off.png"] forState:UIControlStateNormal];
			[int2Button setImage:[UIImage imageNamed:@"int2.off.png"] forState:UIControlStateNormal];
			[int3Button setImage:[UIImage imageNamed:@"int3.off.png"] forState:UIControlStateNormal];
			[cintButton setTitleColor:[UIColor colorWithRed:0.0 green:0.682 blue:0.937 alpha:1.0] forState:UIControlStateNormal];
			
			cDownInterval = [beaconInterval intValue];
			break;
	}//switch
	
	// update display
	// components
	int minutes = (int)(cDownInterval / 60);
	int seconds = cDownInterval - (minutes * 60);
	
	// show on screen
	[cdownLabel setText:[NSString stringWithFormat:@"%02d:%02d",minutes,seconds]];
	
	
	// save for future
	[CommonTools saveToFile:[NSNumber numberWithInt:sender.tag] forTag:_TAG_INTERVAL];
	
	// restart timer
	if (beaconOn)
	{
		[self startCDownTimer];
	}//if
}//func

- (IBAction)callSettings:(UIButton *)sender
{
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil APRSFeed:APRSClass dataFeed:dataClass ccFeed:self];
	[self.navigationController pushViewController:settingsViewController animated:NO];
	[settingsViewController release];
}//func

- (IBAction)callMap:(UIButton *)sender
{
	//MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil APRSFeed:APRSClass];
	//[self.navigationController pushViewController:mapViewController animated:NO];
	//[mapViewController release];
	
	APRSFIViewController *mapViewController = [[APRSFIViewController alloc] initWithNibName:@"APRSFIViewController" bundle:nil APRSFeed:APRSClass];
	[self.navigationController pushViewController:mapViewController animated:NO];
	[mapViewController release];
}//func

- (IBAction)callLog:(UIButton *)sender
{
	LogViewController *logViewController = [[LogViewController alloc] initWithNibName:@"LogViewController" bundle:nil];
	[logViewController setAPRSClass:APRSClass];
	[self.navigationController pushViewController:logViewController animated:NO];
	[logViewController release];
}//func

/**
 * Enable custom interval, replace the default interval
 */
- (IBAction)callCInt:(UIButton *)sender
{
	[self toggleInterval:nil];
}//func

- (IBAction)callLoc:(UIButton *)sender
{
	if ([APRSClass sendLoc])
	{
		[APRSClass setSendLoc:NO];
		[locIndicator setImage:[UIImage imageNamed:@"loc.off.png"]];
	}
	else
	{
		[APRSClass setSendLoc:YES];
		[locIndicator setImage:[UIImage imageNamed:@"loc.on.png"]];
	}//if
	
	// store the new settings
	[CommonTools saveToFile:[APRSClass sendLoc] ? @"YES" : @"NO" forTag:@"_SEND_LOC"];
}//func

- (IBAction)callPos:(UIButton *)sender
{
	if ([self sendOnPos])
	{
		[self setSendOnPos:NO];
		[posIndicator setImage:[UIImage imageNamed:@"pos.off.png"]];
	}
	else
	{
		[self setSendOnPos:YES];
		[posIndicator setImage:[UIImage imageNamed:@"pos.on.png"]];
	}//if
	
	// store the new settings
	[CommonTools saveToFile:[self sendOnPos] ? @"YES" : @"NO" forTag:@"_SEND_ON_POS"];
}//func

- (IBAction)callDScr:(UIButton *)sender
{
	if ([self scrDisabled])
	{
		[self setScrDisabled:NO];
		[self.dscrButton setTitleColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0] forState:UIControlStateNormal];
		
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
	else
	{
		[self setScrDisabled:YES];
		[self.dscrButton setTitleColor:[UIColor colorWithRed:0.0 green:0.682 blue:0.937 alpha:1.0] forState:UIControlStateNormal];
		
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}//if
	
	// store the new settings
	[CommonTools saveToFile:[self scrDisabled] ? @"YES" : @"NO" forTag:@"_SCR_DISABLED"];
}//func

- (IBAction)callAfsk:(UIButton *)sender
{
	if ([self afskOut])
	{
		[self setAfskOut:NO];
		[self.afskButton setTitleColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0] forState:UIControlStateNormal];
	}
	else
	{
		[self setAfskOut:YES];
		[self.afskButton setTitleColor:[UIColor colorWithRed:0.0 green:0.682 blue:0.937 alpha:1.0] forState:UIControlStateNormal];
	}//if
	
	// store the new settings
	[CommonTools saveToFile:[self afskOut] ? @"YES" : @"NO" forTag:@"_AFSK_OUT"];
	
	AFSK *afskClass = [[AFSK alloc] init];
	
	[afskClass buildPacket:[NSArray arrayWithObjects:@"CQ",[APRSClass callsign],@"RELAY",nil]  control:0x03 pid:0x0F payload:@"Test"];
	
	[afskClass sendAFSKPacket];
	//[afskClass dealloc];
}//func

/**
 * Show GPS info
 */
- (IBAction)callGPS:(UIButton *)sender
{
	GPSInfo *GPSInfoController = [[GPSInfo alloc] initWithNibName:@"GPSInfo" bundle:nil APRSFeed:APRSClass];
	[GPSInfoController setMetricOn:self.metricOn];
	[self.navigationController pushViewController:GPSInfoController animated:NO];
	[GPSInfoController release];
}//func

/**
 * Enable user to send custom filter
 */
- (IBAction)callFil:(UIButton *)sender
{
	UIAlertView *filterView = [[UIAlertView alloc] initWithTitle:@"Custom filter" message:@"\n" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Send", nil];
	
	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
	[filterView setTransform:myTransform];
	
	UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
	[myTextField setBackgroundColor:[UIColor whiteColor]];
	[myTextField setReturnKeyType:UIReturnKeyDone];
	[myTextField setDelegate:self];
	[myTextField setText:@"# filter"];
	[myTextField setTag:99];
	
	[filterView addSubview:myTextField];
	[filterView show];
	
	[filterView release];
	[myTextField release];
}//func

/**
 * Show presets - callsign, ssid and icon
 */
- (IBAction)callPrs:(UIButton *)sender
{
	LogViewController *logViewController = [[LogViewController alloc] initWithNibName:@"LogViewController" bundle:nil];
	[logViewController setAPRSClass:APRSClass];
	[self.navigationController pushViewController:logViewController animated:NO];
	[logViewController release];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Alert view

/**
 * Send custom filter
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		UITextField *myTextField = (UITextField *)[alertView viewWithTag:99];
		
		NSString *filter = [myTextField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// check if it valid
		if (![filter isEqualToString:@""] && ![filter isEqualToString:@"# filter"])
		{
			[APRSClass sendCustomAPRSFilter:filter];
		}
		
		filter = nil;
		myTextField = nil;
	}
}

/**
 * Hide the keyboard
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Timer methods

/**
 * UTC clock timer
 */
- (void)fireUTCTimer:(NSTimer *)theTimer
{
	// get date
	NSDate *now = [NSDate date];
	
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	
	NSDateComponents *comps = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:now]; 
	
	NSInteger hours = [comps hour];
	NSInteger minutes = [comps minute];

	// show on screen
	[UTCLabel setText:[NSString stringWithFormat:@"%02d:%02d",hours,minutes]];
	
	[cal release];
}//func

/**
 * Start count down timer
 */
- (void)startCDownTimer
{
	// stop the timer first
	[self stopCDownTimer];
	
	// if something went wront, fix
	if ((beaconInterval == nil) || [beaconInterval intValue] <= 0)
	{
		[self toggleInterval:int1Button];
		
		return;
	}//if
	
	// set the recuring interval
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fireCDownTimer:) userInfo:nil repeats:YES];
    [self setCDownTimer:timer];
	
	NSLog(@"Start CDown\n");
}//func

/**
 * Stop count down timer
 */
- (void)stopCDownTimer
{
    [cDownTimer invalidate];
    [self setCDownTimer:nil];
	
	NSLog(@"Stop CDown\n");
}//func

/**
 * Count down timer
 */
- (void)fireCDownTimer:(NSTimer *)theTimer
{
	// decrement
	cDownInterval--;
	
	// components
	int minutes = (int)(cDownInterval / 60);
	int seconds = cDownInterval - (minutes * 60);
	
	// show on screen
	[cdownLabel setText:[NSString stringWithFormat:@"%02d:%02d",minutes,seconds]];
	
	// shrink bar
	CGFloat height = (cDownInterval / [beaconInterval floatValue]) * 110;
	CGRect barFrame = CGRectMake(285, 20, 15, height);
	[cDownBar setFrame:barFrame];

	if (cDownInterval == 0)
	{
		// fire the beacon
		[NSThread detachNewThreadSelector:@selector(sendAPRSBeaconThreaded) toTarget:self withObject:nil];
		
		// reset timer
		cDownInterval = [beaconInterval intValue];
		
		// reset bar
		[cDownBar setFrame:CGRectMake(285, 20, 15, 110)];
	}//if
}//func


@end
