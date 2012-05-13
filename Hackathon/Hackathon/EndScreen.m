//
//  Monster.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EndScreen.h"
#import "Constants.h"

@implementation EndScreen

@synthesize gameOverLabel = _gameOverLabel;
@synthesize finalScoreLabel = _finalScoreLabel;
@synthesize highScoreLabel = _highScoreLabel;

- (id) init {
    self.gameOverLabel = [CCLabelTTF labelWithString:@"GAME OVER" fontName:@"Arial-BoldMT" fontSize:35];
    [self.gameOverLabel setAnchorPoint:ccp(0.5,0.5)];
//    self.gameOverLabel.position = ccp(screenSize.width/2, screenSize.height/2);
    self.gameOverLabel.position = ccp(100,100);
    [self addChild:self.gameOverLabel z:1];
    return self;
}

@end
