//
//  StationCell.h
//  iBCNU
//
//  Created by David Ponevac on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StationCell : UITableViewCell
{
	// user's image
	IBOutlet UIImageView *stationImage;
	
	// station name
	IBOutlet UILabel *stationName;
	
	// date
	IBOutlet UILabel *stationDate;
}

@property (nonatomic, retain) IBOutlet UIImageView *stationImage;
@property (nonatomic, retain) IBOutlet UILabel *stationName;
@property (nonatomic, retain) IBOutlet UILabel *stationDate;

@end
