//
//  MNLabel.m
//  MeshNetwork
//
//  Created by Elliot Michael Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNLabel.h"

@implementation MNLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
