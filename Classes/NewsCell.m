//
//  NewsCell.m
//  iBCNU
//
//  Created by David Ponevac on 5/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NewsCell.h"


@implementation NewsCell

@synthesize dateLabel;
@synthesize msgLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
