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
        const int top = 10; // 10 keys
        const int mid = top+9; // 9 keys
        const int bottomCount = 7; // keys
        const float standardKeyWidth=32;
        const float midOffset=(frame.size.width-((mid-top)*standardKeyWidth))/2;
        float x=0, y=0;
        for (int i=0; i<layout.length; i++)
        {
            NSString *letter = [NSString stringWithFormat:@"%c", [layout characterAtIndex:i]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:letter forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
            button.titleLabel.shadowColor = [UIColor blackColor];
            button.titleLabel.shadowOffset = CGSizeMake(0, -1);
            
            UIImage *image = [UIImage imageNamed:@"key-darkgray"];
            [button setImage:image forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(hover:) forControlEvents:(UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragEnter)];
            [button addTarget:self action:@selector(unhover:) forControlEvents:(UIControlEventTouchDragOutside | UIControlEventTouchDragExit | UIControlEventTouchCancel)];
            [button addTarget:self action:@selector(activate:) forControlEvents:UIControlEventTouchUpInside];
            
            const float standardTopInset = 4; // need to move all key images down by 4pt
            float keyWidth = standardKeyWidth;
            
            button.titleEdgeInsets = UIEdgeInsetsMake(standardTopInset+6, -image.size.width, 0, 0);
            
            if (i==top) { // 'A'
                x=0;
                y+=keyHeight;
                keyWidth += midOffset;
                button.imageEdgeInsets = UIEdgeInsetsMake(standardTopInset, midOffset, -standardTopInset, -midOffset);
                button.titleEdgeInsets = UIEdgeInsetsMake(standardTopInset+6, -image.size.width+midOffset/2, 0, -midOffset/2);
            } else if (i==top+1) { // 'S'
                x+=standardKeyWidth+midOffset;
                button.imageEdgeInsets = UIEdgeInsetsMake(standardTopInset, 0, -standardTopInset, 0);
            } else if (i==mid-1) { // 'L'
                x+=standardKeyWidth;
                keyWidth += midOffset;
                button.imageEdgeInsets = UIEdgeInsetsMake(standardTopInset, 0, -standardTopInset, 0);
                button.titleEdgeInsets = UIEdgeInsetsMake(standardTopInset+6, -image.size.width-midOffset/2, 0, midOffset/2);
            } else if (i==mid) { // 'Z'
                x=(frame.size.width-(bottomCount*standardKeyWidth))/2;
                y+=keyHeight;
                button.imageEdgeInsets = UIEdgeInsetsMake(standardTopInset, 0, -standardTopInset, 0);
            } else if (i!=0) { // not 'Q'
                x+=standardKeyWidth;
                button.imageEdgeInsets = UIEdgeInsetsMake(standardTopInset, 0, -standardTopInset, 0);
            } else { // 'Q'
                button.imageEdgeInsets = UIEdgeInsetsMake(standardTopInset, 0, -standardTopInset, 0);
            }
            
            button.frame = CGRectMake(x, y, keyWidth, keyHeight);
            
            [self addSubview:button];
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
