//
//  LogViewController.m
//  iBCNU
//
//  Created by David Ponevac on 4/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LogViewController.h"

static NSString *_TITLE = @"Log";


@implementation LogViewController

@synthesize logTableView;
@synthesize APRSClass;

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Class methods

/**
 * The designated initializer. Override to perform setup that is required before the view is loaded.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
        // Custom initialization
    }//if

    return self;
}//func

/**
 * put field updaters here as this gets called every tab click
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationController.navigationBarHidden = NO;
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 18)];
	[headerView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, 300, 15)];
	[headerLabel setText:[NSString stringWithFormat:@"Data RX: %.3fMB TX: %.3fMB.", [APRSClass dataRX]/1024/1024, [APRSClass dataTX]/1024/1024]];
	[headerLabel setFont:[UIFont systemFontOfSize:15.0]];
	[headerLabel setBackgroundColor:[UIColor clearColor]];
	[headerView addSubview:headerLabel];
	[headerLabel release];
	
	[self.logTableView setTableHeaderView:headerView];
	[headerView release];
	
	// reload count
	count = [APRSClass.aprsLog count];
	
	// table needs to be refreshed
	[self.logTableView reloadData];
}//func

/**
 * Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// clear button
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(toggleClear:)];

	// initial set page title
	self.title = _TITLE;
}//func

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	self.logTableView = nil;
}


- (void)dealloc
{
    [super dealloc];
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Helper methods

/**
 * Enable/disable editing mode for messages
 */
- (void)toggleClear:(UIBarButtonItem *)sender
{
	[APRSClass.aprsLog removeAllObjects];
	
	// reload count
	count = [APRSClass.aprsLog count];
	
	// table needs to be refreshed
	[self.logTableView reloadData];
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
    return count;
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
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}//if
	
	// set the cell properties
	[cell.textLabel setText:[APRSClass.aprsLog objectAtIndex:(count - indexPath.row - 1)]];
	[cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
	[cell.textLabel setLineBreakMode:UILineBreakModeCharacterWrap];
	[cell.textLabel setNumberOfLines:0];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	
    return cell;
}//func


@end
