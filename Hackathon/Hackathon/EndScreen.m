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
@synthesize gameOverImage = _gameOverImage;

//- (id) initWithColor:(ccColor4B)color {
//    if ((self = [super initWithColor:color])) {
//        NSLog(@"hahahhaa");
//        self.gameOverLabel = [CCLabelTTF labelWithString:@"GAME OVER" fontName:@"Arial-BoldMT" fontSize:35];
//        [self.gameOverLabel setAnchorPoint:ccp(0.5,0.5)];
//        //    self.gameOverLabel.position = ccp(screenSize.width/2, screenSize.height/2);
//        self.gameOverLabel.position = ccp(0,400);
//        [self addChild:self.gameOverLabel z:1];
//    }
//    return self;
//}

- (CCSprite*)gameOverImage {
    if (_gameOverImage == nil) {
        _gameOverImage = [[CCSprite alloc] init];
    }
    return _gameOverImage;
}

- (void)setGameOverImage:(CCSprite*)gameOverImage {
    _gameOverImage = gameOverImage;
}

- (void)createWithFinalScore:(double)finalScore withReason:(GameOverReasonType)reason {
    screenSize = [[CCDirector sharedDirector] winSize];
    
    // game over label and image
    if (reason == kGameOverEaten) {
        self.gameOverLabel = [CCLabelTTF labelWithString:@"GAME OVER" fontName:@"Copperplate" fontSize:45];
        [self.gameOverImage initWithFile:@"game-over-screen.png"];
        
    } else if (reason == kGameOverTimeOut) {
        self.gameOverLabel = [CCLabelTTF labelWithString:@"YOU WIN!" fontName:@"Copperplate" fontSize:55];
        [self.gameOverImage initWithFile:@"winner-screen.png"];
    }
    
    [self.gameOverImage setAnchorPoint:ccp(0.5,0.5)];
    self.gameOverImage.position = ccp(screenSize.width/2,screenSize.height/2);
    [self addChild:self.gameOverImage z:3];
    
    [self.gameOverLabel setAnchorPoint:ccp(0.5,0.5)];
    self.gameOverLabel.position = ccp(screenSize.width/2,425);
    [self addChild:self.gameOverLabel z:3];
    
    // final score label
    NSString* finalScoreLabel = [NSString stringWithFormat:@"Final Score: %i",(int)finalScore];
    self.finalScoreLabel = [CCLabelTTF labelWithString:finalScoreLabel fontName:@"Copperplate" fontSize:25];
    [self.finalScoreLabel setAnchorPoint:ccp(0.5,0.5)];
    self.finalScoreLabel.position = ccp(screenSize.width/2,375);
    [self addChild:self.finalScoreLabel z:3];
    
    // high score label: if no high score, then save final score as high score, otherwise, return high score
    double currentHighScore = [[NSUserDefaults standardUserDefaults] doubleForKey:@"highScore"];
    if (currentHighScore && currentHighScore > finalScore) {
        // do nothing
    } else {
        currentHighScore = finalScore;
        [[NSUserDefaults standardUserDefaults] setDouble:finalScore forKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString* highScoreLabel = [NSString stringWithFormat:@"High Score: %i",(int)currentHighScore];
    self.highScoreLabel = [CCLabelTTF labelWithString:highScoreLabel fontName:@"Copperplate" fontSize:25];
    [self.highScoreLabel setAnchorPoint:ccp(0.5,0.5)];
    self.highScoreLabel.position = ccp(screenSize.width/2,340);
    [self addChild:self.highScoreLabel z:3];
    
    // play again button
    CCMenuItemImage *playAgainButton = [CCMenuItemImage itemFromNormalImage:@"play-again-button.png" selectedImage:@"play-again-button.png" target:self selector:@selector(resetGame:)];
    CCMenu* myMenu = [CCMenu menuWithItems:playAgainButton, nil];
    [myMenu setAnchorPoint:ccp(0.5,0.5)];
    myMenu.position = ccp(screenSize.width/2,280);
    [self addChild:myMenu z:3];
    
    // font color
    [self.gameOverLabel setColor:ccc3(163, 3, 0)];
    [self.finalScoreLabel setColor:ccc3(163, 3, 0)];
    [self.highScoreLabel setColor:ccc3(163, 3, 0)];
    [playAgainButton setColor:ccc3(163, 3, 0)];
}

-(void)resetGame:(CCMenuItem *)item {
    NSLog(@"the parent is %@",self.parent);
    [self.parent resetGame];
}

@end
