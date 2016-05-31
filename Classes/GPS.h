//
//  GPS.h
//  iBCNU
//
//  Created by David Ponevac on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GPS : NSObject
{

}

+ (NSString *)latitude2String:(double)coord APRSFormat:(BOOL)format;
+ (NSString *)longitude2String:(double)coord APRSFormat:(BOOL)format;
+ (NSString *)getGridSquare:(int)precision longitude:(double)longitude latitude:(double)latitude;

@end
