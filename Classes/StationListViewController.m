//
//  StationListViewController.m
//  iBCNU
//
//  Created by David Ponevac on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StationListViewController.h"
#import "StationCell.h"
#import "WriteMessageViewController.h"


@implementation StationListViewController

@synthesize APRSClass;
@synthesize stationTableView;
@synthesize stations;

static NSString *_TITLE = @"Stations";

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Class methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
        // Custom initialization
    }//if
	
    return self;
}//func

/**
 * View did appear
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Unselect the selected row if any
	NSIndexPath *selection = [self.stationTableView indexPathForSelectedRow];
	if (selection)
	{
		[self.stationTableView deselectRowAtIndexPath:selection animated:YES];
	}//if
	
	//	The scrollbars won't flash unless the tableview is long enough.
	[self.stationTableView flashScrollIndicators];
}//if

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 18)];
	[headerView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, 300, 15)];
	[headerLabel setText:[NSString stringWithFormat:@"Stations within %@km of your location.", [APRSClass filterRange]]];
	[headerLabel setFont:[UIFont systemFontOfSize:15.0]];
	[headerLabel setBackgroundColor:[UIColor clearColor]];
	[headerView addSubview:headerLabel];
	[headerLabel release];
	
	[self.stationTableView setTableHeaderView:headerView];
	[headerView release];
	
	self.stations = [APRSClass.closeStations allKeys];
	
	[self.stationTableView reloadData];
}

/**
 * View did load
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// initial set page title
	self.title = _TITLE;
}//func

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	self.stationTableView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
	self.stations = nil;
	
    [super dealloc];
}//func

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
    return [self.stations count];
}//func

/**
 * Customize the appearance of table view cells.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"StationCell";
	
	StationCell *cell = (StationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StationCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}//if
	
	NSDictionary *stationInfo = [[APRSClass closeStations] objectForKey:[self.stations objectAtIndex:indexPath.row]];
	
	// callsign label
	[cell.stationName setText:[stations objectAtIndex:indexPath.row]];
	
	// date label
	[cell.stationDate setText:[NSString stringWithFormat:@"(%@)", [CommonTools formatTimestamp:[stationInfo objectForKey:@"date"]]]];
	
	stationInfo = nil;
	
    return cell;
}//func

/**
 * If message is clicked
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	WriteMessageViewController *writeController = [[WriteMessageViewController alloc] initWithNibName:@"WriteMessageViewController" bundle:nil];
	[writeController setAPRSClass:APRSClass];
	[writeController.toCallField setText:[stations objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:writeController animated:YES];
	[writeController release];
}//func


@end
