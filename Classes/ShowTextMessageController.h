//
//  ShowTextMessage.h
//  iBCNU
//
//  Created by David Ponevac on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTools.h"
#import "APRS.h"


@interface ShowTextMessageController : UIViewController
{
	// table view with messages
	IBOutlet UILabel *textLabel;
	
	// info label
	IBOutlet UILabel *infoLabel;
	
	// messages from db
	NSDictionary *message;
	
	// sender
	NSString *sender;
	
	// aprs object
	APRS *APRSClass;
}

@property (retain, nonatomic) IBOutlet UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UILabel *infoLabel;
@property (retain, nonatomic) NSDictionary *message;
@property (retain, nonatomic) NSString *sender;
@property (assign, nonatomic) APRS *APRSClass;

@end
