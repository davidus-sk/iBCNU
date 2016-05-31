//
//  CommonTools.h
//  iBCNU
//
//  Created by David Ponevac on 4/13/09.
//  Copyright 2009 LUCEON LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

// default font size
#define _FONT_SIZE						20.0
#define _MSG_FONT_SIZE					14.0

// file used to store prefs
#define _DATA_FILE						@"data.plist"
#define _DB_FILE						@"dbAPRSdata.db"

// tags for UI items
#define _TAG_CALLSIGN					@"10"
#define _TAG_STATUSMSG					@"20"
#define _TAG_BEACON						@"30"
#define _TAG_INTERVAL					@"40"
#define _TAG_MSG						@"50"
#define _TAG_TOCALLSIGN					@"60"
#define _TAG_CINTERVAL					@"70"
#define _TAG_RANGE						@"80"
#define _TAG_LATITUDE					@"90"
#define _TAG_LONGITUDE					@"100"
#define _TAG_DISTANCE					@"110"
#define _TAG_SERVERHOST					@"120"
#define _TAG_SERVERPORT					@"130"
#define _TAG_ICON						@"140"
#define _TAG_METRIC						@"150"

// error messages
#define _ERR_TITLE_APRS_CON_FAILED		@"Connection to APRS-IS failed"
#define _ERR_MSG_APRS_CON_FAILED		@"iPhone failed connecting to the APRS server. It will attempt connecting again automatically when needed."
#define _ERR_TITLE_MSG_SENDING_FAILED	@"Message not sent"
#define _ERR_MSG_MSG_SENDING_FAILED		@"Please check your message and both your and destination callsigns and try again."
#define _ERR_TITLE_CALL_INVALID			@"Invalid callsign"
#define _ERR_MSG_CALL_INVALID			@"Callsign does not conform to AX.25 format. Use only alphanumeric characters."
#define _ERR_TITLE_CINTERVAL_INVALID	@"Custom interval"
#define _ERR_MSG_CINTERVAL_INVALID		@"Interval must fall within 10 and 1000 seconds."
#define _ERR_TITLE_RANGE_INVALID		@"Range filter"
#define _ERR_MSG_RANGE_INVALID			@"Range must fall within 1 and 500 kilometers of your station."
#define _ERR_TITLE_DISTANCE_INVALID		@"GPS distance"
#define _ERR_MSG_DISTANCE_INVALID		@"Distance trigger must fall withing 10 and 2000 meters."
#define _ERR_TITLE_PORT_INVALID			@"Port number"
#define _ERR_MSG_PORT_INVALID			@"Port number must be grater than 0 and smaller than 65536."
#define _ERR_TITLE_HOST_INVALID			@"Gate name"
#define _ERR_MSG_HOST_INVALID			@"Host name for the gate is invalid."
#define _ERR_TITLE_CONN_INVALID			@"Connection problem"
#define _ERR_MSG_CONN_INVALID			@"Failed connecting to server and getting content. Please try again later."

// messages
#define _MSG_TITLE_MSG_SENT				@"Message sent"
#define _MSG_MSG_MSG_SENT				@"Your message was sent to %@."

// colors
#define _BG_COLOR						[UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.0]
#define _LINE_COLOR						[UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0]
#define _TXT_COLOR						[UIColor whiteColor]
#define _BLUE_TXT_COLOR					[UIColor colorWithRed:0.0 green:0.478 blue:0.658 alpha:1.0]
#define _GRAY_TXT_COLOR					[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]

#define _APP_NAME						[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] cStringUsingEncoding:NSASCIIStringEncoding]

@interface CommonTools : NSObject
{

}

+ (void)showError:(NSString *)title message:(NSString *)message;
+ (NSString *)getDataFilePath:(NSString *)file;
+ (void)openLink:(NSString *)link;
+ (NSString *)formatTimestamp:(NSDate *)date;
+ (BOOL)tripConnection:(char *)host port:(int)port;
+ (void)saveToFile:(id)object forTag:(NSString *)tag;
+ (NSArray *)lookupAPRSIcon:(NSString *)symbol;

@end
