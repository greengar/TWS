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

// need to move all key images down by 4pt
#define standardTopInset (-4)
//(4)

//enum {
//    keyTagDefault = 1,
//    keyTagA,
//    keyTagS,
//    keyTagL,
//};



// 10 keys
#define top (10)

// 9 keys
#define mid (top+9)

#define bottomCount (7)

#define keyTagQ (0)
#define keyTagP (top-1)
#define keyTagA (top)
#define keyTagS (top+1)
#define keyTagL (mid-1)

#define standardKeyWidth (32)

#define KEY_FONT ([UIFont boldSystemFontOfSize:22])
#define KEY_IMAGE ([UIImage imageNamed:@"key-darkgray"])
#define midOffset ((self.frame.size.width-((mid-top)*standardKeyWidth))/2)

#define keyTitleEdgeInsetsDefault \
    (UIEdgeInsetsMake(standardTopInset+6, -(KEY_IMAGE).size.width, 0, 0))

#define keyTitleEdgeInsetsA \
    (UIEdgeInsetsMake(standardTopInset+6, -(KEY_IMAGE).size.width+midOffset/2, 0, -midOffset/2))
#define keyTitleEdgeInsetsL (UIEdgeInsetsMake(standardTopInset+6, -(KEY_IMAGE).size.width-midOffset/2, 0, midOffset/2))


// TODO: stop using these; just use Default
//#define keyImageEdgeInsetsS keyImageEdgeInsetsDefault
//#define keyImageEdgeInsetsL keyImageEdgeInsetsDefault


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

static const NSString *keyboardLayout = @"QWERTYUIOPASDFGHJKLZXCVBNM";

//- (NSInteger)tagForKeyString:(NSString *)letter {
//    return [keyboardLayout rangeOfString:letter].location;
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor blackColor];
        
        float x=0, y=0;
        for (int i=0; i<keyboardLayout.length; i++)
        {
            NSString *letter = [NSString stringWithFormat:@"%c", [keyboardLayout characterAtIndex:i]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:letter forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = KEY_FONT;
            button.titleLabel.shadowColor = [UIColor blackColor];
            button.titleLabel.shadowOffset = CGSizeMake(0, -1);
            
            UIImage *image = KEY_IMAGE;
            [button setImage:image forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(hover:) forControlEvents:(UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragEnter)];
            [button addTarget:self action:@selector(unhover:) forControlEvents:(UIControlEventTouchDragOutside | UIControlEventTouchDragExit | UIControlEventTouchCancel)];
            [button addTarget:self action:@selector(activate:) forControlEvents:UIControlEventTouchUpInside];
            
            float keyWidth = standardKeyWidth; // 32 x 54
            // image is 187 x 195
            // 80 x 147
            // 187-80*2=27
            
            //#define keyImageEdgeInsetsDefault (UIEdgeInsetsMake(standardTopInset, 0, -standardTopInset, 0))
            //#define keyImageEdgeInsetsDefault (UIEdgeInsetsMake(-116, -63, -9, -63))
            #define keyImageEdgeInsetsDefault (UIEdgeInsetsMake(-140, -79, -1, -76))
            
            button.titleEdgeInsets = keyTitleEdgeInsetsDefault;
            button.tag = i;
            
            if (i==0) { // 'Q'
                button.imageEdgeInsets = keyImageEdgeInsetsDefault;
            } else if (i==keyTagA) { // 'A'
                x=0;
                y+=keyHeight;
                keyWidth += midOffset;
                
                #define keyImageEdgeInsetsA (UIEdgeInsetsMake(-140, -79+midOffset, -1, -76))
                
                button.imageEdgeInsets = keyImageEdgeInsetsA;
                button.titleEdgeInsets = keyTitleEdgeInsetsA;
            } else if (i==keyTagS) { // 'S'
                x+=standardKeyWidth+midOffset;
                button.imageEdgeInsets = keyImageEdgeInsetsDefault;
            } else if (i==keyTagL) { // 'L'
                x+=standardKeyWidth;
                keyWidth += midOffset;
                button.imageEdgeInsets = keyImageEdgeInsetsDefault;
                button.titleEdgeInsets = keyTitleEdgeInsetsL;
            } else if (i==mid) { // 'Z'
                x=(frame.size.width-(bottomCount*standardKeyWidth))/2;
                y+=keyHeight;
                button.imageEdgeInsets = keyImageEdgeInsetsDefault;
            } else {
                x+=standardKeyWidth;
                button.imageEdgeInsets = keyImageEdgeInsetsDefault;
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
        
        //key.imageEdgeInsets = UIEdgeInsetsMake(-227/2, -123/2, -9, -123/2);
        //key.imageEdgeInsets = UIEdgeInsetsMake(-116, -63, -9, -63);
        
        key.imageEdgeInsets = keyImageEdgeInsetsDefault;
        
        UIImage *image = [UIImage imageNamed:@"keypressed-star-middle"];
        [key setImage:image forState:UIControlStateHighlighted];
        
        if (key.tag == keyTagQ)
        {
            UIImage *image = [UIImage imageNamed:@"keypressed-star-left"];
            [key setImage:image forState:UIControlStateHighlighted];
        }
        else if (key.tag == keyTagP)
        {
            UIImage *image = [UIImage imageNamed:@"keypressed-star-right"];
            [key setImage:image forState:UIControlStateHighlighted];
        }
        else if (key.tag == keyTagA)
        {
            key.imageEdgeInsets = UIEdgeInsetsMake(-227/2, -123/2+midOffset, -9, -123/2-midOffset);
        }
    }
    else
    {
        // insets: more negative is farther from the center
        
        // normal key hover graphic
        key.imageEdgeInsets = keyImageEdgeInsetsDefault; //UIEdgeInsetsMake(-116, -63, -9, -63);
        
        UIImage *image = [UIImage imageNamed:@"keypressed-normal-middle"];
        [key setImage:image forState:UIControlStateHighlighted];
        
//        key.imageEdgeInsets = UIEdgeInsetsMake(-50, -20, 0, -20); // works
        key.titleEdgeInsets = UIEdgeInsetsMake(-93-9, -image.size.width-100, 0, -100);
        
        key.clipsToBounds = NO;
        
        // should be 41, but 33 is the largest that 'W' currently works with
        //key.titleLabel.font = [UIFont boldSystemFontOfSize:33];
        
        key.titleLabel.font = [UIFont boldSystemFontOfSize:44];
        
        if (key.tag == keyTagQ)
        {
            UIImage *image = [UIImage imageNamed:@"keypressed-normal-left"];
            [key setImage:image forState:UIControlStateHighlighted];
            //key.titleEdgeInsets = UIEdgeInsetsMake(-40, -image.size.width, 0, 0);
            key.titleEdgeInsets = UIEdgeInsetsMake(-93-9, -image.size.width-100+10, 0, -100-10);
        }
        else if (key.tag == keyTagP)
        {
            UIImage *image = [UIImage imageNamed:@"keypressed-normal-right"];
            [key setImage:image forState:UIControlStateHighlighted];
            key.titleEdgeInsets = UIEdgeInsetsMake(-93-9, -image.size.width-100-10, 0, -100+10);
        }
        else if (key.tag == keyTagA)
        {
            //key.imageEdgeInsets = UIEdgeInsetsMake(-116, -63+midOffset/2, -9, -63-midOffset/2);
            //key.titleEdgeInsets = UIEdgeInsetsMake(-93, -image.size.width+midOffset/2, 0, 0);
            
            key.titleEdgeInsets = UIEdgeInsetsMake(-93-9, -image.size.width-100+midOffset, 0, -100);
            key.imageEdgeInsets = keyImageEdgeInsetsA;
        }
        else if (key.tag == keyTagL)
        {
            key.titleEdgeInsets = UIEdgeInsetsMake(-93-9, -image.size.width-100, 0, -100+midOffset);
            key.imageEdgeInsets = UIEdgeInsetsMake(-140, -79, -1, -76+midOffset);
        }
    }
    
    [self bringSubviewToFront:key];
    
//    key.backgroundColor = [UIColor blueColor];
//    NSLog(@"hover:");
}

- (void)unhover:(UIButton *)key {
//    key.backgroundColor = [UIColor orangeColor];
//    NSLog(@"unhover:");
    NSLog(@"unhover:%d",key.tag);
    
    key.titleLabel.font = KEY_FONT;
    
    if (key.tag == keyTagA) {
        key.imageEdgeInsets = keyImageEdgeInsetsA;
        key.titleEdgeInsets = keyTitleEdgeInsetsA;
    } else if (key.tag == keyTagL) {
        key.imageEdgeInsets = keyImageEdgeInsetsDefault;
        key.titleEdgeInsets = keyTitleEdgeInsetsL;
    } else {
        key.titleEdgeInsets = keyTitleEdgeInsetsDefault;
        key.imageEdgeInsets = keyImageEdgeInsetsDefault;
    }
    
//    if (key.tag == keyTagDefault) {
////        key.titleEdgeInsets = keyTitleEdgeInsetsDefault;
//    } else if (key.tag == keyTagA) {
//        NSLog(@"unhover:A");
////        key.titleEdgeInsets = keyTitleEdgeInsetsA;
//        key.imageEdgeInsets = keyImageEdgeInsetsA;
//    }
//    
//    if (key.tag == [self tagForKeyString:@"Q"]) {
//        key.imageEdgeInsets = keyImageEdgeInsetsDefault;
//    } else {
//        key.imageEdgeInsets = keyImageEdgeInsetsDefault;
//    }
}

- (void)activate:(UIButton *)key {
//    key.backgroundColor = [UIColor purpleColor];
    
    if (delegate && [delegate respondsToSelector:@selector(keyboard:didActivateKey:)]) {
        [delegate keyboard:self didActivateKey:key];
        
        
    }
    
    [self unhover:key];
    
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:...");
}

@end
