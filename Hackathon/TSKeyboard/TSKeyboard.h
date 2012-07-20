//
//  TSKeyboard.h
//  Hackathon
//
//  Created by Elliot Michael Lee on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSKeyboard;

@protocol TSKeyboardDelegate <NSObject>

- (BOOL)keyboard:(TSKeyboard *)keyboard shouldHoverKey:(UIButton *)key;
- (void)keyboard:(TSKeyboard *)keyboard didActivateKey:(UIButton *)key;

@end

@interface TSKeyboard : UIView

@property (nonatomic, assign) id<TSKeyboardDelegate> delegate;

+ (TSKeyboard *)shared;

@end
