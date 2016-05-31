//
//  UIViewCustom.m
//  iBCNU
//
//  Created by David Ponevac on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIViewCustom.h"


@implementation UIViewCustom


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
