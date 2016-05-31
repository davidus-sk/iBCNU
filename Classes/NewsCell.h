//
//  NewsCell.h
//  iBCNU
//
//  Created by David Ponevac on 5/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewsCell : UITableViewCell
{
	// date label
	IBOutlet UILabel *dateLabel;
	
	// message snippet label
	IBOutlet UILabel *msgLabel;
}

@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *msgLabel;

@end
