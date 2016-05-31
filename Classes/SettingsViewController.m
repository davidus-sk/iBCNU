//
//  SettingsViewController.m
//  iBCNU
//
//  Created by David Ponevac on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "UITextFieldCustom.h"
#import "UIViewCustom.h"
#import "SymbolViewController.h"


@implementation SettingsViewController

@synthesize settingsComponents;
@synthesize dataClass;
@synthesize APRSClass;
@synthesize ccClass;
@synthesize callsignIcon;


static NSString *_TITLE = @"Settings";


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed dataFeed:(Data *)dataFeed ccFeed:(ControlCenterViewController *)ccFeed
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		// set the classes
		[self setAPRSClass:APRSFeed];
		[self setDataClass:dataFeed];
		[self setCcClass:ccFeed];
		
		// frames
		CGRect textFrame = CGRectMake(158, 9, 152, 26);
		
		// field for settings
		UITextFieldCustom *callsignText = [[UITextFieldCustom alloc] initWithFrame:textFrame textRectForBounds:CGRectMake(5, 1, 140, 25)];
		callsignText.textColor = [UIColor darkGrayColor];
		[callsignText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[callsignText setBackgroundColor:[UIColor clearColor]];
		callsignText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		callsignText.returnKeyType = UIReturnKeyDone;
		callsignText.delegate = self;
		callsignText.tag = [_TAG_CALLSIGN intValue];
		callsignText.text = [self.APRSClass callsign];
		[callsignText setAutocorrectionType:UITextAutocorrectionTypeNo];
		
		callsignIcon = [[UIImageView alloc] initWithFrame:CGRectMake(158, 13, 20, 20)];
		callsignIcon.tag = [_TAG_ICON intValue];
		callsignIcon.image = [UIImage imageNamed:[[self.APRSClass icon] stringByAppendingString:@".gif"]];
		
		
		UITextFieldCustom *gateText = [[UITextFieldCustom alloc] initWithFrame:textFrame textRectForBounds:CGRectMake(5, 1, 140, 25)];
		gateText.textColor = [UIColor darkGrayColor];
		[gateText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[gateText setBackgroundColor:[UIColor clearColor]];
		gateText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		gateText.returnKeyType = UIReturnKeyDone;
		gateText.delegate = self;
		gateText.tag = [_TAG_SERVERHOST intValue];
		gateText.text = [APRSClass serverHost];
		[gateText setAutocorrectionType:UITextAutocorrectionTypeNo];
		
		UITextFieldCustom *portText = [[UITextFieldCustom alloc] initWithFrame:textFrame textRectForBounds:CGRectMake(5, 1, 140, 25)];
		portText.textColor = [UIColor darkGrayColor];
		[portText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[portText setBackgroundColor:[UIColor clearColor]];
		portText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		portText.returnKeyType = UIReturnKeyDone;
		portText.delegate = self;
		portText.tag = [_TAG_SERVERPORT intValue];
		portText.text = [NSString stringWithFormat:@"%d", [APRSClass serverPort]];
		[portText setAutocorrectionType:UITextAutocorrectionTypeNo];
		
		UITextFieldCustom *statusText = [[UITextFieldCustom alloc] initWithFrame:textFrame textRectForBounds:CGRectMake(5, 1, 140, 25)];
		statusText.textColor = [UIColor darkGrayColor];
		[statusText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[statusText setBackgroundColor:[UIColor clearColor]];
		statusText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		statusText.returnKeyType = UIReturnKeyDone;
		statusText.delegate = self;
		statusText.tag = [_TAG_STATUSMSG intValue];
		statusText.text = [APRSClass statusMessage];
		[statusText setAutocorrectionType:UITextAutocorrectionTypeNo];
		
		// interval view + field + label
		UITextFieldCustom *intervalText = [[UITextFieldCustom alloc] initWithFrame:CGRectMake(0, 0, 122, 26) textRectForBounds:CGRectMake(5, 1, 110, 25)];
		intervalText.textColor = [UIColor darkGrayColor];
		[intervalText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[intervalText setBackgroundColor:[UIColor clearColor]];
		intervalText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		intervalText.returnKeyType = UIReturnKeyDone;
		intervalText.delegate = self;
		intervalText.tag = [_TAG_CINTERVAL intValue];
		intervalText.text = [NSString stringWithFormat:@"%@", [ccClass customInterval] == nil ? @"" : [ccClass customInterval]];
		[intervalText setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
		
		UILabel *intervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(127, 1, 25, 25)];
		[intervalLabel setText:@"s"];
		
		UIViewCustom *intervalView = [[UIViewCustom alloc] initWithFrame:textFrame];
		[intervalView addSubview:intervalText];
		[intervalView addSubview:intervalLabel];
		
		// distance view + field + label
		UITextFieldCustom *distanceText = [[UITextFieldCustom alloc] initWithFrame:CGRectMake(0, 0, 122, 26) textRectForBounds:CGRectMake(5, 1, 110, 25)];
		distanceText.textColor = [UIColor darkGrayColor];
		[distanceText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[distanceText setBackgroundColor:[UIColor clearColor]];
		distanceText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		distanceText.returnKeyType = UIReturnKeyDone;
		distanceText.delegate = self;
		distanceText.tag = [_TAG_DISTANCE intValue];
		distanceText.text = [NSString stringWithFormat:@"%@", [APRSClass distanceRange]];;
		[distanceText setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
		
		UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(127, 1, 25, 25)];
		[distanceLabel setText:@"m"];
		
		UIViewCustom *distanceView = [[UIViewCustom alloc] initWithFrame:textFrame];
		[distanceView addSubview:distanceText];
		[distanceView addSubview:distanceLabel];
		
		// range view + field + label
		UITextFieldCustom *rangeText = [[UITextFieldCustom alloc] initWithFrame:CGRectMake(0, 0, 122, 26) textRectForBounds:CGRectMake(5, 1, 110, 25)];
		rangeText.textColor = [UIColor darkGrayColor];
		[rangeText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[rangeText setBackgroundColor:[UIColor clearColor]];
		rangeText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		rangeText.returnKeyType = UIReturnKeyDone;
		rangeText.delegate = self;
		rangeText.tag = [_TAG_RANGE intValue];
		rangeText.text = [NSString stringWithFormat:@"%@", [APRSClass filterRange]];
		[rangeText setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
		
		UILabel *rangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(127, 1, 25, 25)];
		[rangeLabel setText:@"km"];
		
		UIViewCustom *rangeView = [[UIViewCustom alloc] initWithFrame:textFrame];
		[rangeView addSubview:rangeText];
		[rangeView addSubview:rangeLabel];
		
		UITextFieldCustom *latitudeText = [[UITextFieldCustom alloc] initWithFrame:textFrame textRectForBounds:CGRectMake(5, 1, 140, 25)];
		latitudeText.textColor = [UIColor darkGrayColor];
		[latitudeText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[latitudeText setBackgroundColor:[UIColor clearColor]];
		latitudeText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		latitudeText.returnKeyType = UIReturnKeyDone;
		latitudeText.delegate = self;
		latitudeText.tag = [_TAG_LATITUDE intValue];
		latitudeText.text = [NSString stringWithFormat:@"%f", [APRSClass latitude]];
		[latitudeText setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
		
		UITextFieldCustom *longitudeText = [[UITextFieldCustom alloc] initWithFrame:textFrame textRectForBounds:CGRectMake(5, 1, 140, 25)];
		longitudeText.textColor = [UIColor darkGrayColor];
		[longitudeText setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[longitudeText setBackgroundColor:[UIColor clearColor]];
		longitudeText.font = [UIFont systemFontOfSize:_FONT_SIZE];
		longitudeText.returnKeyType = UIReturnKeyDone;
		longitudeText.delegate = self;
		longitudeText.tag = [_TAG_LONGITUDE intValue];
		longitudeText.text = [NSString stringWithFormat:@"%f", [APRSClass longitude]];
		[longitudeText setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
		
		// metric switch
		UISwitch *metricSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(158, 8, 140, 25)];
		[metricSwitch setTag:[_TAG_METRIC intValue]];
		[metricSwitch setOn:[ccClass metricOn]];
		[metricSwitch addTarget:self action:@selector(metricSwitched) forControlEvents:UIControlEventValueChanged];
		
		// init settings components
		NSArray *stationSettings = [NSArray arrayWithObjects:
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"Enter your valid amateur radio callsign.",@"itemTitle",
									 [UIFont systemFontOfSize:12],@"fontSize",
									 [NSNull null],@"itemValue",
									 [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
									 [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
									 nil],
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"Callsign",@"itemTitle",
									 [UIFont boldSystemFontOfSize:18],@"fontSize",
									 callsignText,@"itemValue",
									 [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
									 [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
									 [UIImage imageNamed:@"callsign.icon.png"],@"icon",
									 nil],
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"Icon",@"itemTitle",
									 [UIFont boldSystemFontOfSize:18],@"fontSize",
									 callsignIcon,@"itemValue",
									 [NSNumber numberWithInt:UITableViewCellAccessoryDisclosureIndicator],@"accessoryType",
									 [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
									 [UIImage imageNamed:@"callsign.icon.png"],@"icon",
									 nil],
									nil];
		
		NSArray *APRSSettings = [NSArray arrayWithObjects:									
								 [NSDictionary dictionaryWithObjectsAndKeys:
								  @"APRS related information and settings.",@"itemTitle",
								  [UIFont systemFontOfSize:12],@"fontSize",
								  [NSNull null],@"itemValue",
								  [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
								  [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
								  nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Gate server",@"itemTitle",
								  [UIFont boldSystemFontOfSize:18],@"fontSize",
								  gateText,@"itemValue",
								  [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
								  [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
								  [UIImage imageNamed:@"status.icon.png"],@"icon",
								  nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Port number",@"itemTitle",
								  [UIFont boldSystemFontOfSize:18],@"fontSize",
								  portText,@"itemValue",
								  [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
								  [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
								  [UIImage imageNamed:@"status.icon.png"],@"icon",
								  nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Message",@"itemTitle",
								  [UIFont boldSystemFontOfSize:18],@"fontSize",
								  statusText,@"itemValue",
								  [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
								  [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
								  [UIImage imageNamed:@"message.icon.png"],@"icon",
								  nil],
								 [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Range filter",@"itemTitle",
								  [UIFont boldSystemFontOfSize:18],@"fontSize",
								  rangeView,@"itemValue",
								  [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
								  [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
								  [UIImage imageNamed:@"beacon.icon.png"],@"icon",
								  nil],
								 nil];
		
		NSArray *beaconSettings = [NSArray arrayWithObjects:
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"Tweak the behaviour of the automatic beacon.",@"itemTitle",
									[UIFont systemFontOfSize:12],@"fontSize",
									[NSNull null],@"itemValue",
									[NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
									[NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
									nil],
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"Interval",@"itemTitle",
									[UIFont boldSystemFontOfSize:18],@"fontSize",
									intervalView,@"itemValue",
									[NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
									[NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
									[UIImage imageNamed:@"interval.icon.png"],@"icon",
									nil],
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"Distance",@"itemTitle",
									[UIFont boldSystemFontOfSize:18],@"fontSize",
									distanceView,@"itemValue",
									[NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
									[NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
									[UIImage imageNamed:@"distance.icon.png"],@"icon",
									nil],
								   nil];
		
		NSArray *generalSettings = [NSArray arrayWithObjects:
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"Various appliaction settings.", @"itemTitle",
									 [UIFont systemFontOfSize:12],@"fontSize",
									 [NSNull null],@"itemValue",
									 [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
									 [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
									 nil],
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"Metric units",@"itemTitle",
									 [UIFont boldSystemFontOfSize:18],@"fontSize",
									 metricSwitch,@"itemValue",
									 [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
									 [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
									 [UIImage imageNamed:@"distance.icon.png"],@"icon",
									 nil],
									nil];
		
		NSArray *GPSSettings = [NSArray arrayWithObjects:
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"Enter decimal coords if no GPS receiver present.",@"itemTitle",
								 [UIFont systemFontOfSize:12],@"fontSize",
								 [NSNull null],@"itemValue",
								 [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
								 [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
								 nil],
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"Latitude",@"itemTitle",
								 [UIFont boldSystemFontOfSize:18],@"fontSize",
								 latitudeText,@"itemValue",
								 [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
								 [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
								 [UIImage imageNamed:@"latitude.icon.png"],@"icon",
								 nil],
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"Longitude",@"itemTitle",
								 [UIFont boldSystemFontOfSize:18],@"fontSize",
								 longitudeText,@"itemValue",
								 [NSNumber numberWithInt:UITableViewCellAccessoryNone],@"accessoryType",
								 [NSNumber numberWithInt:UITableViewCellSelectionStyleNone],@"selectionStyle",
								 [UIImage imageNamed:@"longitude.icon.png"],@"icon",
								 nil],
								nil];
		
		self.settingsComponents = [[NSArray alloc] initWithObjects:
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"Station Settings",@"title",
									stationSettings,@"items",nil],
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"APRS Settings",@"title",
									APRSSettings,@"items",nil],
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"Beacon Settings",@"title",
									beaconSettings,@"items",nil],
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"GPS Settings",@"title",
									GPSSettings,@"items",nil],
								   [NSDictionary dictionaryWithObjectsAndKeys:
									@"General Settings",@"title",
									generalSettings,@"items",nil],
								   nil];
		
		// release
		[callsignText release];
		
		[gateText release];
		[portText release];
		[statusText release];
		
		[rangeText release];
		[rangeLabel release];
		[rangeView release];
		
		[intervalText release];
		[intervalLabel release];
		[intervalView release];
		
		[distanceText release];
		[distanceLabel release];
		[distanceView release];
		
		[latitudeText release];
		[longitudeText release];
		
		[metricSwitch release];
		
		stationSettings = nil;
		APRSSettings = nil;
		beaconSettings = nil;
		GPSSettings = nil;
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationController.navigationBarHidden = NO;
	
	NSString *newIcon = [[self.APRSClass icon] stringByAppendingString:@".gif"];
	
	[self.callsignIcon setImage:[UIImage imageNamed:newIcon]];
	[self.callsignIcon setNeedsDisplay];
	[self.callsignIcon setNeedsLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
	[callsignIcon release];
	[settingsComponents release];

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
	

	for (UIView *view in cell.subviews)
	{
		if (([view isMemberOfClass:[UITextFieldCustom class]] == YES) || ([view isMemberOfClass:[UIViewCustom class]] == YES) ||
			([view isMemberOfClass:[UISwitch class]] == YES) || ([view isMemberOfClass:[UIImageView class]] == YES))
		{
			[view removeFromSuperview];
		}
	}
    
	// extract from dict
	NSDictionary *currentItem = [[NSDictionary alloc] initWithDictionary:[[[self.settingsComponents objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row]];
	NSString *title = [currentItem objectForKey:@"itemTitle"];
	id uiItem = [currentItem objectForKey:@"itemValue"];
	uiItem = uiItem == [NSNull null] ? nil : uiItem;
	NSInteger style = [[currentItem objectForKey:@"selectionStyle"] intValue];
	NSInteger accessory = [[currentItem objectForKey:@"accessoryType"] intValue];
	UIImage *image = [currentItem objectForKey:@"icon"];
	UIFont *fontSize = [currentItem objectForKey:@"fontSize"];
	
	// set the cell properties
	[cell.textLabel setText:title];
	[cell.textLabel setFont:fontSize];
	[cell.imageView setImage:image];
	[cell addSubview:uiItem];
	[cell setSelectionStyle:style];
	[cell setAccessoryType:accessory];
	
	[currentItem release];
	
    return cell;
}//func

/**
 * If item is clicked
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 2 && indexPath.section == 0)
	{
		SymbolViewController *symbolController = [[SymbolViewController alloc] initWithNibName:@"SymbolViewController" bundle:nil APRSFeed: APRSClass];
		//[showTextController setSender:@"inbox"];
		//[showTextController setMessage:[messages objectAtIndex:indexPath.row]];
		[self.navigationController pushViewController:symbolController animated:YES];
		[symbolController release];
	}//if
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark TextField methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	CGRect rect = self.view.frame;
	
	rect.origin.y -= 155;
	rect.size.height += 155;
	
	//self.view.frame = rect;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	// move down by a bit
	CGRect rect = self.view.frame;
	
	rect.origin.y += 155;
	rect.size.height -= 155;
	
	//self.view.frame = rect;
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSString *text = textField.text;
	
	// uppercase the string
	text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	switch (textField.tag)
	{
			// _TAG_CALLSIGN
		case 10:
		{
			// callsign needs to be upercase
			text = [text uppercaseString];
			
			// make sure its not empty
			if (![text isEqualToString:@""])
			{
				// check if we have the same callsign
				if ([text isEqualToString:[APRSClass callsign]])
				{
					return;
				}//if
				
				// validate callsign before proceeding
				if (![APRSClass validateCallsign:text])
				{
					[CommonTools showError:_ERR_TITLE_CALL_INVALID message:_ERR_MSG_CALL_INVALID];
					
					return;
				}//if
				
				// add SSID if NONE
				if ([text rangeOfString:@"-" options:NSLiteralSearch].location == NSNotFound)
				{
					// generate random num between 0-15
					int randSSID = (arc4random() % 14) + 1;
					
					text = [text stringByAppendingString:[NSString stringWithFormat:@"-%d",randSSID]]; 
				}//if
				
				// save for future
				[CommonTools saveToFile:text forTag:_TAG_CALLSIGN];
				
				// save to aprs object
				[APRSClass setCallsign:text];
				[dataClass setCallsign:text];
			}
			else
			{
				// use last goog known callsign
				text = [APRSClass callsign];
			}//if
		} break;
			
			// _TAG_STATUSMSG
		case 20:
		{
			// save for future
			[CommonTools saveToFile:text forTag:_TAG_STATUSMSG];
			
			// save to aprs object
			[APRSClass setStatusMessage:[text isEqualToString:@""] ? nil : text];
		} break;
			
			// _TAG_CINTERVAL
		case 70:
		{
			// check if interval falls within bounds
			int interval = [text intValue];
			
			if ((interval >= 10) && (interval <= 1000))
			{
				[CommonTools saveToFile:[NSNumber numberWithInt:interval] forTag:_TAG_CINTERVAL];
				
				// save to control center
				[ccClass setCustomInterval:[NSNumber numberWithInt:interval]];
			}
			else
			{
				// use last good known value
				text = [NSString stringWithFormat:@"%@", [ccClass customInterval] == nil ? @"" : [ccClass customInterval]];
				
				// display error
				[CommonTools showError:_ERR_TITLE_CINTERVAL_INVALID message:_ERR_MSG_CINTERVAL_INVALID];
			}//if
		} break;
			
			// _TAG_RANGE
		case 80:
		{
			// check if range falls within bounds
			int interval = [text intValue];
			
			if ((interval >= 1) && (interval <= 500))
			{
				[CommonTools saveToFile:[NSNumber numberWithInt:interval] forTag:_TAG_RANGE];
				
				// save to aprs object
				[APRSClass setFilterRange:[NSNumber numberWithInt:interval]];
				
				// send to server
				[APRSClass sendAPRSFilter];
			}
			else
			{
				// use last good known value
				text = [NSString stringWithFormat:@"%@", [APRSClass filterRange]];
				
				// display error
				[CommonTools showError:_ERR_TITLE_RANGE_INVALID message:_ERR_MSG_RANGE_INVALID];
			}//if
		} break;
			
			// _TAG_DISTANCE
		case 110:
		{
			// check if range falls within bounds
			int interval = [text intValue];
			
			if ((interval >= 10) && (interval <= 2000))
			{
				[CommonTools saveToFile:[NSNumber numberWithInt:interval] forTag:_TAG_DISTANCE];
				
				// save to aprs object
				[APRSClass setDistanceRange:[NSNumber numberWithInt:interval]];
			}
			else
			{
				// use last good known value
				text = [NSString stringWithFormat:@"%@", [APRSClass distanceRange] == nil ? @"" : [APRSClass distanceRange]];
				
				// display error
				[CommonTools showError:_ERR_TITLE_DISTANCE_INVALID message:_ERR_MSG_DISTANCE_INVALID];
			}//if
		} break;
			
			// _TAG_LATITUDE
		case 90:
		{
			double latitude = [text floatValue];
			
			if (latitude != 0.0)
			{
				[APRSClass setLatitude:latitude];
			}//if
		} break;
			
			// _TAG_LONGITUDE
		case 100:
		{
			double longitude = [text floatValue];
			
			if (longitude != 0.0)
			{
				[APRSClass setLongitude:longitude];
			}//if
		} break;
			
			// _TAG_SERVERHOST
		case 120:
		{			
			if (![text isEqualToString:@""])
			{
				[CommonTools saveToFile:text forTag:_TAG_SERVERHOST];
				
				// save to aprs object
				[APRSClass setServerHost:text];
				
				[APRSClass disconnectFromAPRS];
				//[APRSClass connectToAPRS];
			}
			else
			{
				// use last good known value
				text = [APRSClass serverHost];
				
				// display error
				[CommonTools showError:_ERR_TITLE_HOST_INVALID message:_ERR_MSG_HOST_INVALID];
			}//if
		} break;
			
			// _TAG_SERVERPORT
		case 130:
		{
			// check if range falls within bounds
			int port = [text intValue];
			
			if ((port > 0) && (port <= 65536))
			{
				[CommonTools saveToFile:[NSNumber numberWithInt:port] forTag:_TAG_SERVERPORT];
				
				// save to aprs object
				[APRSClass setServerPort:port];
				
				[APRSClass disconnectFromAPRS];
				//[APRSClass connectToAPRS];
			}
			else
			{
				// use last good known value
				text = [NSString stringWithFormat:@"%d", [APRSClass serverPort]];
				
				// display error
				[CommonTools showError:_ERR_TITLE_PORT_INVALID message:_ERR_MSG_PORT_INVALID];
			}//if
		} break;
			
		default:
			break;
	}//switch
	
	[textField setText:text];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Switch event
- (void)metricSwitched
{
	// store new data
	[ccClass setMetricOn:![ccClass metricOn]];
	
	[CommonTools saveToFile:[NSNumber numberWithBool:[ccClass metricOn]] forTag:_TAG_METRIC];
}


@end
