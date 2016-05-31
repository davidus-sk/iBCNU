//
//  UITextFieldCustom.h
//  iBCNU
//
//  Created by David Ponevac on 4/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UITextFieldCustom : UITextField
{
	CGRect textRect;
}

- (id) initWithFrame:(CGRect)frame textRectForBounds:(CGRect)rect;

@end
