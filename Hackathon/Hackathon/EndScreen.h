//
//  EndScreen.h
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@interface EndScreen : CCLayerColor {
    CGSize screenSize;
}

@property (nonatomic, retain) CCLabelTTF *gameOverLabel, *finalScoreLabel, *highScoreLabel;
@property (nonatomic, retain) CCSprite* gameOverImage;

- (void)createWithFinalScore:(double)finalScore withReason:(GameOverReasonType)reason;

@end
