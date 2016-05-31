//
//  InboxViewController.m
//  iBCNU
//
//  Created by David Ponevac on 4/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InboxViewController.h"
#import "ShowTextMessageController.h"
#import "MessageCell.h"


@implementation InboxViewController

@synthesize messageTableView;
@synthesize barItem;
@synthesize dataClass;
@synthesize APRSClass;

static NSString *_TITLE = @"Inbox";

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Class methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		// notification receiver for NEW_MSG_RCVD
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgsReceived:) name:@"_NOTIFY_NEW_MSG_RCVD" object:nil];
    }//if
	
    return self;
}//func

/**
 * View did show
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// reset badge to nada
	barItem.badgeValue = nil;
	
	// Unselect the selected row if any
	NSIndexPath *selection = [self.messageTableView indexPathForSelectedRow];
	if (selection)
	{
		[self.messageTableView deselectRowAtIndexPath:selection animated:YES];
	}//if
	
	//	The scrollbars won't flash unless the tableview is long enough.
	[self.messageTableView flashScrollIndicators];
}//if

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	int numMessages = 0;
	if ([Data isDbSet] || [Data connectToDB])
	{
		numMessages = [Data countMessages:@"tblInbox"];
		[Data closeDB];
	}//if
	
	if (numMessages > 0)
	{
		[progress startAnimating];
	}
	else
	{
		[progress stopAnimating];
	}//if
	
	// try to connect via new thread
	[NSThread detachNewThreadSelector:@selector(getFromSQLThreaded) toTarget:self withObject:nil];
}//func

/**
 * View did load
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// initial set page title
	self.title = _TITLE;
	
	// edit button
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEdit:)];
	
	// put big loader on screen
	progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[progress setHidesWhenStopped:YES];
	[progress setFrame:CGRectMake(145, 185, 30, 30)];
	[self.view addSubview:progress];
}//func

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// mark all messages as read
	if ([Data isDbSet] || [Data connectToDB])
	{
		[Data markMessagesRead:@"tblInbox"];
		[Data closeDB];
	}//if
}//func

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}//func

- (void)dealloc
{	
	[messages release];
	[progress release];
	
    [super dealloc];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Helper methods

/**
 * Execute on new notification - reload table
 */
- (void)msgsReceived:(NSNotification *)notif
{	
	// start progress bar
	[progress startAnimating];
	
	// launch in thread
	[NSThread detachNewThreadSelector:@selector(getFromSQLThreaded) toTarget:self withObject:nil];
}//func

/**
 * Enable/disable editing mode for messages
 */
- (void)toggleEdit:(UIBarButtonItem *)sender
{
	if ([self.messageTableView isEditing])
	{
		[self.messageTableView setEditing:NO animated:YES];
		
		// return back to original button
		self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStylePlain;
		self.navigationItem.leftBarButtonItem.title = @"Edit";
	}
	else
	{
		[self.messageTableView setEditing:YES animated:YES];
		
		// return back to original button
		self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;
		self.navigationItem.leftBarButtonItem.title = @"Done";
	}//if
}//func

/**
 * load messages in a thread
 */
- (void)getFromSQLThreaded
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// indicator - start
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// load from SQL
	// load up messages
	messages = [[NSMutableArray alloc] initWithCapacity:0];
	if ([Data isDbSet] || [Data connectToDB])
	{
		messages = [[NSMutableArray alloc] initWithArray:[Data getMessagesFromDB:@"tblInbox"]];
		[Data closeDB];
	}//if
	
	// stop
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// reload the data
	[self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:true];
	
	[pool release];	
}//func

/**
 * Reload table on the main thread
 */
- (void)reloadTable
{
	NSLog(@"msgs: %d", [messages count]);
	[messageTableView reloadData];
	
	// hide spinner
	if ([progress isAnimating])
	{
		[progress stopAnimating];
	}//if
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
    return [messages count];
}//func

/**
 * Customize the appearance of table view cells.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"MessageCellIdentifier";
	
	MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}//if
	
	// callsign label
	[cell.callsignLabel setFont:[UIFont boldSystemFontOfSize:_FONT_SIZE]];
	[cell.callsignLabel setText:[[messages objectAtIndex:indexPath.row] objectForKey:@"callsign"]];
	
	// date label
	[cell.dateLabel setFont:[UIFont systemFontOfSize:12.0]];
	[cell.dateLabel setText:[NSString stringWithFormat:@"(%@)", [[messages objectAtIndex:indexPath.row] objectForKey:@"date"]]];
	
	// message label
	[cell.msgLabel setFont:[UIFont systemFontOfSize:_MSG_FONT_SIZE]];
	[cell.msgLabel setTextColor:_GRAY_TXT_COLOR];
	[cell.msgLabel setText:[[messages objectAtIndex:indexPath.row] objectForKey:@"message"]];
	
	
	[cell setTag:[[[messages objectAtIndex:indexPath.row] objectForKey:@"messageID"] intValue]];

    return cell;
}//func

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 66;
}//func

/**
 * Update the data model according to edit actions delete or insert.
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{		
		// get cell tag
		UITableViewCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
		
		// if cell was not found
		if (cell == nil)
		{
			return;
		}//if
		
		// delete from DB
		if ([Data connectToDB])
		{
			[Data deleteMessageFromDB:@"tblInbox" message:cell.tag];
			[Data closeDB];
		}//if
		
		// delete from iBCNU server
		[Data deleteMessageFromServer:cell.tag callsign:[APRSClass callsign]];
		
		// load up messages
		messages = [[NSMutableArray alloc] initWithCapacity:0];
		if ([Data connectToDB])
		{
			messages = [[NSMutableArray alloc] initWithArray:[Data getMessagesFromDB:@"tblInbox"]];
			[Data closeDB];
		}//if
		
		// remove from table
		[self.messageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];	
    }//if
}//func

/**
 * If message is clicked
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ShowTextMessageController *showTextController = [[ShowTextMessageController alloc] initWithNibName:@"ShowTextMessageController" bundle:nil];
	[showTextController setSender:@"inbox"];
	[showTextController setAPRSClass:APRSClass];
	[showTextController setMessage:[messages objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:showTextController animated:YES];
	[showTextController release];
}//func


@end
