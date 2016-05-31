//
//  WriteMessageViewController.h
//  iBCNU
//
//  Created by David Ponevac on 4/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTools.h"
#import "APRS.h"
#import "Data.h"


@interface WriteMessageViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{		
	// to call field
	UITextField *toCallField;
	
	// msg area
	UITextView *msgTextView;
	
	// send btn
	UIButton *sendButton;
	
	// APRS object
	APRS *APRSClass;
}

@property (nonatomic, retain) UITextField *toCallField;
@property (nonatomic, assign) APRS *APRSClass;

@end
