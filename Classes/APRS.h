//
//  APRS.h
//  iBCNU
//
//  Created by David Ponevac on 4/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CommonTools.h"
#import "GPS.h"
#import "Data.h"
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <fcntl.h>
#import <unistd.h>
#import <regex.h>

// APRS related defines
#define _HOST "rotate.aprs2.net"
#define _PORT 14580
#define _RECV_BUFFER 4096
#define _SEND_BUFFER 120
#define _NUM_TRIES 4

@interface APRS : NSObject
{
	// HOST NAME
	NSString *serverHost;
	
	// port
	NSUInteger serverPort;
	
	// sock descriptor
	int sock_fd;
	
	// number of bytes read in last read()
	int cnt;
	
	// read & write buffer
	char buffer[_RECV_BUFFER];
	
	// vars for setting FROM callsing
	NSString *callsign;
	
	// map icon
	NSString *icon;
	
	// vars for setting TO callsign
	NSString *toCallsign;
	
	// beacon status msg
	NSString *statusMessage;
	
	// text message
	NSString *textMessage;
	
	// GPS data for beacon
	double longitude;
	double latitude;
	double speed;
	double course;
	double altitude;
	double altitudeAccuracy;
	double horizontalAccuracy;
	CLLocation *GPSData;
	
	// APRS filter to be sent to the server
	NSString *filter;
	
	// message count for outgoing messages
	int messageOutCount;
	
	// number of beacons sent
	NSInteger numBeaconsSent;
	
	// last beacon
	NSDate *lastBeacon;
	
	// log of APRS communications
	NSMutableArray *aprsLog;
	
	// timer
	NSTimer *connectionTimer;
	
	// last time we received ping from server
	NSDate *lastPing;
	
	// connected or not - to be used instead of sock_fd
	BOOL connected;
	
	// check if we are connecting right now
	BOOL connecting;
	
	// check if we are already sending out beacon
	BOOL beaconing;
	
	// send out locator instead of coords?
	BOOL sendLoc;
	
	// close by stations
	NSMutableDictionary *closeStations;
	
	// range for the m/ filter
	NSNumber *filterRange;
	
	// horizontal distance range for GPS (coreloc) trigger
	NSNumber *distanceRange;
	
	// data counters
	double dataTX;
	double dataRX;
}

@property (nonatomic, retain) NSString *serverHost;
@property (nonatomic, assign) NSUInteger serverPort;

@property (nonatomic) int sock_fd;

@property (retain, nonatomic) NSString *callsign;
@property (retain, nonatomic) NSString *toCallsign;

@property (retain, nonatomic) NSString *icon;

@property (retain, nonatomic) NSString *statusMessage;
@property (retain, nonatomic) NSString *textMessage;

@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) double speed;
@property (nonatomic) double course;
@property (nonatomic) double altitude;
@property (nonatomic) double altitudeAccuracy;
@property (nonatomic) double horizontalAccuracy;
@property (nonatomic, retain) CLLocation *GPSData;

@property (nonatomic, retain) NSString *filter;

@property (nonatomic) NSInteger numBeaconsSent;
@property (retain, nonatomic) NSDate *lastBeacon;

@property (retain, nonatomic) NSMutableArray *aprsLog;

@property (nonatomic, assign) NSTimer *connectionTimer;

@property (retain, nonatomic) NSDate *lastPing;

// set to true when connected
@property (nonatomic) BOOL connected;

// set to true while connecting
@property (nonatomic) BOOL connecting;

// set to true while sending beacon
@property (nonatomic) BOOL beaconing;

// set to true if locator to be sent
@property (nonatomic) BOOL sendLoc;

@property (nonatomic, retain) NSMutableDictionary *closeStations;
@property (nonatomic, retain) NSNumber *filterRange;
@property (nonatomic, retain) NSNumber *distanceRange;

// data counters
@property (nonatomic, assign) double dataTX;
@property (nonatomic, assign) double dataRX;


- (BOOL)connectToAPRS;
- (void)disconnectFromAPRS;
- (BOOL)sendAPRSBeacon;
- (BOOL)APRSSendBeaconData:(const char*)data_c position:(BOOL)included;
- (short)getAPRSPassword:(const char *)realcall_c;
- (BOOL)validateAPRSData;
- (BOOL)sendAPRSFilter;
- (BOOL)sendCustomAPRSFilter:(NSString *)customFilter;
- (BOOL)sendTextMessage;
- (NSString *)removeSSID:(NSString *)realcall;
- (NSDictionary *)processTextMessage:(NSString *)msg;
- (BOOL)validateCallsign:(NSString *)realcall;
- (BOOL)validateTextMessage:(NSString *)msg;
- (void)insertIntoLog:(id)object;

- (void) startConnectionTimer;
- (void) stopConnectionTimer;
- (void) fireConnectionTimer:(NSTimer*)theTimer;


@end
