//
//  Data.h
//  iBCNU
//
//  Created by David Ponevac on 5/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "CommonTools.h"


@interface Data : NSObject
{	
	// callsign
	NSString *callsign;
	
	// connection tracking
	NSMutableDictionary *connections;
	
	// timers
	NSTimer *checkMessagesTimer;
	
	// xml related
	NSMutableDictionary *currentItem;
	NSMutableString *currentContents;
}


// SQL struct
sqlite3 *db;

// instance vars
@property (retain, nonatomic) NSString *callsign;
@property (retain, nonatomic) NSMutableDictionary *connections;

// timers
@property (assign, nonatomic) NSTimer *checkMessagesTimer;


// aux methods
+ (NSString *)base64Encode:(NSString *)string;
+ (NSString *)prepareBase64String:(NSString *)string;

// messaging methods
+ (void)storeMessageOnServer:(NSDictionary *)params;
+ (void)storePositionOnServer:(NSDictionary *)params;
+ (void)deleteMessageFromServer:(int)messageID callsign:(NSString *)callsign;
- (void)getMessagesFromServer;
- (void)checkNewMessages;
- (void)processMessages:(NSData *)xml;

// SQL methods
+ (BOOL)connectToDB;
+ (void)closeDB;
+ (void)prepareDB;
+ (int)storeMessageInDB:(NSDictionary *)data table:(NSString *)table;
+ (BOOL)markMessagesRead:(NSString *)table;
+ (int)countNewMessages:(NSString *)table;
+ (int)countMessages:(NSString *)table;
+ (NSArray *)getMessagesFromDB:(NSString *)table;
+ (BOOL)deleteMessageFromDB:(NSString *)table message:(int)messageID;
+ (BOOL)isDbSet;

// timer methods
- (void)fireCheckMessagesTimer:(NSTimer *)theTimer;


@end
