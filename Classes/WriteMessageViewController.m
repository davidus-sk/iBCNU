//
//  WriteMessageViewController.m
//  iBCNU
//
//  Created by David Ponevac on 4/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WriteMessageViewController.h"
#import "UITextFieldCustom.h"

static NSString *_TITLE = @"Compose";


@implementation WriteMessageViewController

@synthesize toCallField;
@synthesize APRSClass;


/**
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{		
		// to call label
		UILabel *toCallLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 40)];
		[toCallLabel setFont:[UIFont boldSystemFontOfSize:_FONT_SIZE]];
		[toCallLabel setText:@"To call"];
		
		// to call field
		toCallField = [[UITextFieldCustom alloc] initWithFrame:CGRectMake(158, 15, 152, 26) textRectForBounds:CGRectMake(5, 1, 140, 25)];
		[toCallField setFont:[UIFont systemFontOfSize:_FONT_SIZE]];
		[toCallField setTextColor:[UIColor darkGrayColor]];
		[toCallField setBackground:[UIImage imageNamed:@"root.input.bg.png"]];
		[toCallField setBackgroundColor:[UIColor clearColor]];
		[toCallField setReturnKeyType:UIReturnKeyDone];
		[toCallField setDelegate:self];
		[toCallField setTag:[_TAG_TOCALLSIGN intValue]];
		[toCallField setAutocorrectionType:UITextAutocorrectionTypeNo];

		// msg field
		msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 55, 300, 180)];
		[msgTextView setFont:[UIFont systemFontOfSize:_FONT_SIZE]];
		[msgTextView setTextColor:[UIColor darkGrayColor]];
		[msgTextView setBackgroundColor:[UIColor clearColor]];
		[msgTextView setReturnKeyType:UIReturnKeyDone];
		[msgTextView setKeyboardType:UIKeyboardTypeASCIICapable];
		[msgTextView setDelegate:self];
		[msgTextView setTag:[_TAG_MSG intValue]];
		
		UIImage *msgImageBG = [UIImage imageNamed:@"root.input.bg.png"];
		UIImage *stretchableMsgImageBG = [msgImageBG stretchableImageWithLeftCapWidth:10 topCapHeight:10];
		UIImageView *textViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
		textViewBG.image = stretchableMsgImageBG;
		[msgTextView addSubview:textViewBG];
		[msgTextView sendSubviewToBack:textViewBG];
		
		// button
		UIImage *buttonImageNormal = [UIImage imageNamed:@"greenButton.png"];
		UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		CGRect buttonFrame = CGRectMake(10, 300, 300, 50);
		sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[sendButton setFrame:buttonFrame];
		[sendButton setTitle:@"Send message" forState:UIControlStateNormal];
		[sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:_FONT_SIZE]];
		[sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
		[sendButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
		[sendButton setBackgroundColor:[UIColor clearColor]];
		[sendButton addTarget:self action:@selector(sendMessage:event:) forControlEvents:UIControlEventTouchUpInside];
		
		// add the elements
		[self.view addSubview:toCallLabel];
		[self.view addSubview:toCallField];
		[self.view addSubview:msgTextView];
		[self.view addSubview:sendButton];
		
		// release
		[toCallLabel release];
		[textViewBG release];
		

    }//if

    return self;
}//func

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}//func

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[textView setFrame:CGRectMake(10, 55, 300, 130)];
	
	[[[textView subviews] objectAtIndex:0] setFrame:CGRectMake(0, 0, 300, 130)];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{	
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"])
	{
		[textView resignFirstResponder];
		[textView setFrame:CGRectMake(10, 55, 300, 180)];
		[[[textView subviews] objectAtIndex:0] setFrame:CGRectMake(0, 0, 300, 180)];
		return NO;
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{	
	// uppercase the string
	[textField setText:textField.text];
}//func

/**
 * Execute when button pressed - send msg
 */
- (void)sendMessage:(id)sender event:(id)event
{
	//check lengths
	if ([APRSClass validateCallsign:toCallField.text] && [APRSClass validateTextMessage:msgTextView.text])
	{
		// set to call and message
		[APRSClass setToCallsign:[toCallField.text uppercaseString]];
		[APRSClass setTextMessage:msgTextView.text];
		
		// try to send and if success, store in db
		if (![APRSClass sendTextMessage])
		{
			[CommonTools showError:_ERR_TITLE_MSG_SENDING_FAILED message:_ERR_MSG_MSG_SENDING_FAILED];
		}
		else
		{
			// store in sql
			if ([Data connectToDB])
			{
				NSDictionary *sqlData = [NSDictionary dictionaryWithObjectsAndKeys:
										 [toCallField text], @"callsign",
										 [msgTextView text], @"message",
										 [CommonTools formatTimestamp:[NSDate date]], @"date",
										 nil];
				
				[Data storeMessageInDB:sqlData table:@"tblOutbox"];
				[Data closeDB];
			}//if
			
			// empty out text field
			[msgTextView setText:@""];
			
			// ok
			[CommonTools showError:_MSG_TITLE_MSG_SENT message:[NSString stringWithFormat:_MSG_MSG_MSG_SENT, toCallField.text]];
			
			// switch back to inbox
			if ([self navigationController] != nil)
			{
				[self.navigationController popViewControllerAnimated:YES];
			}//if
		}//if
	}//if
}//func

/**
 * Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Custom initialization
	self.title = _TITLE;
}//func


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}//func

/**
 * Clean up
 */
- (void)dealloc
{
	[toCallField release];
	[msgTextView release];
	sendButton = nil;
    [super dealloc];
}//func


@end
