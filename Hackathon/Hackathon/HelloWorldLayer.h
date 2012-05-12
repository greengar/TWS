//
//  HelloWorldLayer.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Constants.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    double timeLeft; // how long till game is over
    double nextMonsterTimer; // next monster shows up in x seconds
    double score;
    CGSize screenSize;
}

@property (nonatomic, retain) CCLabelTTF *scoreLabel, *timerLabel;
@property (nonatomic, retain) NSArray* dictionary;
@property (nonatomic, retain) NSMutableSet* monsters;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
