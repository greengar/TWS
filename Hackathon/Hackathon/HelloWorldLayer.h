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
#import "CCTextField.h"
#import "Player.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <CCTextFieldDelegate>
{
    double timeLeft; // how long till game is over
    double nextMonsterTimer; // next monster shows up in x seconds
    double score;
    CGSize screenSize;
    CGPoint playerPosition;
}

@property (nonatomic, retain) CCLabelTTF *scoreLabel, *timerLabel;
@property (nonatomic, retain) NSMutableArray* dictionary;
@property (nonatomic, retain) NSMutableSet* monsters;
@property (nonatomic, retain) NSString *lastWord; // last word checked against the monsters
@property (nonatomic, retain) UITextField *textEntryFieldUI;
@property (nonatomic, retain) CCLabelTTF *textEntryLabel;
@property (nonatomic, retain) CCTextField *textEntryFieldCC;
@property GameOverReasonType gameOverReason;
@property BOOL isGameOver;
@property (nonatomic, retain) Player *myPlayer;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
