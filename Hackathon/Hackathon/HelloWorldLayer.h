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
#import "EndScreen.h"
#import "BloodDrip.h"
#import "MNCenter.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <CCTextFieldDelegate>
{
    double timeLeft; // how long till game is over
    double nextMonsterTimer; // next monster shows up in x seconds
    double score;
    CGSize screenSize;
    CGPoint playerPosition;
    int gameCount;
    BOOL bossAppeared;
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
@property (nonatomic, retain) NSMutableDictionary *players;
@property (nonatomic, retain) EndScreen* gameOverScreen;
@property (nonatomic, retain) BloodDrip* blood;
@property (nonatomic, retain) NSMutableSet *devices;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)showGameOverScreen;
-(void)showBlood;


/******* communication *********/
-(void) handleIncomingMessage:(NSData *)data fromDevice:(Device *)device;
-(void) sendJoinRequest:(Device *)device; // actually sends to all devices
-(void) sendMonsterBornMessage:(Monster *)monster;
-(void) sendMonsterDiedMessage:(Monster *)monster;
-(void) sendPlayerLeftMessage; 

@end
