//
//  MessageCell.h
//  iBCNU
//
//  Created by David Ponevac on 4/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MessageCell : UITableViewCell
{
	// callsign label
	IBOutlet UILabel *callsignLabel;
	
	// date label
	IBOutlet UILabel *dateLabel;
	
	// message snippet label
	IBOutlet UILabel *msgLabel;
}

@property (nonatomic, retain) UILabel *callsignLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *msgLabel;

@end
