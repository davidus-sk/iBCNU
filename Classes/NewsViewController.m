//
//  NewsViewController.m
//  iBCNU
//
//  Created by David Ponevac on 5/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"


@implementation NewsViewController

@synthesize newsTableView;
@synthesize rootData;

static NSString *_TITLE = @"iBCNU News";

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
    }
    return self;
}//func

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// initial set page title
	self.title = _TITLE;
	
	// put big loader on screen
	progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[progress setHidesWhenStopped:YES];
	[progress startAnimating];
	[progress setFrame:CGRectMake(145, 185, 30, 30)];
	[self.view addSubview:progress];
	
	// try to connect via new thread
	[NSThread detachNewThreadSelector:@selector(getXMLThreaded) toTarget:self withObject:nil];
}//func

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	self.newsTableView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
	currentItem = nil;
	currentContents = nil;
	
	[self setRootData:nil];
	
    [super dealloc];
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark XML methods

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	//NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	//NSLog(@"error parsing XML: %@", errorString);
	
	//UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName compare:@"item"] == NSOrderedSame)
	{
		currentItem = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	else if (currentItem != NULL)
	{
		currentContents = [[NSMutableString alloc] initWithCapacity:0];
	}//if
}//func

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (currentContents && string)
	{
		[currentContents appendString:string];
	}//if
}//func

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName compare:@"item"] == NSOrderedSame)
	{
		[rootData addObject:currentItem];
		[currentItem release];
	}
	else if (currentItem && currentContents)
	{
		[currentItem setObject:currentContents forKey:elementName];
		currentContents = nil;
		[currentContents release];
	}//if
}//func

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Threaded methods

- (void)getXMLThreaded
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// indicator - start
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// get data from xml
	rootData = [[NSMutableArray alloc] initWithCapacity:0];
	NSURL *feedXML = [NSURL URLWithString:@"http://ibcnu.us/xml_out?request=get_news"];
	NSXMLParser *feedParser = [[NSXMLParser alloc] initWithContentsOfURL:feedXML];
	[feedParser setDelegate:self];
	BOOL success = [feedParser parse];
	if (!success)
	{
		[rootData addObject:[NSDictionary dictionaryWithObject:@"Unable to fetch news from server." forKey:@"text"]];
	}//if
	[feedParser release];
	
	// stop
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// reload the data
	[self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:false];
	
	[pool release];
}

/**
 * Reload table on the main thread
 */
- (void)reloadTable
{
	[newsTableView reloadData];
	
	// hide spinner
	if ([progress isAnimating])
	{
		[progress stopAnimating];
	}//if
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [rootData count];
}//func

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	static NSString *CellIdentifier = @"NewsCell";
	
	NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewsCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}//if
	
	// callsign label
	[cell.dateLabel setText:[[rootData objectAtIndex:indexPath.row] objectForKey:@"date"]];

	
	// message label
	[cell.msgLabel setText:[[rootData objectAtIndex:indexPath.row] objectForKey:@"text"]];
	
	
	[cell setTag:[[[rootData objectAtIndex:indexPath.row] objectForKey:@"id"] intValue]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
