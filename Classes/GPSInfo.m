//
//  GPSInfo.m
//  iBCNU
//
//  Created by David Ponevac on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GPSInfo.h"


@implementation GPSInfo;

@synthesize infoTableView;
@synthesize metricSwitch;
@synthesize decimalSwitch;
@synthesize GPSArray;
@synthesize APRSClass;
@synthesize metricOn;

static NSString *_TITLE = @"GPS Data";

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Class methods

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		[self setAPRSClass:APRSFeed];
		self.GPSArray = [[NSMutableArray alloc] initWithCapacity:0];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGPSData:) name:@"_NOTIFY_NEW_GPS_DATA" object:nil];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// initial set page title
	self.title = _TITLE;
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
	[headerView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 200, 18)];
	[headerLabel setText:@"Metric units"];
	[headerLabel setFont:[UIFont systemFontOfSize:18.0]];
	[headerLabel setBackgroundColor:[UIColor clearColor]];
	[headerView addSubview:headerLabel];
	[headerLabel release];
	
	UILabel *decimalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 56, 200, 18)];
	[decimalLabel setText:@"Decimal coords"];
	[decimalLabel setFont:[UIFont systemFontOfSize:18.0]];
	[decimalLabel setBackgroundColor:[UIColor clearColor]];
	[headerView addSubview:decimalLabel];
	[decimalLabel release];
	
	self.metricSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(215, 8, 100, 18)];
	[self.metricSwitch setOn:self.metricOn];
	[self.metricSwitch addTarget:self action:@selector(metricSwitched) forControlEvents:UIControlEventValueChanged];
	[headerView addSubview:self.metricSwitch];
	
	self.decimalSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(215, 52, 100, 18)];
	[self.decimalSwitch setOn:YES];
	[self.decimalSwitch addTarget:self action:@selector(metricSwitched) forControlEvents:UIControlEventValueChanged];
	[headerView addSubview:self.decimalSwitch];
	
	[self.infoTableView setTableHeaderView:headerView];
	[headerView release];
	
	[self newGPSData:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	self.infoTableView = nil;
	self.metricSwitch = nil;
	self.decimalSwitch = nil;
}

- (void)dealloc
{
	[self.GPSArray release];
	
    [super dealloc];
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Switch event
- (void)metricSwitched
{
	[self newGPSData:nil];
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark GPS notification
- (void)newGPSData:(NSNotification *)notif
{
	CLLocation *curData = [self.APRSClass GPSData];
	CLLocationCoordinate2D curCoords = curData.coordinate;
	
	// units
	NSString *dUnit = @"m";
	NSString *sUnit = @"kmh";
	
	if (![self.metricSwitch isOn])
	{
		dUnit = @"ft";
		sUnit = @"mph";
	}
	
	NSString *alt = curData.verticalAccuracy < 0 ? @"unknown" : [NSString stringWithFormat:@"%.0f %@", ([self.metricSwitch isOn] ? curData.altitude : curData.altitude * 3.2808399), dUnit];
	NSString *hA = curData.horizontalAccuracy < 0 ? @"unknown" : [NSString stringWithFormat:@"%.1f %@", ([self.metricSwitch isOn] ? curData.horizontalAccuracy : curData.horizontalAccuracy * 3.2808399), dUnit];
	NSString *vA = curData.verticalAccuracy < 0 ? @"unknown" : [NSString stringWithFormat:@"%.1f %@", ([self.metricSwitch isOn] ? curData.verticalAccuracy : curData.verticalAccuracy * 3.2808399), dUnit];
	NSString *speed = curData.speed < 0 ? @"unknown" : [NSString stringWithFormat:@"%.1f %@", ([self.metricSwitch isOn] ? curData.speed * 3.6 : curData.speed * 2.23693629), sUnit];
	NSString *course = curData.course < 0 ? @"unknown" : [NSString stringWithFormat:@"%.0f ˚", curData.course];
	
	// Custom initialization
	NSArray *newData = [[NSArray alloc] initWithObjects:
					 [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Latitude", @"title",
					  [self.decimalSwitch isOn] ? [NSString stringWithFormat:@"%f", curCoords.latitude] : [GPS latitude2String:curCoords.latitude APRSFormat:NO], @"data", nil
					  ],
					 [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Longitude", @"title",
					  [self.decimalSwitch isOn] ? [NSString stringWithFormat:@"%f", curCoords.longitude] : [GPS longitude2String:curCoords.longitude APRSFormat:NO], @"data", nil
					  ],
					 [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Altitude", @"title",
					  alt, @"data", nil
					  ],
					 [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Horizontal accuracy", @"title",
					  hA, @"data", nil
					  ],
					 [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Vertical accuracy", @"title",
					  vA, @"data", nil
					  ],
					 [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Speed", @"title",
					  speed, @"data", nil
					  ],
					 [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Course", @"title",
					  course, @"data", nil
					  ],
					 nil
					 ];
	
	[self.GPSArray removeAllObjects];
	[self.GPSArray addObjectsFromArray:newData];
	
	[newData release];
	
	[self.infoTableView reloadData];
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Table methods

/**
 * Set number of sections in table
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}//func

/**
 * Customize the number of rows in the table view.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.GPSArray count];
}//func

/**
 * Customize the appearance of table view cells.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
	}//if
	
	NSDictionary *currentItem = [[NSDictionary alloc] initWithDictionary:[self.GPSArray objectAtIndex:indexPath.row]];
	
	// set the cell properties
	[cell.textLabel setText:[currentItem objectForKey:@"title"]];
	[cell.textLabel setFont:[UIFont systemFontOfSize:18.0]];
	
	[cell.detailTextLabel setText:[currentItem objectForKey:@"data"]];
	[cell.detailTextLabel setFont:[UIFont systemFontOfSize:15.0]];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	
    return cell;
}//func


@end
