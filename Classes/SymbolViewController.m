//
//  SymbolViewController.m
//  iBCNU
//
//  Created by David Ponevac on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SymbolViewController.h"


@implementation SymbolViewController

@synthesize iconRotator;
@synthesize pickerData;
@synthesize APRSClass;

static NSString *_TITLE = @"APRS Icon";


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
	
	// load icons
	self.pickerData = [[NSArray alloc] initWithObjects:
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_1_1.gif"]], @"image", @"1_1_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_3_1.gif"]], @"image", @"1_3_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_4_1.gif"]], @"image", @"1_4_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_5_1.gif"]], @"image", @"1_5_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_6_1.gif"]], @"image", @"1_6_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_7_1.gif"]], @"image", @"1_7_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_8_1.gif"]], @"image", @"1_8_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_9_1.gif"]], @"image", @"1_9_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_10_1.gif"]], @"image", @"1_10_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_11_1.gif"]], @"image", @"1_11_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_12_1.gif"]], @"image", @"1_12_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_13_1.gif"]], @"image", @"1_13_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_14_1.gif"]], @"image", @"1_14_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_15_1.gif"]], @"image", @"1_15_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_16_1.gif"]], @"image", @"1_16_1", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_1_2.gif"]], @"image", @"1_1_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_2_2.gif"]], @"image", @"1_2_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_3_2.gif"]], @"image", @"1_3_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_4_2.gif"]], @"image", @"1_4_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_5_2.gif"]], @"image", @"1_5_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_6_2.gif"]], @"image", @"1_6_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_7_2.gif"]], @"image", @"1_7_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_8_2.gif"]], @"image", @"1_8_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_9_2.gif"]], @"image", @"1_9_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_10_2.gif"]], @"image", @"1_10_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_11_2.gif"]], @"image", @"1_11_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_12_2.gif"]], @"image", @"1_12_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_13_2.gif"]], @"image", @"1_13_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_14_2.gif"]], @"image", @"1_14_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_15_2.gif"]], @"image", @"1_15_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_16_2.gif"]], @"image", @"1_16_2", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_1_3.gif"]], @"image", @"1_1_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_2_3.gif"]], @"image", @"1_2_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_3_3.gif"]], @"image", @"1_3_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_5_3.gif"]], @"image", @"1_5_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_6_3.gif"]], @"image", @"1_6_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_7_3.gif"]], @"image", @"1_7_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_8_3.gif"]], @"image", @"1_8_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_9_3.gif"]], @"image", @"1_9_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_11_3.gif"]], @"image", @"1_11_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_12_3.gif"]], @"image", @"1_12_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_13_3.gif"]], @"image", @"1_13_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_14_3.gif"]], @"image", @"1_14_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_15_3.gif"]], @"image", @"1_15_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_16_3.gif"]], @"image", @"1_16_3", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_1_4.gif"]], @"image", @"1_1_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_2_4.gif"]], @"image", @"1_2_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_3_4.gif"]], @"image", @"1_3_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_4_4.gif"]], @"image", @"1_4_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_5_4.gif"]], @"image", @"1_5_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_6_4.gif"]], @"image", @"1_6_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_7_4.gif"]], @"image", @"1_7_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_8_4.gif"]], @"image", @"1_8_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_9_4.gif"]], @"image", @"1_9_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_10_4.gif"]], @"image", @"1_10_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_11_4.gif"]], @"image", @"1_11_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_12_4.gif"]], @"image", @"1_12_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_13_4.gif"]], @"image", @"1_13_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_14_4.gif"]], @"image", @"1_14_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_15_4.gif"]], @"image", @"1_15_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_16_4.gif"]], @"image", @"1_16_4", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_1_5.gif"]], @"image", @"1_1_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_2_5.gif"]], @"image", @"1_2_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_3_5.gif"]], @"image", @"1_3_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_4_5.gif"]], @"image", @"1_4_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_5_5.gif"]], @"image", @"1_5_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_6_5.gif"]], @"image", @"1_6_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_7_5.gif"]], @"image", @"1_7_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_8_5.gif"]], @"image", @"1_8_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_9_5.gif"]], @"image", @"1_9_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_10_5.gif"]], @"image", @"1_10_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_11_5.gif"]], @"image", @"1_11_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_12_5.gif"]], @"image", @"1_12_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_13_5.gif"]], @"image", @"1_13_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_14_5.gif"]], @"image", @"1_14_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_15_5.gif"]], @"image", @"1_15_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_16_5.gif"]], @"image", @"1_16_5", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_1_6.gif"]], @"image", @"1_1_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_2_6.gif"]], @"image", @"1_2_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_3_6.gif"]], @"image", @"1_3_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_4_6.gif"]], @"image", @"1_4_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_5_6.gif"]], @"image", @"1_5_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_6_6.gif"]], @"image", @"1_6_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_7_6.gif"]], @"image", @"1_7_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_8_6.gif"]], @"image", @"1_8_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_9_6.gif"]], @"image", @"1_9_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_10_6.gif"]], @"image", @"1_10_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_12_6.gif"]], @"image", @"1_12_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_14_6.gif"]], @"image", @"1_14_6", @"code", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_16_6.gif"]], @"image", @"1_16_6", @"code", nil],
					   nil
					   ];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// set currently selected icon in picker
	for (int i = 0; i < [self.pickerData count]; i++)
	{
		if ([[self.APRSClass icon] isEqualToString: [[self.pickerData objectAtIndex:i] objectForKey:@"code"]])
		{
			[self.iconRotator selectRow:i inComponent:0 animated:YES];
			
			return;
		}//if
	}//for
}

/**
 * write down users selection
 */
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	NSInteger row = [self.iconRotator selectedRowInComponent:0];
	
	// save to file
	[CommonTools saveToFile:[[self.pickerData objectAtIndex:row] objectForKey:@"code"] forTag:_TAG_ICON];
	
	// set in APRS
	[self.APRSClass setIcon:[[self.pickerData objectAtIndex:row] objectForKey:@"code"]];
}//func


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.iconRotator = nil;
}


- (void)dealloc
{
	[self.pickerData release];

    [super dealloc];
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Picker methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}//func

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.pickerData count];
}//func

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	return [[self.pickerData objectAtIndex:row] objectForKey:@"image"];
}


@end
