//
//  SymbolViewController.h
//  iBCNU
//
//  Created by David Ponevac on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTools.h"
#import "APRS.h"


@interface SymbolViewController : UIViewController
{
	IBOutlet UIPickerView *iconRotator;
	
	APRS *APRSClass;
	
	NSArray *pickerData;
}

@property (nonatomic, retain) UIPickerView * iconRotator;
@property (nonatomic, assign) APRS *APRSClass;
@property (nonatomic, retain) NSArray *pickerData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed;

@end
