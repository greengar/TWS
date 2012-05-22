//
//  TSKeyboard.m
//  Hackathon
//
//  Created by Elliot Michael Lee on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSKeyboard.h"
#import <UIKit/UIWindow.h>

#define keyHeight (54)
#define numRows (3)

//@interface UIView (extraFirstResponderMethod)
//- (UIView *)getFirstResponder;
//@end
//
//@implementation UIView (extraFirstResponderMethod)
//- (UIView *)getFirstResponder
//{
//    if (self.isFirstResponder)        
//        return self;     
//    
//    
//    for ( UIView * _pCurView in self.subviews ) 
//    {
//        UIView * _pFirstResponder = [_pCurView getFirstResponder];
//        
//        if (_pFirstResponder != nil)
//            return _pFirstResponder;
//    }
//    
//    return nil;
//}
//
//@end

@implementation TSKeyboard

@synthesize delegate;

+ (TSKeyboard *)shared {
    static TSKeyboard *sharedKeyboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedKeyboard = [[TSKeyboard alloc] initWithFrame:CGRectMake(0, 0, 320, keyHeight*numRows)];
    });
    return sharedKeyboard;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor blackColor];
        
        NSString *layout = @"QWERTYUIOPASDFGHJKLZXCVBNM";
        const int top = 10-1; // 10 keys
        const int mid = top+9; // 9 keys
        const int bottomCount = 7; // keys
        const float keyWidth=32;
        float x=0, y=4;
        for (int i=0; i<layout.length; i++) {
            NSString *letter = [NSString stringWithFormat:@"%c", [layout characterAtIndex:i]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[UIImage imageNamed:@"key-darkgray"] forState:UIControlStateNormal];
            [button setTitle:letter forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
            [button addTarget:self action:@selector(hover:) forControlEvents:(UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragEnter)];
            [button addTarget:self action:@selector(unhover:) forControlEvents:(UIControlEventTouchDragOutside | UIControlEventTouchDragExit | UIControlEventTouchCancel)];
            [button addTarget:self action:@selector(activate:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(x, y, keyWidth, keyHeight);
            
//            button.backgroundColor = [UIColor orangeColor];
            
            [self addSubview:button];
            x+=keyWidth;
            if (i == top) {
                x=(frame.size.width-((mid-top)*keyWidth))/2;
                y+=keyHeight;
            } else if (i == mid) {
                x=(frame.size.width-(bottomCount*keyWidth))/2;
                y+=keyHeight;
            }
        }
    }
    return self;
}

- (void)hover:(UIButton *)key {
    if (delegate && [delegate respondsToSelector:@selector(keyboard:shouldHoverKey:)] && [delegate keyboard:self shouldHoverKey:key])
    {
        // show special key hover graphic
    } else {
        // show normal key hover graphic
    }
    
//    key.backgroundColor = [UIColor blueColor];
//    NSLog(@"hover:");
}

- (void)unhover:(UIButton *)key {
//    key.backgroundColor = [UIColor orangeColor];
//    NSLog(@"unhover:");
}

- (void)activate:(UIButton *)key {
//    key.backgroundColor = [UIColor purpleColor];
    
    if (delegate && [delegate respondsToSelector:@selector(keyboard:didActivateKey:)]) {
        [delegate keyboard:self didActivateKey:key];
    }
    
//    UITextField *firstResponder = (UITextField *)[[[UIApplication sharedApplication] keyWindow] getFirstResponder];
//    if (firstResponder && [firstResponder isKindOfClass:[UITextField class]]) {
//        firstResponder.text = [firstResponder.text stringByAppendingString:key.titleLabel.text];
//    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
