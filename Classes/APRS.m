//
//  APRS.m
//  iBCNU
//
//  Created by David Ponevac on 4/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APRS.h"

@implementation APRS

@synthesize serverHost;
@synthesize serverPort;

@synthesize sock_fd;
@synthesize callsign;
@synthesize toCallsign;
@synthesize statusMessage;
@synthesize textMessage;
@synthesize longitude;
@synthesize latitude;
@synthesize speed;
@synthesize course;
@synthesize altitude;
@synthesize altitudeAccuracy;
@synthesize horizontalAccuracy;
@synthesize GPSData;
@synthesize filter;
@synthesize numBeaconsSent;
@synthesize lastBeacon;
@synthesize aprsLog;
@synthesize connectionTimer;
@synthesize lastPing;
@synthesize connected;
@synthesize connecting;
@synthesize beaconing;
@synthesize sendLoc;
@synthesize closeStations;
@synthesize filterRange;
@synthesize distanceRange;
@synthesize icon;
@synthesize dataTX;
@synthesize dataRX;

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
	
	
	// zero out some vars
	sock_fd = 0;
	cnt = 0;
	bzero(buffer, sizeof(buffer));
	
	// message count starts with 1
	messageOutCount = 1;
	
	// GPS info
	latitude = 0.0;
	longitude = 0.0;
	speed = 0;
	course = 0;
	altitudeAccuracy = -1;
	horizontalAccuracy = -1;
	
	// number of beacons sent out
	numBeaconsSent = 0;

	// last beacon
	[self setLastBeacon:nil];

	// zero out the msg log
	self.aprsLog = [[NSMutableArray alloc] initWithCapacity:0];
	
	// last ping
	[self setLastPing:nil];
	
	// connected - no
	[self setConnected:NO];
	
	// connecting - no
	[self setConnecting:NO];
	
	// beaconing - no
	[self setBeaconing:NO];
	
	// loaction only - no
	[self setSendLoc: NO];
	
	// init station arrays
	self.closeStations = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	// reset counters
	self.dataTX = 0.0;
	self.dataRX = 0.0;
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// read in settings
	NSDictionary *appSettings;
	NSArray *appSettingsKeys = [[NSArray alloc] init];
	NSString *filePath = [CommonTools getDataFilePath:_DATA_FILE];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		appSettings = [[NSDictionary alloc] initWithContentsOfFile:filePath];
		if ([appSettings count] > 0)
		{
			appSettingsKeys = [appSettings allKeys];
		}//if
	}//if
	
	// get stored callsign if any
	NSString *call = [appSettingsKeys containsObject:_TAG_CALLSIGN] ? [appSettings objectForKey:_TAG_CALLSIGN] : nil;
	[self setCallsign:[self validateCallsign:call] ? call : nil];
	
	// set whether to send locator
	self.sendLoc = [appSettingsKeys containsObject:@"_SEND_LOC"] ? [[appSettings objectForKey:@"_SEND_LOC"] boolValue] : NO;
	
	// set the status msg
	self.statusMessage = [appSettingsKeys containsObject:_TAG_STATUSMSG] ? [appSettings objectForKey:_TAG_STATUSMSG] : nil;
	
	// range for the filter
	self.filterRange = [appSettingsKeys containsObject:_TAG_RANGE] ? [appSettings objectForKey:_TAG_RANGE] : [NSNumber numberWithInt:50];
	
	// distance range
	self.distanceRange = [appSettingsKeys containsObject:_TAG_DISTANCE] ? [appSettings objectForKey:_TAG_DISTANCE] : [NSNumber numberWithInt:50];
	
	// set host
	self.serverHost = [appSettingsKeys containsObject:_TAG_SERVERHOST] ? [appSettings objectForKey:_TAG_SERVERHOST] : [NSString stringWithFormat:@"%s", _HOST];
	
	// set port
	self.serverPort = [appSettingsKeys containsObject:_TAG_SERVERPORT] ? [[appSettings objectForKey:_TAG_SERVERPORT] intValue] : _PORT;
	
	// set icon
	self.icon = [appSettingsKeys containsObject:_TAG_ICON] ? [appSettings objectForKey:_TAG_ICON] : @"1_4_1";
	
	// clean up
	call = nil;
	filePath = nil;
	appSettings = nil;
	appSettingsKeys = nil;
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	return self;
}//func

/**
 * Clean up
 */
- (void)dealloc
{
	[self disconnectFromAPRS];
	
	callsign = nil;
	
	toCallsign = nil;
	
	statusMessage = nil;
	textMessage = nil;
	
	[closeStations release];
	
    [super dealloc];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark APRS methods

/**
 * Connect to the APRS server, authenticate and set filter
 *
 * @return BOOL
 */
- (BOOL)connectToAPRS
{
	if ([self connecting])
	{
		return NO;
	}//if
	
	// we are connecting
	[self setConnecting:YES];
	
	if([self validateAPRSData] == NO)
	{
		[self insertIntoLog:@"Can't validate basic APRS data."];
		NSLog(@"Can't validate data\n");
		
		return NO;
	}//if
	
	// start activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// prime net connection
	if (![CommonTools tripConnection:"www.google.com" port:80])
	{
		[self insertIntoLog:@"Can't start net connection."];
		NSLog(@"Can't start net connection\n");
		
		[self disconnectFromAPRS];
		
		return NO;
	}//if
	
	// if connected, dont bother
	if ([self connected])
	{
		return YES;
	}//if
	
	// create a socked
	if ((sock_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
	{
		[self insertIntoLog:@"Can't create BSD sock."];
		NSLog(@"Can't create sock\n");
		
		[self disconnectFromAPRS];
		
		return NO;
	}//if
	
	struct sockaddr_in addr;
	struct hostent *hp;
	
	addr.sin_port = htons(serverPort);
	addr.sin_family = AF_INET;
	
	hp = gethostbyname([serverHost UTF8String]);
	
	if (hp == NULL)
	{
		[self insertIntoLog:@"Can't get IPs for APRS host."];
		NSLog(@"Gethostbyname failed\n");
		
		[self disconnectFromAPRS];
		
		return NO;
	}//if
	
	// number of IPs returned
	int numIPs = 0;
	while (hp->h_addr_list[numIPs] != NULL)
	{
		numIPs++;
	}//if
	
	if (numIPs == 0)
	{
		[self insertIntoLog:@"APRS host has no IPs."];
		NSLog(@"No addresses\n");
		
		[self disconnectFromAPRS];
		
		return NO;
	}//if
	
	// main connect logic - try to connect multiple times
	int numTries = 0;
	
	while (![self connected] && (numTries < _NUM_TRIES))
	{
		// generate random IP num
		int randIP = arc4random() % numIPs;
		
		// copy
		bcopy(hp->h_addr_list[randIP], &addr.sin_addr, hp->h_length);
		
		// connect
		if ((connect(sock_fd, (struct sockaddr *)&addr, sizeof(addr))) < 0)
		{
			[self insertIntoLog:@"Can't connect to to APRS server"];
			NSLog(@"Can't connect to APRS server\n");
			
			[self disconnectFromAPRS];
			
			return NO;
		}//if
		
		// zero the buffer
		bzero(buffer, sizeof(buffer));
		
		// read from aprs server
		if ((cnt = read(sock_fd, buffer, sizeof(buffer))) < 0)
		{
			[self insertIntoLog:@"Can't read from APRS server."];
			NSLog(@"Can't read from APRS server\n");
			
			[self disconnectFromAPRS];
			
			return NO;
		}//if
		
		// inc RX counter
		self.dataRX += cnt;
		
		// check if we connected to APRS
		if (strstr(buffer, "javAPRSSrvr") == NULL)
		{
			[self insertIntoLog:@"Invalid response from APRS server."];
			NSLog(@"Invalid response from APRS server\n");
			
			[self disconnectFromAPRS];
			
			return NO;
		}//if
		
		// check if port full
		if (strstr(buffer, "Port Full") != NULL)
		{
			[self insertIntoLog:@"Port full on APRS server."];
			NSLog(@"Port full on APRS server\n");
		}
		else
		{
			[self setConnected:YES];
		}//if
		
		// inc tries
		numTries++;
	}//while
	
	// last sanity check
	if (![self connected])
	{
		[self insertIntoLog:@"Unable to connect to APRS server."];
		NSLog(@"Unable to connect!\n");
		
		[self disconnectFromAPRS];
		
		return NO;
	}//if
	
	// reset connected to NO, we are not done yet
	[self setConnected:NO];
	
	// prepare login message
	const char *callsign_c = [[[callsign stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	short password_c = [self getAPRSPassword:callsign_c];
	
	// set filter
	[self setFilter:[NSString stringWithFormat:@"%s", callsign_c]];	

	char msg[_SEND_BUFFER];
	bzero(msg, sizeof(msg));
	sprintf(msg, "user %s pass %hi vers %s %s filter u/%s m/%d\r\n", callsign_c, password_c, [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] cStringUsingEncoding:NSASCIIStringEncoding], [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] cStringUsingEncoding:NSASCIIStringEncoding], [filter cStringUsingEncoding:NSASCIIStringEncoding], [self.filterRange intValue]);
	
	// log message
	[self insertIntoLog:[NSString stringWithFormat:@"%s", msg]];
	NSLog(@"%s\n", msg);
	
	// write login message to server
	write(sock_fd, msg, sizeof(msg));
	
	// inc TX counter
	self.dataTX += strlen(msg);
	
	// zero the buffer
	bzero(buffer, sizeof(buffer));
	
	// read from aprs server
	if ((cnt = read(sock_fd, buffer, sizeof(buffer))) < 0)
	{
		[self insertIntoLog:@"Can't read from APRS server."];
		NSLog(@"Can't read from APRS server\n");
		
		[self disconnectFromAPRS];
		
		return NO;
	}//if
	
	// inc RX counter
	self.dataRX += cnt;
	
	// output
	NSLog(@">%s\n", buffer);
	
	// check returned data
	if (strstr(buffer, "# logresp") == NULL)
	{
		[self insertIntoLog:@"Invalid response from APRS server."];
		NSLog(@"Invalid response from APRS server\n");
		
		[self disconnectFromAPRS];
		
		return NO;
	}//if
	
	// check returned data
	if (strstr(buffer, "unverified") != NULL)
	{
		[self insertIntoLog:@"Invalid response from APRS server."];
		NSLog(@"Invalid response from APRS server\n");
		
		[self disconnectFromAPRS];
		
		return NO;
	}//if
	
	// make non blocking
	//if (fcntl(sock_fd, F_SETFL, O_NONBLOCK))
	//{
	//	NSLog(@"Can't set O_NONBLOCK\n");
	//	close(sock_fd);
	
	//	return NO;
	//}//if
	
	// send filter to pick up messages for callsign
	bzero(msg, sizeof(msg));
	sprintf(msg, "# filter u/%s m/%d\r\n", [self.filter cStringUsingEncoding:NSASCIIStringEncoding], [self.filterRange intValue]);
	write(sock_fd, msg, sizeof(msg));
	
	// inc TX counter
	self.dataTX += strlen(msg);
	
	// log message
	[self insertIntoLog:[NSString stringWithFormat:@"%s", msg]];
	NSLog(@"%s\n", msg);
	
	// write banner
	bzero(msg, sizeof(msg));
	sprintf(msg, "%s>%s v%s\r\n", callsign_c, _APP_NAME, [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] cStringUsingEncoding:NSASCIIStringEncoding]);
	write(sock_fd, msg, sizeof(msg));
	
	// inc TX counter
	self.dataTX += strlen(msg);
	
	// log message
	[self insertIntoLog:[NSString stringWithFormat:@"%s", msg]];
	NSLog(@"%s\n", msg);
	
	// stop activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// connected for sure
	[self setConnected:YES];
	
	// reset connecting flag
	[self setConnecting:NO];
	
	// start reading from filehandle on the main thread
	[self performSelectorOnMainThread:@selector(bindAsyncReader) withObject:nil waitUntilDone:false];
	
	// notify other classes of change
	[[NSNotificationCenter defaultCenter] postNotificationName:@"_NOTIFY_CONN_CHANGED" object:nil];
	
	return YES;
}//func

/**
 * If connected, start reading on background
 */
- (void)bindAsyncReader
{
	if ([self connected])
	{
		// setup async reading from socket
		// http://code.google.com/p/iphone-elite/source/browse/trunk/ZiPhoneOSX/ZiPhoneWindowController.m?r=617
		NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
		NSFileHandle *fh = [[NSFileHandle alloc] initWithFileDescriptor:sock_fd];
		[fh readInBackgroundAndNotify];
		[defaultCenter addObserver:self selector:@selector(readMessage:) name:NSFileHandleReadCompletionNotification object:fh];
		[fh release];
	}//if
}//func

/**
 * Disconnect from the APRS server
 *
 * @return void
 */
- (void)disconnectFromAPRS
{
	if (sock_fd != 0)
	{
		close(sock_fd);
		sock_fd = 0;
	}//if
	
	// stop activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// not connected
	[self setConnected:NO];
	
	// reset connecting flag
	[self setConnecting:NO];
	
	// notify other classes of change
	[[NSNotificationCenter defaultCenter] postNotificationName:@"_NOTIFY_CONN_CHANGED" object:nil];
}//func

/**
 * Construct APRS beacon message
 *
 * @return BOOL
 */
- (BOOL)sendAPRSBeacon
{
	// if not connected, attempt to make a connection
	if (![self connected])
	{
		if ([self connectToAPRS] == NO)
		{
			return NO;
		}//if
	}//if
	
	// if already sending beacon return here
	if ([self beaconing])
	{
		return YES;
	}//if
	
	// if beaconing too fast, return here
	if ([self lastBeacon] != nil)
	{
		NSTimeInterval interval =  ([self.lastBeacon timeIntervalSinceNow] * -1);
		
		// 10 seconds minimum
		if (interval < 9)
		{
			NSLog(@"%f", interval);
			
			[self insertIntoLog:@"Beaconing too fast. Limiting to 1 bcn / 10 secs."];
			
			return YES;
		}//if
	}//if
	
	self.beaconing = YES;

	// has position?
	BOOL hasPos = NO;
	
	// create msg buffer
	char beacon[_SEND_BUFFER];
	bzero(beacon, sizeof(beacon));
	
	// shorten the msg
	if ([statusMessage length] > 43)
	{
		[self setStatusMessage: [statusMessage substringToIndex:43]];
	}//if
	
	
	// if we have GPS coord, add them, otherwise send only blank msg
	if ([self horizontalAccuracy] >= 0)
	{
		hasPos = YES;

		// send full coords or just the locator?
		if ([self sendLoc])
		{
			sprintf(beacon, "[%s]%s",
					[[GPS getGridSquare:1 longitude:longitude latitude:latitude] cStringUsingEncoding:NSASCIIStringEncoding],
					statusMessage == nil ? "" : [statusMessage cStringUsingEncoding:NSASCIIStringEncoding]);
		}
		else
		{
			// get date
			NSDate *now = [NSDate date];
			
			NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			[cal setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
			
			NSDateComponents *comps = [cal components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:now];
			
			NSInteger day = [comps day];
			NSInteger hours = [comps hour];
			NSInteger minutes = [comps minute];
			
			[cal release];
			
			// get symbol
			NSArray *APRSSymbol = [CommonTools lookupAPRSIcon:[self icon]];
			
			// validate altitude
			NSString *altitudeString = [self altitudeAccuracy] >= 0 ? [NSString stringWithFormat:@"/A=%06.0f ", [self altitude]] : @" ";
			
			sprintf(beacon, "@%02d%02d%02dz%s%s%s%s%03.0f/%03.0f%s%s", day, hours, minutes,
					[[GPS latitude2String:latitude APRSFormat:YES] cStringUsingEncoding:NSASCIIStringEncoding],
					[[APRSSymbol objectAtIndex:0] cStringUsingEncoding:NSASCIIStringEncoding],
					[[GPS longitude2String:longitude APRSFormat:YES] cStringUsingEncoding:NSASCIIStringEncoding],
					[[APRSSymbol objectAtIndex:1] cStringUsingEncoding:NSASCIIStringEncoding],
					[self course], [self speed], [altitudeString cStringUsingEncoding:NSASCIIStringEncoding],
					statusMessage == nil ? "" : [statusMessage cStringUsingEncoding:NSASCIIStringEncoding]);
		}//if
	}
	else
	{
		hasPos = NO;
		sprintf(beacon, ">%s",
				statusMessage == nil ? "" : [statusMessage cStringUsingEncoding:NSASCIIStringEncoding]);
	}//if
	
	if([self APRSSendBeaconData:beacon position:hasPos])
	{
		self.beaconing = NO;
		
		return YES;
	}//if
	
	self.beaconing = NO;
	
	return NO;
}//func

/**
 * Format data for APRS beacon
 *
 * @param const char* data_c
 * @return BOOL
 */
- (BOOL)APRSSendBeaconData:(const char*)data_c position:(BOOL)included
{
	if (![self connected] || ([self validateAPRSData] == NO))
	{
		return NO;
	}//if
	
	// prepare callsign
	const char *callsign_c = [[[callsign stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	
	// create msg buffer
	char msg[_SEND_BUFFER];
	bzero(msg, sizeof(msg));
	
	if ([self sendLoc])
	{
		sprintf(msg, "%s>APRS:%s\r\n", callsign_c, data_c);
	}
	else if (included)
	{
		sprintf(msg, "%s>APRS:%s\r\n", callsign_c, data_c);
	}
	else
	{
		sprintf(msg, "%s>BEACON:%s\r\n", callsign_c, data_c);
	}//if
	
	// write to server
	write(sock_fd, msg, sizeof(msg));
	
	// inc TX counter
	self.dataTX += strlen(msg);
	
	// log message
	[self insertIntoLog:[NSString stringWithFormat:@"%s", msg]];
	
	// get symbol
	NSArray *APRSSymbol = [CommonTools lookupAPRSIcon:[self icon]];
	
	// if we have coords, save to server
	if (included)
	{
		NSDictionary *params;
		
		if ([self sendLoc])
		{
			params = [NSDictionary dictionaryWithObjectsAndKeys:
									[self callsign], @"fromCall",
									@"@", @"msgType",
									[NSString stringWithFormat:@"%s", data_c], @"message",
									[GPS getGridSquare:1 longitude:longitude latitude:latitude], @"locator",
									[APRSSymbol objectAtIndex:0], @"table",
									[APRSSymbol objectAtIndex:1], @"symbol",
									nil];
		}
		else
		{
			params = [NSDictionary dictionaryWithObjectsAndKeys:
									[self callsign], @"fromCall",
									@"@", @"msgType",
									[NSString stringWithFormat:@"%s", data_c], @"message",
									[GPS longitude2String:longitude APRSFormat:YES], @"longitude",
									longitude < 0 ? @"W" : @"E", @"lonOrient",
									[GPS latitude2String:latitude APRSFormat:YES], @"latitude",
									latitude < 0 ? @"S" : @"N", @"latOrient",
									[APRSSymbol objectAtIndex:0], @"table",
									[APRSSymbol objectAtIndex:1], @"symbol",
									nil];
		}//if
		
		[Data storePositionOnServer:params];
	}//if
	
	// inc counter
	numBeaconsSent++;
	
	// save timestamp
	[self setLastBeacon:[NSDate date]];

	// notify other classes of new beacon
	[[NSNotificationCenter defaultCenter] postNotificationName:@"_NOTIFY_NEW_BCN_SNT" object:nil];
	
	return YES;
}//func

- (BOOL)sendAPRSFilter
{
	// create msg buffer
	char msg[_SEND_BUFFER];
	bzero(msg, sizeof(msg));
	
	// send filter to pick up messages for callsign
	sprintf(msg, "# filter u/%s m/%d\r\n", [self.filter cStringUsingEncoding:NSASCIIStringEncoding], [self.filterRange intValue]);
	write(sock_fd, msg, sizeof(msg));
	
	// inc TX counter
	self.dataTX += strlen(msg);
	
	// log message
	[self insertIntoLog:[NSString stringWithFormat:@"%s", msg]];
	NSLog(@"%s\n", msg);
	
	return YES;
}

/**
 * Let users send custom APRS filter
 */
- (BOOL)sendCustomAPRSFilter:(NSString *)customFilter
{
	// create msg buffer
	char msg[_SEND_BUFFER];
	bzero(msg, sizeof(msg));
	
	// send filter to pick up messages for callsign
	sprintf(msg, "%s\r\n", [customFilter cStringUsingEncoding:NSASCIIStringEncoding]);
	write(sock_fd, msg, sizeof(msg));
	
	// inc TX counter
	self.dataTX += strlen(msg);
	
	// log message
	[self insertIntoLog:[NSString stringWithFormat:@"%s", msg]];
	NSLog(@"%s\n", msg);
	
	return YES;
}

/**
 * Send text message to the APRS server for delivery
 */
- (BOOL)sendTextMessage
{
	// clean TO call
	//[self setToCallsign:[self removeSSID:toCallsign]];
	
	// if sock disconnected, reconnect
	if (![self connected])
	{
		[self connectToAPRS];
	}//if
	
	if (![self connected] || ([self validateCallsign:callsign] == NO) || ([self validateCallsign:toCallsign] == NO))
	{
		return NO;
	}//if
	
	// set up some vars
	const char *fromCallsign_c = [[[callsign stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	const char *toCallsign_c = [[[toCallsign stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	const char *textMessage_c = [[[textMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	
	// create msg buffer
	char msg[512];
	bzero(msg, sizeof(msg));
	
	int rand = arc4random() % 10000;
	
	sprintf(msg, "%s>%s::%-9s:%s {%d\r\n", fromCallsign_c, toCallsign_c, toCallsign_c, textMessage_c, rand);
	
	// log message
	[self insertIntoLog:[NSString stringWithFormat:@"%s", msg]];
	
	// write to server
	write(sock_fd, msg, sizeof(msg));
	
	// inc TX counter
	self.dataTX += strlen(msg);
	
	// send to iBCNU server
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[self callsign], @"fromCall",
							[self toCallsign], @"toCall",
							[NSString stringWithFormat:@"%@ {%d", textMessage, rand], @"text",
							nil];
	[Data storeMessageOnServer:params];
	
	// nil out
	textMessage_c = nil;
	
	// number of messages sent (for APRS packet)
	messageOutCount++;
	
	return YES;
}//func

/**
 * http://aprs.org/aprs11/replyacks.txt
 */
- (BOOL)sendACKPacket:(NSString *)toCall messageID:(NSString *)messageID
{	
	// if sock disconnected, reconnect
	if (![self connected])
	{
		[self connectToAPRS];
	}//if
	
	if (![self connected] || ([self validateCallsign:callsign] == NO) || ([self validateCallsign:toCall] == NO) || [messageID isEqualToString:@""])
	{
		return NO;
	}//if
	
	// set up some vars
	const char *fromCallsign_c = [[[callsign stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	const char *toCallsign_c = [[[toCall stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	
	// create msg buffer
	char msg[512];
	bzero(msg, sizeof(msg));
	
	sprintf(msg, "%s>%s::%-9s:ack%s\r\n", fromCallsign_c, toCallsign_c, toCallsign_c, [messageID cStringUsingEncoding:NSASCIIStringEncoding]);
	
	// log message
	[self insertIntoLog:[NSString stringWithFormat:@"%s", msg]];
	
	// write to server
	write(sock_fd, msg, sizeof(msg));
	
	// inc TX counter
	self.dataTX += strlen(msg);
	
	return YES;
}//func

/**
 * Note: The doHash(char*) function is Copyright Steve Dimse 1998
 * As of April 11 2000 Steve Dimse has released this code to the open source aprs community
 *
 * @param const char* realcall_c
 * @return short
 */
- (short)getAPRSPassword:(const char*)realcall_c
{
	char rootCall[10];
	char *p1 = rootCall;
	
	while ((*realcall_c != '-') && (*realcall_c != 0))
	{
		*p1++ = toupper(*realcall_c++);
	}
	
	*p1 = 0;
	
	// init
	short hash = 0x73e2;
	unsigned short i = 0;
	unsigned short length = strlen(rootCall);
	char *ptr = rootCall;
	
	// hash call sign two bytes at a time
	while (i < length)
	{
		hash ^= (*ptr++) << 8;
		hash ^= (*ptr++);
		
		i += 2;
	}//while
	
	return hash & 0x7fff;
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Validation methods

/**
 * Validate a callsign
 *
 * @param NSString * realcal
 * @return BOOL
 */
- (BOOL)validateCallsign:(NSString *)realcall
{
	NSInteger length = [realcall length];
	
	// check length
	if ((length < 3) || (length > 9))
	{
		return NO;
	}//if
	
	// patern check via regex.h
	regex_t compiledRE;
	char *pattern = "^[a-zA-Z0-9]{3,6}\\*?(-[0-9]{1,2})?$";
	
	if (regcomp(&compiledRE, pattern, REG_EXTENDED | REG_NOSUB | REG_NEWLINE) == 0)
	{
		const char *realcall_c = [realcall cStringUsingEncoding:NSASCIIStringEncoding];
		
		int matchRes = regexec(&compiledRE, realcall_c, (size_t) 0, NULL, 0);
		regfree(&compiledRE);
		
		// returns 0 for match
		if (matchRes != 0)
		{
			return NO;
		}//if
	}//if
	
	return YES;
}//func

/**
 * Validate a message
 *
 * @param NSString * msg
 * @return BOOL
 */
- (BOOL)validateTextMessage:(NSString *)msg
{
	NSInteger length = [msg length];
	
	if ((length < 1) || (length > 512))
	{
		return NO;
	}//if
	
	/*
	 NSString *regex = @"^[a-zA-Z0-9\\-\\*]+$";
	 
	 NSPredicate *regexTest = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regex];
	 
	 if ([regexTest evaluateWithObject:realcall] == NO)
	 {
	 return NO;
	 }//if
	 */
	
	return YES;
}//func

/**
 * Validate requied data
 *
 * @return BOOL
 */
- (BOOL)validateAPRSData
{
	return [self validateCallsign:callsign];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Processing methods


/**
 * Take data from the running task and display it to the screen.
 */
- (void)readMessage:(NSNotification *)notif
{
	NSData *incomingData = [[notif userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	// inc RX data
	self.dataRX += [incomingData length];
	
	if (incomingData && [incomingData length])
	{
		NSString *incomingText = [[NSString alloc] initWithData:incomingData encoding:NSASCIIStringEncoding];
		
		// split the input in case more lines arrived
		NSArray *incomingLines = [incomingText componentsSeparatedByString:@"\n"];

		// loop through the lines
		for (int i = 0; i < ([incomingLines count] - 1); i++)
		{
			NSString *incomingLine = [[incomingLines objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSLog(@"%@", incomingLine);

			// log server ping data
			if ([incomingLine characterAtIndex:0] == '#')
			{
				// record timestamp
				[self setLastPing:[NSDate date]];
				
				// start up timer
				if (connectionTimer == nil)
				{
					[self startConnectionTimer];
				}//if
				
				[self insertIntoLog:[NSString stringWithFormat:@"Ping from APRS server %@.", [CommonTools formatTimestamp:lastPing]]];
			}//if
			
			// check if this is MSG or comment
			if ([incomingLine characterAtIndex:0] != '#')
			{
				// record timestamp
				[self setLastPing:[NSDate date]];
				
				// start up timer
				if (connectionTimer == nil)
				{
					[self startConnectionTimer];
				}//if
				
				// parse the msg
				NSDictionary *fromData = [self processTextMessage:incomingLine];
				
				// proceed on valid callsign only
				if ([self validateCallsign:[fromData objectForKey:@"from"]] && ([fromData objectForKey:@"message"] != nil))
				{				
					// send to server
					NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
											[fromData objectForKey:@"from"], @"fromCall",
											[self callsign], @"toCall",
											[fromData objectForKey:@"message"], @"text",
											nil];
					[Data storeMessageOnServer:params];
				}//if
				
				// nil out
				fromData = nil;
			}//if
			
			incomingLine = nil;
		}//for
		
		incomingLines = nil;
		
		[[notif object] readInBackgroundAndNotify];
		[incomingText release];
	}//if
}//func

/**
 * Extract relevant information from received message string
 * Format MSG:AB3Y-IP>OM6IB,TCPIP*::OM6IB    :teste teste teste {13
 * Format POS:AB3Y-1>TCPIP*:@
 */
- (NSDictionary *)processTextMessage:(NSString *)msg
{
	// trim the MSG
	msg = [msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSString *fromCall = nil;
	NSString *fromMessage = nil;
	
	// extract from call
	NSRange range = [msg rangeOfString:@">"];
	if (range.location != NSNotFound)
	{
		fromCall = [[msg substringToIndex:range.location] uppercaseString];
	}//if
	
	// extract position station - look for :[@=!/]
	range = [msg rangeOfString:@"::"];
	if ((range.location == NSNotFound) && (fromCall != nil))
	{
		NSDictionary *stationInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"date", nil];
		[self.closeStations setObject:stationInfo forKey:fromCall];
		stationInfo = nil;
		
		// insert into log
		[self insertIntoLog:msg];
	}//if
	
	// extract message - look for ::
	range = [msg rangeOfString:@"::"];
	if (range.location != NSNotFound)
	{
		NSRange toCallRange;
		toCallRange.location = range.location + 2;
		toCallRange.length = 9;
		NSString *toCall = [[msg substringWithRange:toCallRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// check if fromCall is embedded in message
		if ([self validateCallsign:toCall] && [toCall isEqualToString:self.callsign])
		{
			// find "{" if any
			NSRange rangeNum = [msg rangeOfString:@"{"];
			if (rangeNum.location == NSNotFound)
			{
				fromMessage = [msg substringFromIndex:(range.location + 12)];
			}
			else
			{
				NSRange msgRange;
				msgRange.location = (range.location + 12);
				msgRange.length = rangeNum.location - msgRange.location;
				
				fromMessage = [msg substringWithRange:msgRange];
				
				// extract the ack num
				NSString *ack = [msg substringFromIndex:(rangeNum.location + 1)];
				[self sendACKPacket:fromCall messageID:ack];
			}//if

			// make sure we are not processing ack
			NSRange rangeAck = [[msg uppercaseString] rangeOfString:@":ACK"];
			if (rangeAck.location == NSNotFound)
			{
				// return the decoded message
				return [NSDictionary dictionaryWithObjectsAndKeys:fromCall,@"from",fromMessage,@"message",nil];
			}//if
		}//if
	}//if
	
	return [NSMutableDictionary dictionaryWithCapacity:0];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Helper methods


/**
 * Function removes SSID portion of call if present
 *
 * @param NSString * realcal
 * @return NSString *
 */
- (NSString *)removeSSID:(NSString *)realcall
{
	NSRange range = [realcall rangeOfString:@"-"];
	if (range.location == NSNotFound)
	{
		return realcall;
	}
	else
	{
		return [realcall substringToIndex:range.location];
	}//if
}//func

/**
 * Add object to the log queue
 */
- (void)insertIntoLog:(id)object
{
	if ([aprsLog count] > 20)
	{
		[aprsLog removeObjectAtIndex:0];
	}//if
	
	[aprsLog addObject:object];
}//func

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Timer methods

/**
 * check if connection is alive
 */
- (void)fireConnectionTimer:(NSTimer *)theTimer
{
	NSLog(@"tick - %d\n", [self connected]);
	NSDate *now = [[NSDate alloc] init];
	
	// determine last ping
	if (lastPing != nil)
	{
		NSTimeInterval interval =  [now timeIntervalSinceDate:[self lastPing]];
		
		if (interval > 60)
		{
			// disconnected
			[self disconnectFromAPRS];
			
			// long time since last ping, reconnect
			if ([self validateCallsign:callsign] && [self connectToAPRS])
			{
				[self insertIntoLog:[NSString stringWithFormat:@"Reconnected to APRS server %@.", [CommonTools formatTimestamp:[NSDate date]]]];
			}//if
			
			// notify other classes of change
			[[NSNotificationCenter defaultCenter] postNotificationName:@"_NOTIFY_CONN_CHANGED" object:nil];
		}
		else
		{
			[self setConnected:YES];
		}//if
	}//if
	
	[now release];
}//func

/**
 * Start connection checking timer
 */
- (void)startConnectionTimer
{
	// set the recuring interval
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(fireConnectionTimer:) userInfo:nil repeats:YES];
    [self setConnectionTimer:timer];
}//func

/**
 * Stop connection checking timer
 */
- (void)stopConnectionTimer
{
	[connectionTimer invalidate];
    [self setConnectionTimer:nil];
}//func

@end
