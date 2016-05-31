//
//  UITextFieldCustom.m
//  iBCNU
//
//  Created by David Ponevac on 4/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UITextFieldCustom.h"


@implementation UITextFieldCustom

- (id) initWithFrame:(CGRect)frame textRectForBounds:(CGRect)rect
{
	if (self = [super initWithFrame: frame])
	{
		textRect = rect;
	}//if
	
	return self;
}//func

- (CGRect)textRectForBounds:(CGRect)bounds
{
	return textRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	return textRect;
}

@end
