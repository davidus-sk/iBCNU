//
//  AboutViewController.m
//  iBCNU
//
//  Created by David Ponevac on 4/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"

static NSString *_TITLE = @"About";


@implementation AboutViewController


@synthesize aboutScrollView;

/**
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{		

    }//if

    return self;
}//func

/**
 * Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// set page title
	self.title = _TITLE;

	// top image
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 150)];
	imageView.image = [UIImage imageNamed:@"about.image.png"];
	
	// link
	UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
	CGSize size = [@"ibcnu.us" sizeWithFont:[UIFont boldSystemFontOfSize:_FONT_SIZE] constrainedToSize:CGSizeMake(300.0, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
	[linkButton setFrame: CGRectMake(70, 170, size.width, size.height)];
	[linkButton setTitle:@"ibcnu.us" forState:UIControlStateNormal];
	[linkButton setTitleColor:[UIColor colorWithRed:0 green:0.478 blue:0.658 alpha:1.0] forState:UIControlStateNormal];
	[linkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:_FONT_SIZE]];
	[linkButton addTarget:self action:@selector(openLink:) forControlEvents:UIControlEventTouchUpInside];
	
	// visit label
	UILabel *visitLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 50, size.height)];
	[visitLabel setFont:[UIFont boldSystemFontOfSize:_FONT_SIZE]];
	[visitLabel setText:@"Visit:"];
	
	// add items
	[self.aboutScrollView addSubview:imageView];
	[self.aboutScrollView addSubview:visitLabel];
	[self.aboutScrollView addSubview:linkButton];
	
	// text pieces
	NSArray *text = [NSArray arrayWithObjects:
					 [NSString stringWithFormat:@"%@ (%@) was written by David Ponevac (AB3Y) during long spring nights of 2009 in El Paso Texas.", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]],
					 @"This application serves two purposes: as an APRS beacon reporting position of your iPhone and as a two-way text messaging tool (via APRS).",
					 @"A valid callsign is required for both modes to work properly. If you are not licensed, get a ham radio license before using this application.",
					 @"Create a free account and track your position reports and your messages on ibcnu.sk.",
					 @"APRS Copyright © Bob Bruninga (WB4APR). Many thanks to all who make APRS and APRS-IS possible.",
					 @"This application is intended for licensed ham radio operators.",
					 nil];
	
	// text
	float initial_height = 200.0;
	for (int i = 0; i < [text count]; i++)
	{
		CGSize size = [[text objectAtIndex:i] sizeWithFont:[UIFont boldSystemFontOfSize:_FONT_SIZE] constrainedToSize:CGSizeMake(300.0, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, initial_height + 10.0, 300, size.height)];
		[textLabel setText:[text objectAtIndex:i]];
		[textLabel setNumberOfLines:30];
		[textLabel setLineBreakMode:UILineBreakModeWordWrap];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setTextColor:[UIColor blackColor]];
		[textLabel setFont:[UIFont systemFontOfSize:_FONT_SIZE]];
		
		// inc initial height for next label
		initial_height += size.height + 20;
		
		// add to view
		[self.aboutScrollView addSubview:textLabel];
		[textLabel release];
	}//for
	
	[self.aboutScrollView setContentSize:CGSizeMake(300, initial_height)];
	
	[imageView release];
	linkButton = nil;
	[visitLabel release];
}//func


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}//func

/**
 * Navigate to link
 */
- (void)openLink:(id)sender
{
	[CommonTools openLink:@"http://ibcnu.us/"];
}//func

/**
 * Clean up
 */
- (void)dealloc
{
    [super dealloc];
}//func


@end
