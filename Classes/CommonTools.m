//
//  CommonTools.m
//  iBCNU
//
//  Created by David Ponevac on 4/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CommonTools.h"


@implementation CommonTools

/**
 * display error
 */
+ (void)showError:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}//func

/**
 * Get path to a file on current file system
 */
+ (NSString *)getDataFilePath:(NSString *)file
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [path objectAtIndex:0];
	
	return [documentDirectory stringByAppendingPathComponent:file];
}//func


/**
 * Open link in safari
 */
+ (void)openLink:(NSString *)link
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}//func

/**
 * Format NSDate into shorter string version
 */
+ (NSString *)formatTimestamp:(NSDate *)date
{
	// get date into YYYY-MM-DD HH:MM:SS ±HHMM and trim up
	NSString *timestamp = [date description];
	
	// find last dot
	NSRange range = [timestamp rangeOfString:@":" options:NSBackwardsSearch];
	
	// output YYYY-MM-DD HH:MM
	if (range.location == NSNotFound)
	{
		return [[NSDate date] description];
	}
	else
	{
		return [timestamp substringToIndex:range.location];
	}//if
}//func

/**
 * quick hack to initiate connection
 */
+ (BOOL)tripConnection:(char *)host port:(int)port
{
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%s:%d", host, 80]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:25.0];
	NSURLResponse *theResponse = nil;
	NSError *theError = nil;
	NSData *theData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];

	if ((theData == nil) || (theError != nil))
	{
		NSLog(@"%@", theError);
		return NO;
	}//if
	
	return YES;
}//func

+ (void)saveToFile:(id)object forTag:(NSString *)tag
{
	NSMutableDictionary *appSettings = [[NSMutableDictionary alloc] init];
	
	// determine if file already exists and load it
	NSString *filePath = [CommonTools getDataFilePath:_DATA_FILE];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		appSettings = [appSettings initWithContentsOfFile:filePath];
	}//if
	
	// add the changes
	[appSettings setObject:object forKey:tag];
	[appSettings writeToFile:filePath atomically:YES];
	[appSettings release];
}

+ (NSArray *)lookupAPRSIcon:(NSString *)symbol
{
	// return array
	NSMutableArray *symbolArray = [[NSMutableArray alloc] initWithCapacity:0];
	
	// table lookup array
	NSArray *symbolTable = [[NSArray alloc] initWithObjects:
							[NSArray arrayWithObjects:@"!",@"\"",@"#",@"$",@"%",@"&",@"'",@"(",@")",@"*",@"+",@",",@"-",@".",@"/",@"0",nil],
							[NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@":",@";",@"<",@"=",@">",@"?",@"@",nil],
							[NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",nil],
							[NSArray arrayWithObjects:@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"[",@"\\",@"]",@"^",@"_",@"`",nil],
							[NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",nil],
							[NSArray arrayWithObjects:@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"{",@"|",@"}",@"~",@"",@"",nil],
							nil];
	
	// symbol is in 1_1_1 format
	NSArray *components = [symbol componentsSeparatedByString:@"_"];
	
	NSUInteger x = ([[components objectAtIndex:1] intValue] - 1);
	NSUInteger y = ([[components objectAtIndex:2] intValue] - 1);
	
	if ([[components objectAtIndex:0] isEqualToString:@"1"])
	{
		[symbolArray addObject:@"/"];
		[symbolArray addObject:[[symbolTable objectAtIndex:y] objectAtIndex:x]];
	}
	else
	{
		[symbolArray addObject:@"\\"];
		[symbolArray addObject:[[symbolTable objectAtIndex:y] objectAtIndex:x]];
	}//if
	
	[symbolTable release];
	components = nil;
	
	return symbolArray;
}

@end
