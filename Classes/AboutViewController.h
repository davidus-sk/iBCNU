//
//  AboutViewController.h
//  iBCNU
//
//  Created by David Ponevac on 4/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTools.h"


@interface AboutViewController : UIViewController
{	
	// table view
	IBOutlet UIScrollView *aboutScrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *aboutScrollView;

@end
