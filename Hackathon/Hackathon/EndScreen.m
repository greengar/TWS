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

- (void)createWithFinalScore:(double)finalScore {
    screenSize = [[CCDirector sharedDirector] winSize];
    
    // game over label
    self.gameOverLabel = [CCLabelTTF labelWithString:@"GAME OVER" fontName:@"Arial-BoldMT" fontSize:45];
    [self.gameOverLabel setAnchorPoint:ccp(0.5,0.5)];
    self.gameOverLabel.position = ccp(screenSize.width/2,400);
    NSLog(@"width is %f and height is %f",screenSize.width, screenSize.height);
    [self addChild:self.gameOverLabel z:3];
    
    // final score label
    NSString* finalScoreLabel = [NSString stringWithFormat:@"Final Score: %i",(int)finalScore];
    self.finalScoreLabel = [CCLabelTTF labelWithString:finalScoreLabel fontName:@"Arial-BoldMT" fontSize:25];
    [self.finalScoreLabel setAnchorPoint:ccp(0.5,0.5)];
    self.finalScoreLabel.position = ccp(screenSize.width/2,300);
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
    self.highScoreLabel = [CCLabelTTF labelWithString:highScoreLabel fontName:@"Arial-BoldMT" fontSize:25];
    [self.highScoreLabel setAnchorPoint:ccp(0.5,0.5)];
    self.highScoreLabel.position = ccp(screenSize.width/2,275);
    [self addChild:self.highScoreLabel z:3];
    
    // play again button
}

@end
