//
//  Data.m
//  iBCNU
//
//  Created by David Ponevac on 5/13/09.
//  Copyright 2009 Seven Minds LLC. All rights reserved.
//
// SEND MESSAGE:
// - write MSG to socket
// - prepare MSG as XML and send to iBCNU server
// - store in SQL tblOutbox
// - reload outbox table
//
// RECEIVE MESSAGE:
// - check for messages periodically
// - if change in num of messages ask for XML from iBCNU server
// - parse XML and load messages to array and to SQL
// - reload inbox table
//
// SEND LOCATION:
// - format packet based on settings
// - write packet to socket
// - format packet as XML and send to iBCNU server

#import "Data.h"


@implementation Data

@synthesize callsign;
@synthesize checkMessagesTimer;
@synthesize connections;

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Class methods

/**
 * Class constructor
 *
 * @return id
 */
- (id)init
{
	self = [super init];
	
	// init callsign
	[self setCallsign:nil];
	
	// init connections
	connections = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	// start message timer
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(fireCheckMessagesTimer:) userInfo:nil repeats:YES];
	[self setCheckMessagesTimer:timer];
	
	return self;
}//func

/**
 * Clean up
 */
- (void)dealloc
{
	[self.connections release];
	
	[self.checkMessagesTimer invalidate];
	[self setCheckMessagesTimer:nil];
	
	[super dealloc];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Aux methods

/**
 * encode data to base 64
 */
+ (NSString *)base64Encode:(NSString *)string
{
	if ([string length] == 0)
	{
		return @"";
	}//if
	
    char *characters = malloc((([string length] + 2) / 3) * 4);
	
	if (characters == NULL)
	{
		return nil;
	}
	
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [string length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [string length])
			buffer[bufferLength++] = ((char *)[string UTF8String])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

/**
 * Prepare base64 encoded string for POST or GET transmission
 */
+ (NSString *)prepareBase64String:(NSString *)string
{
	string = [string stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
	string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	string = [string stringByReplacingOccurrencesOfString:@"=" withString:@","];
	
	return string;
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Messaging methods

/**
 * Send XML with message content to the server
 */
+ (void)storeMessageOnServer:(NSDictionary *)params
{
	NSString *xml = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><messages><message><from_call>%@</from_call><to_call>%@</to_call><unproto>XML</unproto><text><![CDATA[%@]]></text></message></messages>", [params objectForKey:@"fromCall"], [params objectForKey:@"toCall"], [params objectForKey:@"text"]];
	xml = [self base64Encode:xml];
	NSString *link = [NSString stringWithFormat:@"http://ibcnu.us/xml_in?xml=%@", [self prepareBase64String:xml]];
	NSURL *url = [NSURL URLWithString:link];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:50];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately:YES];
	
	if (connection != nil)
	{
		[connection release];
	}//if
}//func

/**
 * Send XML with position data to the server
 * NEEDS TO BE SYNCHRONOUS
 */
+ (void)storePositionOnServer:(NSDictionary *)params
{
	NSString *xml;
	
	// create message based on locator
	if ([params objectForKey:@"locator"] == nil)
	{
		xml = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><positions><position><from_call>%@</from_call><unproto>XML</unproto><msg_type>%@</msg_type><message><![CDATA[%@]]></message><longitude>%@</longitude><lon_orient>%@</lon_orient><latitude>%@</latitude><lat_orient>%@</lat_orient><table>%@</table><symbol>%@</symbol></position></positions>", [params objectForKey:@"fromCall"], [params objectForKey:@"msgType"], [params objectForKey:@"message"], [params objectForKey:@"longitude"], [params objectForKey:@"lonOrient"], [params objectForKey:@"latitude"], [params objectForKey:@"latOrient"], [params objectForKey:@"table"], [params objectForKey:@"symbol"]];
	}
	else
	{
		xml = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><positions><position><from_call>%@</from_call><unproto>XML</unproto><msg_type>%@</msg_type><message><![CDATA[%@]]></message><locator>%@</locator><table>%@</table><symbol>%@</symbol></position></positions>", [params objectForKey:@"fromCall"], [params objectForKey:@"msgType"], [params objectForKey:@"message"], [params objectForKey:@"locator"], [params objectForKey:@"table"], [params objectForKey:@"symbol"]];
	}//if

	xml = [self base64Encode:xml];
	NSString *link = [NSString stringWithFormat:@"http://ibcnu.us/xml_in?xml=%@", [self prepareBase64String:xml]];
	NSURL *url = [NSURL URLWithString:link];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
	
	NSURLResponse *theResponse = nil;
	NSError *theError = nil;

	// sync request
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&theError];
	
	if ((data == nil) || (theError != nil))
	{

	}//if
	
	xml = nil;
	link = nil;
	url = nil;
	request = nil;
	data = nil;
}//func

/**
 * Send XML with position data to the server
 */
+ (void)deleteMessageFromServer:(int)messageID callsign:(NSString *)callsign
{
	NSString *xml = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><delete><message><id>%d</id><callsign>%@</callsign></message></delete>", messageID, callsign];
	xml = [self base64Encode:xml];
	NSString *link = [NSString stringWithFormat:@"http://ibcnu.us/xml_in?xml=%@", [self prepareBase64String:xml]];
	
	NSLog(@"%@\n", link);
	
	NSURL *url = [NSURL URLWithString:link];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately:YES];
	
	if (connection != nil)
	{
		[connection release];
	}//if
	
	xml = nil;
	link = nil;
	url = nil;
	request = nil;
}//func

/**
 * Get messages in XML format
 * Need to track this connection
 */
- (void)getMessagesFromServer
{
	if ([self callsign] == nil)
	{
		return;
	}//if

	NSString *link = [NSString stringWithFormat:@"http://ibcnu.us/xml_out?request=inbox&callsign=%@", [self callsign]];
	NSURL *url = [NSURL URLWithString:link];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	NSString *cID = [NSString stringWithFormat:@"%@", connection];
	
	if (connection != nil)
	{
		NSArray *array = [[NSArray alloc] initWithObjects:@"getMessages", [NSMutableData data], nil];
		
		[connections setObject:array forKey:cID];
		
		[array release];
	}//if

	cID = nil;
	link = nil;
	url = nil;
	request = nil;
}//func

/**
 * Ask server for number of messages
 * Need to track this connection
 */
- (void)checkNewMessages
{
	if ([self callsign] == nil)
	{
		return;
	}//if
	
	NSString *link = [NSString stringWithFormat:@"http://ibcnu.us/xml_out?request=get_count&callsign=%@", [self callsign]];
	NSURL *url = [NSURL URLWithString:link];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	NSString *cID = [NSString stringWithFormat:@"%@", connection];
	
	if (connection != nil)
	{
		NSArray *array = [[NSArray alloc] initWithObjects:@"checkMessages", [NSMutableData data], nil];

		[connections setObject:array forKey:cID];

		[array release];
	}//if

	link = nil;
	url = nil;
	request = nil;
	cID = nil;
}//func

/**
 * process XML messages
 */
- (void)processMessages:(NSData *)xml
{
	// indicator - start
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// get data from xml
	NSXMLParser *feedParser = [[NSXMLParser alloc] initWithData:xml];
	[feedParser setDelegate:self];
	BOOL success = [feedParser parse];
	if (!success)
	{

	}//if
	[feedParser release];
	
	// stop
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}//func

/**
 * Process incomming data
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	NSArray *arrayObject = [connections objectForKey:[NSString stringWithFormat:@"%@", connection]];
	
	if ([arrayObject count] <= 0)
	{
		return;
	}//if
	
	// incrementaly store data for connection
	[[[connections objectForKey:[NSString stringWithFormat:@"%@", connection]] objectAtIndex:1] appendData:data];
}//func

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", error);
	
	// remove from connection tracking
	[connections removeObjectForKey:[NSString stringWithFormat:@"%@", connection]];
	
	[connection release];
}//func

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// reset data store
	[[[connections objectForKey:[NSString stringWithFormat:@"%@", connection]] objectAtIndex:1] setLength:0];
}//func

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSArray *arrayObject = [connections objectForKey:[NSString stringWithFormat:@"%@", connection]];
	
	if ([arrayObject count] <= 0)
	{
		return;
	}//if
	
	// check msgs is returning data
	if ([[arrayObject objectAtIndex:0] compare:@"checkMessages"] == NSOrderedSame)
	{
		// move
		NSString *rcvString = [[NSString alloc] initWithData:[[connections objectForKey:[NSString stringWithFormat:@"%@", connection]] objectAtIndex:1] encoding:NSUTF8StringEncoding];
		NSInteger numMessages = [rcvString intValue];
		
		// check for difference
		int numOldMessages = 0;
		if ([Data connectToDB])
		{
			numOldMessages = [Data countMessages:@"tblInbox"];
			[Data closeDB];
		}//if
		
		if (numMessages > numOldMessages)
		{
			// fetch the data
			[self getMessagesFromServer];
		}//if
	}//if
	
	// get messages from server
	if ([[arrayObject objectAtIndex:0] compare:@"getMessages"] == NSOrderedSame)
	{		
		// insert into SQL lite
		[self processMessages:[[connections objectForKey:[NSString stringWithFormat:@"%@", connection]] objectAtIndex:1]];
		
		// issue notification
		[[NSNotificationCenter defaultCenter] postNotificationName:@"_NOTIFY_NEW_MSG_RCVD" object:nil];
	}//if
	
	// remove from connection tracking
	[connections removeObjectForKey:[NSString stringWithFormat:@"%@", connection]];
	
	[connection release];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark SQL methods

/**
 * Connect to DB
 */
+ (BOOL)connectToDB
{
	const char *dbFile = [[CommonTools getDataFilePath:_DB_FILE] cStringUsingEncoding:NSASCIIStringEncoding];
	
	if (sqlite3_open(dbFile, &db) != SQLITE_OK)
	{
		sqlite3_close(db);
		
		NSLog(@"Can't connect to DB\n");
		
		return NO;
	}//if
	
	[self prepareDB];
	
	return YES;
}//func

/**
 * Close link to db
 */
+ (void)closeDB
{
	sqlite3_close(db);
	db = NULL;
}//func

/**
 * Prepare required tables
 */
+ (void)prepareDB
{
	NSArray *queries = [NSArray arrayWithObjects:
						@"CREATE TABLE IF NOT EXISTS tblInbox  (messageID_n INTEGER PRIMARY KEY, callsign_c TEXT, message_c TEXT, date_d TEXT, new_n INTEGER);",
						@"CREATE TABLE IF NOT EXISTS tblOutbox (messageID_n INTEGER PRIMARY KEY AUTOINCREMENT, callsign_c TEXT, message_c TEXT, date_d TEXT, new_n INTEGER);",
						nil];
	
	char *errorMsg;
	NSInteger i = 0;
	
	// create tables
	for (i = 0; i < [queries count]; i++)
	{
		if (sqlite3_exec(db, [[queries objectAtIndex:i] UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
		{
			sqlite3_free(errorMsg);
		}//if
	}//for
}//if

/**
 * Store inbox or outbox messages
 */
+ (int)storeMessageInDB:(NSDictionary *)data table:(NSString *)table
{
	NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (messageID_n, callsign_c, message_c, date_d, new_n) VALUES (%@, '%@', '%@', '%@', 1);", table, [data objectForKey:@"messageID"], [data objectForKey:@"callsign"], [data objectForKey:@"message"], [data objectForKey:@"date"]];
	
	NSLog(@"%@", query);
	
	char *errorMsg;
	
	if (sqlite3_exec(db, [query UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		sqlite3_free(errorMsg);
		
		return 0;
	}//if
	
	int lastID = sqlite3_last_insert_rowid(db);
	
	return lastID;
}//func

/**
 * Marek all messages as read
 */
+ (BOOL)markMessagesRead:(NSString *)table
{
	NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET new_n = 0", table];
	
	NSLog(@"%@", query);
	
	char *errorMsg;
	
	if (sqlite3_exec(db, [query UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		sqlite3_free(errorMsg);
		
		return NO;
	}//if
	
	return YES;
}//func

/**
 * Count number of new messages
 */
+ (int)countNewMessages:(NSString *)table
{
	// array to store results in temporarily
	int messages = 0;
	
	NSString *query = [NSString stringWithFormat:@"SELECT COUNT(new_n) FROM %@ WHERE new_n = 1;", table];
	
	NSLog(@"%@", query);
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			messages = sqlite3_column_int(statement, 0);
		}//while
		
		// release
		sqlite3_finalize(statement);
	}//if
	
	return messages;
}//func

/**
 * Count number of messages
 */
+ (int)countMessages:(NSString *)table
{
	// array to store results in temporarily
	int messages = 0;
	
	NSString *query = [NSString stringWithFormat:@"SELECT COUNT(messageID_n) FROM %@;", table];
	
	NSLog(@"%@", query);
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			messages = sqlite3_column_int(statement, 0);
		}//while
		
		// release
		sqlite3_finalize(statement);
	}//if
	
	return messages;
}//func

/**
 * Retrieve messages from DB
 */
+ (NSArray *)getMessagesFromDB:(NSString *)table
{
	// array to store results in temporarily
	NSMutableArray *results = [[NSMutableArray alloc] init];
	
	NSString *query = [NSString stringWithFormat:@"SELECT messageID_n, callsign_c, message_c, date_d, new_n FROM %@ ORDER BY messageID_n DESC;", table];
	
	NSLog(@"%@", query);
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
	{
		int row = 0;
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			int messageID_n = sqlite3_column_int(statement, 0);
			char *callsign_c = (char *)sqlite3_column_text(statement, 1);
			char *message_c = (char *)sqlite3_column_text(statement, 2);
			char *date_d = (char *)sqlite3_column_text(statement, 3);
			int new_n = sqlite3_column_int(statement, 4);
			
			// store in array
			[results insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithInt:messageID_n], @"messageID",
								   [NSString stringWithUTF8String:callsign_c], @"callsign",
								   [NSString stringWithUTF8String:message_c], @"message",
								   [NSString stringWithUTF8String:date_d], @"date",
								   [NSNumber numberWithInt:new_n], @"new",
								   nil] atIndex:row];
			
			row++;
		}//while
		
		// release
		sqlite3_finalize(statement);
	}//if
	
	return results;
}//func

/**
 * Retrieve messages from DB
 */
+ (BOOL)deleteMessageFromDB:(NSString *)table message:(int)messageID
{	
	NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE messageID_n = %d;", table, messageID];
	
	NSLog(@"%@", query);
	
	char *errorMsg;
	
	if (sqlite3_exec(db, [query UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		sqlite3_free(errorMsg);
		
		return NO;
	}//if
	
	return YES;
}//func

/**
 * get the value of db
 */
+ (BOOL)isDbSet
{
	return db != NULL;
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
	if ([elementName compare:@"message"] == NSOrderedSame)
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
	if ([elementName compare:@"message"] == NSOrderedSame)
	{
		if ([Data connectToDB])
		{
			NSDictionary *sqlData = [NSDictionary dictionaryWithObjectsAndKeys:
									 [currentItem objectForKey:@"id"], @"messageID",
									 [currentItem objectForKey:@"fromCallsign"], @"callsign",
									 [currentItem objectForKey:@"text"], @"message",
									 [currentItem objectForKey:@"date"], @"date",
									 nil];
			[Data storeMessageInDB:sqlData table:@"tblInbox"];
			sqlData = nil;
			
			[Data closeDB];
		}//if

		[currentItem release];
	}
	else if (currentItem && currentContents)
	{
		[currentItem setObject:currentContents forKey:elementName];
		currentContents = nil;
		[currentContents release];
	}//if
}//func

/**
 * Parsing ended, store MSGS in SQL
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{

}//func


#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Timer methods

/**
 * Fire check timer
 */
- (void)fireCheckMessagesTimer:(NSTimer *)theTimer
{
	[self checkNewMessages];
}//func

@end
