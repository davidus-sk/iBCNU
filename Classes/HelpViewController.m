//
//  HelpViewController.m
//  iBCNU
//
//  Created by David Ponevac on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController

@synthesize settingsComponents;

static NSString *_TITLE = @"Help";

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		NSArray *displayItems = [NSArray arrayWithObjects:
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Data is being transmitted to APRS server",@"itemTitle",[UIImage imageNamed:@"busy.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Link to APRS server is established",@"itemTitle",[UIImage imageNamed:@"link.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Grid locator instead of GPS coords is used",@"itemTitle",[UIImage imageNamed:@"loc.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Custom message is attached to APRS position packet",@"itemTitle",[UIImage imageNamed:@"msg.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Data is sent to server on GPS position change",@"itemTitle",[UIImage imageNamed:@"pos.on.png"],@"icon",nil],
								 nil];
		
		NSArray *controlItems = [NSArray arrayWithObjects:
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Transmit beacon data now",@"itemTitle",[UIImage imageNamed:@"bcn_now.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Establish link to APRS server now",@"itemTitle",[UIImage imageNamed:@"link_now.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Disconnect from APRS server",@"itemTitle",[UIImage imageNamed:@"link_disc.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Enable/disable automatic beacon",@"itemTitle",[UIImage imageNamed:@"bcn_off.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Send beacon data every minute",@"itemTitle",[UIImage imageNamed:@"int1.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Send beacon data every 2 minutes",@"itemTitle",[UIImage imageNamed:@"int2.on.png"],@"icon",nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:@"Send beacon data every 5 minutes",@"itemTitle",[UIImage imageNamed:@"int3.on.png"],@"icon",nil],
								 nil];
		
		NSArray *buttonItems = [NSArray arrayWithObjects:
								[NSDictionary dictionaryWithObjectsAndKeys:@"LOC - Enable/disable grid locator beacon",@"itemTitle",nil],
								[NSDictionary dictionaryWithObjectsAndKeys:@"POS - Enable/disable beacon on position change",@"itemTitle",nil],
								[NSDictionary dictionaryWithObjectsAndKeys:@"CINT - Enable custom beacon interval",@"itemTitle",nil],
								[NSDictionary dictionaryWithObjectsAndKeys:@"MAP - Plot your location on Google Maps",@"itemTitle",nil],
								[NSDictionary dictionaryWithObjectsAndKeys:@"LOG - Show the communications log",@"itemTitle",nil],
								[NSDictionary dictionaryWithObjectsAndKeys:@"DSCR - Disable phone's screensaver",@"itemTitle",nil],
								[NSDictionary dictionaryWithObjectsAndKeys:@"FIL - Send custom filters to APRS server",@"itemTitle",nil],
								[NSDictionary dictionaryWithObjectsAndKeys:@"GPS - Get detailed GPS information",@"itemTitle",nil],
								nil];
		
		self.settingsComponents = [[NSArray alloc] initWithObjects:
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"Display Items",@"title",
									displayItems,@"items",nil],
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"Control Items",@"title",
									controlItems,@"items",nil],
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"Control Buttons",@"title",
									buttonItems,@"items",nil],
								   nil];
    }//if
	
    return self;
}//func

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// initial set page title
	self.title = _TITLE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
	[self.settingsComponents release];
	
    [super dealloc];
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Table methods

/**
 * Set number of sections in table
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.settingsComponents count];
}//func

/**
 * Customize the number of rows in the table view.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.settingsComponents objectAtIndex:section] objectForKey:@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.settingsComponents objectAtIndex:section] objectForKey:@"title"];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// extract from dict
	NSDictionary *currentItem = [[NSDictionary alloc] initWithDictionary:[[[self.settingsComponents objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row]];
	NSString *title = [currentItem objectForKey:@"itemTitle"];
	UIImage *image = [currentItem objectForKey:@"icon"];
	
	// set the cell properties
	[cell.textLabel setText:title];
	[cell.textLabel setFont:[UIFont systemFontOfSize:15]];
	[cell.textLabel setNumberOfLines:0];
	[cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
	[cell.imageView setImage:image];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	
    return cell;
}//func


@end
