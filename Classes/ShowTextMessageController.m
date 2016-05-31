//
//  ShowTextMessage.m
//  iBCNU
//
//  Created by David Ponevac on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShowTextMessageController.h"
#import "WriteMessageViewController.h"


@implementation ShowTextMessageController

@synthesize textLabel;
@synthesize infoLabel;
@synthesize message;
@synthesize sender;
@synthesize APRSClass;

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
 * Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// set title to call sign
	self.title = [message objectForKey:@"callsign"];
	
	// prepare message
	NSString *infoMessage = [self sender] == @"inbox" ? [NSString stringWithFormat:@"Received on %@ from %@.", [message objectForKey:@"date"], [message objectForKey:@"callsign"]] : [NSString stringWithFormat:@"Sent on %@ to %@.", [message objectForKey:@"date"], [message objectForKey:@"callsign"]];
	
	// set label
	[infoLabel setFrame:CGRectMake(20.0, 10.0, 280.0, 30.0)];
	[infoLabel setFont:[UIFont systemFontOfSize:13]];
	[infoLabel setTextColor:[UIColor blackColor]];
	[infoLabel setText:infoMessage];
	
	// set message
	CGSize size = [[message objectForKey:@"message"] sizeWithFont:[UIFont systemFontOfSize:_FONT_SIZE] constrainedToSize:CGSizeMake(280.0, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
	[textLabel setFrame:CGRectMake(20.0, 50.0, 280, size.height)];
	[textLabel setNumberOfLines:40];
	[textLabel setLineBreakMode:UILineBreakModeWordWrap];
	[textLabel setFont:[UIFont systemFontOfSize:_FONT_SIZE]];
	[textLabel setTextColor:[UIColor blackColor]];
	[textLabel setText:[message objectForKey:@"message"]];
	
	
	if ([self sender] == @"inbox")
	{
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStyleBordered target:self action:@selector(replyToMsg)];
	}//if
}//func

- (void)replyToMsg
{
	WriteMessageViewController *writeController = [[WriteMessageViewController alloc] initWithNibName:@"WriteMessageViewController" bundle:nil];
	[writeController setAPRSClass:APRSClass];
	[writeController.toCallField setText:self.title];
	[self.navigationController pushViewController:writeController animated:YES];
	[writeController release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}//func

- (void)dealloc
{
	[self setMessage:nil];
	[self setSender:nil];
    [super dealloc];
}//func


@end
