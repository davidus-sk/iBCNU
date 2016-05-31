//
//  GPS.m
//  iBCNU
//
//  Created by David Ponevac on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GPS.h"


@implementation GPS

/**
 * Convert decimal latitude into degree and aprs formats
 */
+ (NSString *)latitude2String:(double)coord APRSFormat:(BOOL)format
{
	char orientation;
	
	// orientation
	if (coord < 0)
	{
		orientation = 'S';
	}
	else
	{
		orientation = 'N';
	}//if
	
	coord = fabs(coord);
	
	// degrees
	int deg = floor(coord);
	
	// mins
	int mins = floor((coord - deg) * 60);
	
	// secs
	//int secs = floor(((coord - deg) * 60 - mins) * 60);
	
	//hundreds
	int hundreds = floor(((coord - deg) * 60 - mins) * 100);
	
	// return
	if (!format)
	{
		// display format
		//return [NSString stringWithFormat:@"%3d° %2d' %2d\" %c",deg,mins,secs,orientation];
		return [NSString stringWithFormat:@"%d° %d.%d\' %c",deg,mins,hundreds,orientation];
	}//if
	
	// aprs format
	return [NSString stringWithFormat:@"%02d%02d.%02d%c",deg,mins,hundreds,orientation];
}//func

/**
 * Convert decimal longitude into degree and aprs formats
 */
+ (NSString *)longitude2String:(double)coord APRSFormat:(BOOL)format
{
	char orientation;
	
	// orientation
	if (coord < 0)
	{
		orientation = 'W';
	}
	else
	{
		orientation = 'E';
	}//if
	
	coord = fabs(coord);
	
	// degrees
	int deg = floor(coord);
	
	// mins
	int mins = floor((coord - deg) * 60);
	
	// secs
	//int secs = floor(((coord - deg) * 60 - mins) * 60);

	//hundreds
	int hundreds = floor(((coord - deg) * 60 - mins) * 100);
	
	// return
	if (!format)
	{
		// display format
		//return [NSString stringWithFormat:@"%3d° %2d' %2d\" %c",deg,mins,secs,orientation];
		return [NSString stringWithFormat:@"%d° %d.%d\' %c",deg,mins,hundreds,orientation];
	}//if
	
	// aprs format
	return [NSString stringWithFormat:@"%03d%02d.%02d%c",deg,mins,hundreds,orientation];
}//func

/**
 * Calculate maidenhead locator from GPS coords
 */
+ (NSString *)getGridSquare:(int)precision longitude:(double)longitude latitude:(double)latitude
{
	int v = 0;
	int p1, p2, p3, p4, p5, p6;

	latitude += 90;
	longitude += 180;
	
	v = (int)(longitude / 20);
	longitude -= v * 20;
	p1 = ('A' + v);
	
	v = (int)(latitude / 10);
	latitude -= v * 10;
	p2 = ('A' + v);
	
	p3 = (int)(longitude / 2);
	p4 = (int)latitude;
	longitude -= p3 * 2;
	latitude -= p4;
	
	p3 = '0' + p3;
	p4 = '0' + p4;
	p5 = (int)(12 * longitude);
	p6 = (int)(24 * latitude);
	p5 = 'A' + p5;
	p6 = 'A' + p6;
	
	return [NSString stringWithFormat:@"%c%c%c%c%c%c", p1, p2, p3, p4, p5, p6];
	
}//func

@end
