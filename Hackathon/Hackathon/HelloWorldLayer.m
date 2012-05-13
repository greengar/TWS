//
//  HelloWorldLayer.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "Monster.h"
#import "MinionDragon.h"
#import "BloodDrip.h"
#import "MNCenter.h"
#import "Messages.h"
#import "Fireball.h"
#import <objc/runtime.h>

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize timerLabel = _timerLabel;
@synthesize scoreLabel = _scoreLabel;
@synthesize textEntryLabel = _textEntryLabel;
@synthesize textEntryFieldCC = _textEntryFieldCC;
@synthesize textEntryFieldUI = _textEntryFieldUI;
@synthesize dictionary = _dictionary;
@synthesize monsters = _monsters;
@synthesize lastWord = _lastWord;
@synthesize gameOverReason;
@synthesize isGameOver;
@synthesize myPlayer = _myPlayer;
@synthesize gameOverScreen = _gameOverScreen;
@synthesize blood = _blood;
@synthesize devices = _devices;
@synthesize players = _players;
@synthesize bossDictionary = _bossDictionary;
@synthesize localMonsters = _localMonsters;
@synthesize boss = _boss;

NSString* const DICTIONARY_FILE = @"CommonWords-SixOrLess";
NSString* const BOSS_DICTIONARY_FILE = @"CommonWords-TwelveOrMore";


#pragma mark - setters and getters 

- (NSMutableSet*)monsters { 
    if (_monsters == nil) {
        _monsters = [[NSMutableSet alloc] init];
    }
    return _monsters;
}

- (void)setMonsters:(NSMutableSet*)monsters {
    _monsters = monsters;
}

- (NSMutableArray*)dictionary { 
    if (_dictionary == nil) {
        _dictionary = [[NSMutableArray alloc] init];
    }
    return _dictionary;
}

- (void)setDictionary:(NSMutableArray *)dictionary {
    _dictionary = dictionary;
}

- (NSMutableArray*)bossDictionary { 
    if (_bossDictionary == nil) {
        _bossDictionary = [[NSMutableArray alloc] init];
    }
    return _bossDictionary;
}

- (void)setBossDictionary:(NSMutableArray *)bossDictionary {
    _bossDictionary = bossDictionary;
}


static MNCenter *mnCenter = nil;
+(MNCenter *) sharedMNCenter {

    if (!mnCenter) {
        mnCenter = [[MNCenter alloc] initWithSessionID:@"ninjasvsdragons"];
    }
    return mnCenter;

}



+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) notifyTime:(double) time {
    int min = time / 60;
    int sec = ((int) time) % 60;
    [self.timerLabel setString:[NSString stringWithFormat:@"%i:%02i", min, sec]];
}

-(void) notifyScore:(int) theScore {
    NSLog(@"in score!");
    [self.scoreLabel setString:[NSString stringWithFormat:@"Score: %i", theScore]];

}

// reset all re-playable game elements
-(void) resetGame {
    gameCount++;
    
    // clear text field
    self.textEntryFieldCC.text = @"";
    
    // remove existing monsters
    for (Monster* monster in self.monsters) {
        [self removeChild:monster cleanup:YES];
    }
    
    [self.monsters removeAllObjects];
    [self.localMonsters removeAllObjects];
    
    [self removeChild:self.blood cleanup:YES];
    
    self.isGameOver = NO;
    self.gameOverReason = 0; // no reason
    timeLeft = GAME_LENGTH_SECONDS;
    nextMonsterTimer = MONSTER_EVERY_X_SECONDS;
    nextFireballTimer = FIREBALL_EVERY_X_SECONDS;
    score = 0;
    bossAppeared = NO;
    self.textEntryFieldCC.text = @"";
    [self notifyTime:timeLeft];
    [self notifyScore:score];
    
    if (gameCount > 1) {
        NSLog(@"game over screen is %@",self.gameOverScreen);
        [self removeChild:self.gameOverScreen cleanup:YES];
        [self.textEntryFieldCC setFocus];
    }
    [self sendJoinRequest:nil]; // broadcast request for monster info

    // existing player re-walk onto the screen
    for (Player *player in self.players.allValues) {
        if (!player.isMe) {
            player.position = ccp(-player.boundingBox.size.width / 2, self.myPlayer.position.y); // offscreen position. We'll rewalk them all on screen
        }
    }
    [self repositionPlayers]; // reposition all remote players
}

-(void) initCommChannel {
    self.devices = [NSMutableSet setWithCapacity:5];
    MNCenter *networkCenter = [HelloWorldLayer sharedMNCenter];
    networkCenter.deviceConnectedCallback = ^(Device *device) {
        [self.devices addObject:device];
        //NSLog(@"Connected: %@", [device deviceName]);
        [self sendJoinRequest:device];
        //[self connected];
    };
    
    networkCenter.deviceDisconnectedCallback = ^(Device *device) {
        [self.devices removeObject:device];
        [self remotePlayerLeft:device];
        //NSLog(@"Disconnected: %@", [device deviceName]);
        
        //[self connected];
    };
    
    [networkCenter start];
        
    [networkCenter.sessionManager setOnStateChange:^{
        //[self connected];
    }];
    
    networkCenter.dataReceivedCallback = ^(NSData *data, Device *d) {
        NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        [self handleIncomingMessage:data fromDevice:d];
        //NSLog(@"Received msg from %@: %@", d.deviceName, msg);
    };
    
    //NSLog(@"MY PEER ID: %@", [HelloWorldLayer sharedMNCenter].sessionManager.meshSession.peerID);

    
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        self.lastWord = @"";
        self.players = [NSMutableDictionary dictionaryWithCapacity:5];
        self.localMonsters = [NSMutableSet setWithCapacity:5];
		
        // ask director the the window size
		screenSize = [[CCDirector sharedDirector] winSize];
        

        // background
        CCSprite *background = [CCSprite spriteWithFile:@"grass-background-1.png"];
        background.position = ccpMult(ccpFromSize(screenSize), 0.5);
        [self addChild:background z:-1];
        CCAnimation *bgAnimation = [Monster animationFromTemplate:@"grass-background-%@.png" andFrames:@"1,2,3,2"];
        [background runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:0.5 animation:bgAnimation restoreOriginalFrame:NO]]];
         
        // Timer label
        self.timerLabel = [CCLabelTTF labelWithString:@"HELLO" fontName:@"Arial-BoldMT" fontSize:20];
        [self.timerLabel setAnchorPoint:ccp(0, 1)];
        self.timerLabel.position = ccp(0, screenSize.height); // top left
        [self addChild:self.timerLabel z:1];
        
        
        // score label
        self.scoreLabel = [CCLabelTTF labelWithString:@"Hi there" fontName:@"Arial-BoldMT" fontSize:20];
        [self.scoreLabel setAnchorPoint:ccp(1,1)];
        self.scoreLabel.position = ccp(screenSize.width, screenSize.height);
        [self addChild:self.scoreLabel z:1];
        
        // 'dictionary' is filled upon game load and holds all possible words
        NSError* error;
        NSString* filePath = [[NSBundle mainBundle] pathForResource:DICTIONARY_FILE ofType:@"txt"];
        NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
        NSArray* wordsWithBlanks = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        for (NSString* word in wordsWithBlanks) {
            if (![[word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                [self.dictionary addObject:word];
            }
        }
        
        filePath = [[NSBundle mainBundle] pathForResource:BOSS_DICTIONARY_FILE ofType:@"txt"];
        fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
        wordsWithBlanks = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        for (NSString* word in wordsWithBlanks) {
            if (![[word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                [self.bossDictionary addObject:word];
            }
        }
        

//        self.dictionary = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
//        self.dictionary = [fileContents componentsSeparatedByString:@"\n\r"];
//        NSLog(@"the file contents are %@",fileContents);
        
        NSLog(@"the dictionary is : %@",self.bossDictionary);
        
        self.textEntryFieldCC = [CCTextField textFieldWithFieldSize:CGSizeMake(screenSize.width, 30) fontName:@"Arial-BoldMT" andFontSize:20];
        self.textEntryFieldCC.delegate = self;
        self.textEntryFieldCC.position = ccp(0,210);
        self.textEntryFieldCC.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self addChild:self.textEntryFieldCC];
        [self.textEntryFieldCC setTextColor:ccWHITE];
        [self.textEntryFieldCC setText:@""];
        [self.textEntryFieldCC setFocus];
        
        self.myPlayer = [[Player alloc] initWithName:[[UIDevice currentDevice] name]];
        playerPosition = ccp(screenSize.width / 2, 215 + self.myPlayer.boundingBox.size.height / 2);
        self.myPlayer.position = playerPosition;
        self.myPlayer.isMe = YES;
        [self addChild:self.myPlayer];
        
        gameCount = 0;
        [self resetGame]; // reset all counters, labels, etc.
        
        [self initCommChannel];
        [self.players setObject:self.myPlayer forKey:[HelloWorldLayer sharedMNCenter].peerID];

        [self schedule: @selector(tick:)];
        
/*
        // Data encoding test
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
        [dict setObject:@"abc" forKey:@"123"];
        NSKeyedArchiver *keyed = [NSKeyedArchiver archivedDataWithRootObject:dict];
        NSMutableDictionary *newDict = [NSKeyedUnarchiver unarchiveObjectWithData:keyed];
        NSLog(@"!!!!!!Unarchived value for 123: %@", [newDict valueForKey:@"123"]);
*/        
	}
	return self;
}

-(void) peerMonsterGenerator:(NSDictionary *)dict device: (Device *) device{
    if (self.isGameOver)
        return; // monsters don't bother us if we're not playing
    Player *player = [self.players objectForKey:device.peerID];
    Monster *monster = [Monster deserialize:dict peerID:device.peerID player:player];
    [self.monsters addObject:monster];
    [self addChild:monster];
    NSLog(@"COMM: Creating monster for which there's no peer on file: %@", device.peerID);
    
    [monster marchTo:player.eventualPosition];

}

-(void)randomMonsterGenerator:(ccTime) dt monsterType:(MonsterType) monsterType {
    nextMonsterTimer -= dt;
    while (nextMonsterTimer < 0) {

        // create new monster with random word and random location at the top
        int randomWordGen = arc4random() % [self.dictionary count];
        NSString* newWord = [self.dictionary objectAtIndex:MAX(0,(randomWordGen - 1))];
        double delta;
        Monster* newMonster = nil;
        CGPoint location;
        int randomXLoc = arc4random() % (int)screenSize.width;

        switch (monsterType) {
            case kMonsterTypeMinion:
                delta = MONSTER_EVERY_X_SECONDS;
                newMonster = [[MinionDragon alloc] createWithWord:newWord];
                location = ccp(randomXLoc, screenSize.height); 
                break;
                
            case kMonsterTypeFireball:
                delta = FIREBALL_EVERY_X_SECONDS;
                newMonster = [[Fireball alloc] createWithWord:newWord];
                location = ccp(screenSize.width/2, screenSize.height-self.boss.boundingBox.size.height/0.75);                break;
                
            default:
                delta = 10000; // what the hell is going on?
                return;
                break;
        }
        nextMonsterTimer += delta;
        
        [newMonster setOwnerMe:YES uniqueID:0 peerID:[HelloWorldLayer sharedMNCenter].peerID]; // set me as owner
        newMonster.position = location;

        [self.monsters addObject:newMonster];
        [self.localMonsters addObject:newMonster]; // keep separate tab of local monsters
        [self addChild:newMonster];
        [newMonster marchTo:self.myPlayer.position];
        NSLog(@"new monster is %@",newMonster);
        
        [self sendMonsterBornMessage:newMonster]; // tell the world - we're proud parents of a new monster
        
        //for (Monster* monster in self.monsters) {
        //    [monster decreasePointValue];
        //}
    }
}

/*
-(void)fireballGenerator:(ccTime) dt {
    nextFireballTimer -= dt;
    while (nextFireballTimer < 0) {
        nextFireballTimer += FIREBALL_EVERY_X_SECONDS;
        
        // create new monster with random word and random location at the top
        int randomWordGen = arc4random() % [self.dictionary count];
        NSString* newWord = [self.dictionary objectAtIndex:MAX(0,(randomWordGen - 1))];
        Monster* newMonster = [[Fireball alloc] createWithWord:newWord];
        newMonster.position = ccp(screenSize.width/2, screenSize.height-self.boss.boundingBox.size.height/0.75);
        [self.monsters addObject:newMonster];
        [self.localMonsters addObject:newMonster]; // keep separate tab of local monsters
        [self addChild:newMonster];
        [newMonster marchTo:self.myPlayer.position];
        NSLog(@"new monster is %@",newMonster);
        
        [self sendMonsterBornMessage:newMonster]; // tell the world - we're proud parents of a new monster
        
        for (Monster* monster in self.monsters) {
            [monster decreasePointValue];
        }
    }
}
 */

-(void)generateBoss {
    int randomBossWordGen = arc4random() % [self.bossDictionary count];
    NSString* newWord = [self.bossDictionary objectAtIndex:MAX(0,(randomBossWordGen - 1))];
    Monster* newBoss = [[BossDragon alloc] createWithWord:newWord];
    [newBoss setOwnerMe:YES uniqueID:0 peerID:[HelloWorldLayer sharedMNCenter].peerID];
    newBoss.position = ccp(screenSize.width/2,screenSize.height - newBoss.boundingBox.size.height/2);
    self.boss = newBoss;
    [self.monsters addObject:newBoss];
    [self.localMonsters addObject:newBoss];
    [self addChild:newBoss];
    [self sendMonsterBornMessage:newBoss];
}

-(void)showBlood {
    [self.textEntryFieldCC hideKeyboard];

    self.blood = [[BloodDrip alloc] initWithFile:@"blood-screen.png"];
    [self.blood setAnchorPoint:ccp(0.5,0)];
    self.blood.position = ccp(screenSize.width/2,screenSize.height);
    [self addChild:self.blood z:2];
    
    [self.blood bloodDrip];
}

-(void) showGameOverScreen {
    [self.textEntryFieldCC hideKeyboard];
    
    if(self.gameOverReason == kGameOverEaten) {
        self.gameOverScreen = [[EndScreen alloc] initWithColor:ccc4(163, 3, 0, 255) width:screenSize.width height:screenSize.height];
    } else {
        self.gameOverScreen = [[EndScreen alloc] initWithColor:ccc4(220, 220, 220, 255) width:screenSize.width height:screenSize.height];
    }
    [self.gameOverScreen createWithFinalScore:score withReason:self.gameOverReason];
    [self addChild:self.gameOverScreen z:3];
}

// remove leftover monsters. for some reason they're sticking around
-(void) endOfGameCleanup {
    for (Monster* monster in self.monsters) {
        [monster removeFromParentAndCleanup:YES];
    }
    
}

-(void) hitByMonster:(Monster *) monster {
    self.isGameOver = YES;
    self.gameOverReason = kGameOverEaten;
    [self endOfGameCleanup];
    [self sendPlayerLeftMessage];
    [self showBlood];
}

-(void) remoteKillMonster:(NSDictionary *)dict device:(Device *)device {

    NSString *word = [dict objectForKey:KEY_WORD];
    //NSLog(@"REMOTE KILL WORD %@ PEER ID: %@ FOR UID %i", [dict objectForKey:KEY_WORD], [dict objectForKey:KEY_PEER_ID], [[dict objectForKey:KEY_UNIQUE_ID] intValue]);
    int uid = [[dict objectForKey:KEY_UNIQUE_ID] intValue];
    NSString *peerID = [dict objectForKey:KEY_PEER_ID];
    // there will only be one such monster. Place it in a variable
    Monster *theDead = nil;
    
    for (Monster *monster in self.monsters) {
        if ((monster.uniqueID == uid)) {
            if ([monster.peerID isEqualToString:peerID]) {
                //NSLog(@"KILLING: %@", word);
                theDead = monster;
            }
        }
    }
    
    if (theDead) {
        theDead.isSlatedToDie = YES;
        // For now, just kill the monster, since we don't yet have an associated player:
        Player *player = [self.players objectForKey:theDead.peerID];
        if (player) {
            [player throwWeaponAt:theDead];
        } else {
            // someone killed it but we don't know who. Just explode it
            [theDead die];
        }
        [self.monsters removeObject:theDead];
        [self.localMonsters removeObject:theDead];
    }
}

// main update loop
-(void) tick: (ccTime) dt {
    if (self.isGameOver)
        return;
    
    int min = timeLeft / 60;
    int sec = ((int) timeLeft) % 60;
    
    // game is over, time is up and all monsters created are killed
    if (timeLeft <= 0 && [self.localMonsters count] == 0) {
        // game over, timed out
        self.isGameOver = YES;
        self.gameOverReason = kGameOverTimeOut;
        [self endOfGameCleanup];
        [self sendPlayerLeftMessage];
        [self showGameOverScreen];
        return; // nothing further to do
    } 
    
    if (timeLeft > 0) { // game not over yet since timer still ticking
        timeLeft -= dt;
        [self notifyTime:MAX(timeLeft, 0)];
        if (timeLeft > 10) {
            [self randomMonsterGenerator:dt monsterType:kMonsterTypeMinion];
        } else {
            [self randomMonsterGenerator:dt monsterType:kMonsterTypeFireball];
        }

        // add boss at 10 seconds remaining
        if (min == 0 && sec <= 10) {
            if (bossAppeared == NO) {
                bossAppeared = YES;
                //[self generateBoss];
            }
//            if (sec % 3) {
//                [self.boss throwFireballAt:self.myPlayer];
//                NSLog(@"throw fireball");
//            }
//            NSLog(@"10 sec left");
        }
    }        
    // check if a new word was entered (very inefficient) and then check against all monsters
    NSString *newWord = self.textEntryFieldCC.text.lowercaseString;
    NSMutableSet *deadMonsters = [NSMutableSet setWithCapacity:1];
    if (![newWord isEqualToString:self.lastWord]) {
        for (Monster *monster in self.monsters) {
            if ([monster attackWithWord:newWord]) {
                monster.isSlatedToDie = YES;
                [deadMonsters addObject:monster];
                [self sendMonsterDiedMessage:monster];
            }
        }
        for (Monster *monster in deadMonsters) {
            score+=[monster getKillScore];
            [self.myPlayer throwWeaponAt:monster];
            [self notifyScore:score];
        }
        if ([deadMonsters count] > 0) {
            // we killed a monster, so clear field  
            self.textEntryFieldCC.text = @"";
        }
        [self.monsters minusSet:deadMonsters]; // this same code appears again later ... ???
        [self.localMonsters minusSet:deadMonsters];
        self.lastWord = [NSString stringWithString:newWord];
        [self sendPlayerTypedMessage:self.lastWord];
    }
    
    // Check for monsters that have reached the player
    for (Monster *monster in self.monsters) {
        if (monster.reachedPlayer && !monster.isSlatedToDie) {
            [deadMonsters addObject:monster];
            [self hitByMonster:monster];
        }
    }
    [deadMonsters removeAllObjects];
    [self.monsters minusSet:deadMonsters];
}

- (BOOL)textField:(CCTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        return YES; // allow backspace
    }
    
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    // also make sure the current text works
    for (int i = [result length]; i >= 0; i--) {
        NSString *needle = [result substringToIndex:i];
        for (Monster *monster in self.monsters) {
            if ([monster.word hasPrefix:needle]) {
                // see if it's still valid with the replacement string appended
                NSString *extended = [needle stringByAppendingString:string];
                if ([monster.word hasPrefix:extended]) {
                    textField.text = extended;
                } else {
                    textField.text = needle;
                }
                return NO;
            }
        }
    }
    // check to see if the end of the text matches
    // this is lower priority, so we intentionally do it AFTER checking the beginning of the text
    for (int i = 0; i < [result length]; i++) {
        NSString *needle = [result substringFromIndex:i];
        for (Monster *monster in self.monsters) {
            if ([monster.word hasPrefix:needle]) {
                // see if it's still valid with the replacement string appended
                NSString *extended = [needle stringByAppendingString:string];
                if ([monster.word hasPrefix:extended]) {
                    textField.text = extended;
                } else {
                    textField.text = needle;
                }
                return NO;
            }
        }
    }
    
    // nothing matched. blank out the text field
    textField.text = @"";
    return NO;
}

-(BOOL) textFieldShouldReturn:(CCTextField *)textField {
    // if we know this text field, allow it to return if game is over, otherwise no returns.
    if (textField == self.textEntryFieldCC) {
        if (self.isGameOver)
            return YES;
        else
            return NO;
    }
    // which text field could it be?
    return YES;
}

- (void)textFieldDidReturn:(CCTextField *)textField {
    // intentionally do nothing
}

-(void) repositionPlayers {
    int remotePlayers = [self.players count] - 1;
    if (remotePlayers == 0)
        return; // nothing to do

    // identify if new player joined
    
    Player *firstPlayer = nil;
    NSMutableArray *allPlayers = [NSMutableArray arrayWithArray:self.players.allValues];
    [allPlayers removeObject:self.myPlayer];
    for (Player *player in allPlayers) {
        if (!CGRectContainsPoint(self.boundingBox, player.position)) {
            // this player is off screen so just joining. give it prime position outside
            firstPlayer = player;
            break;
        }
    }
    if (firstPlayer) {
        [allPlayers removeObject:firstPlayer];
        [allPlayers insertObject:firstPlayer atIndex:0]; // make sure it's the first player
    }    
    // Now position equidistantly around main player
    if (remotePlayers % 2 == 0)
        remotePlayers++; // make it odd for center placement

    float deltaD = screenSize.width / (remotePlayers + 2); //  +2 for buffers on left and right of screen

    int pos = - remotePlayers / 2; // start from left of screen
    // now traverse in order
    for (Player *player in allPlayers) {
        if (pos == 0)
            pos++; // 0 position is reserved for main player
        CGPoint newPos = ccp(self.myPlayer.position.x + pos * deltaD, self.myPlayer.position.y);
        [player walkTo:newPos];
        pos++;
    }
}

-(void) remotePlayerJoined:(Device *)device {
    Player *player = [self.players objectForKey:device.peerID];
    if (!player) {
        // we don't have this player yet. create
        player = [[Player alloc] initWithName:device.deviceName];
        [self addChild:player];
        [self.players setObject:player forKey:device.peerID];
        // position off screen. Player will be animated onto it
        player.position = ccp(-self.boundingBox.size.width, 215 + self.boundingBox.size.height / 2);
        [self repositionPlayers];
    } else {
        NSLog(@"COMM: Player joining game they're alreayd part of: %@", device.peerID);
    }
        
}

-(void) remotePlayerLeft:(Device *)device {
    Player *player = [self.players objectForKey:device.peerID];
    if (player) {
        if (!self.isGameOver) {
            [player walkOffScreen];
            [self repositionPlayers];
        }
        [self.players removeObjectForKey:device.peerID];
        NSMutableSet *goneMonsters = [NSMutableSet setWithCapacity:5];
        for (Monster *monster in self.monsters) {
            if ((!monster.isMine) && [monster.peerID isEqualToString:device.peerID]) {
                if (!self.isGameOver) {
                    [monster walkOffScreen];
                }
                [goneMonsters addObject:monster];
            }
        }
        [self.monsters minusSet:goneMonsters];
    } else {
        NSLog(@"COMM: Unknown player leaving the game. what to do what to do?: %@",device.peerID);
    }
}

-(void) remotePlayerTyped:(NSDictionary *)dict device:(Device *)device {
    NSString *text = [dict objectForKey:KEY_TEXT];
    Player *player = [self.players objectForKey:device.peerID];
    if (player) {
        [player notifyTypedMessage:text];
    } else {
        NSLog(@"COMM: Typed message from unknown player %@: %@", device.peerID, text );
    }
}

/************* Communication **************/

-(void) handleIncomingMessage:(NSData *)data fromDevice:(Device *)device {
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    PeerMessageType peerMessageType = [[dict objectForKey:MESSAGE_TYPE] intValue];
    NSLog(@"Got message of type: %i", peerMessageType);
    switch (peerMessageType) {
        case kMessageJoinRequest: {
            if (!self.isGameOver) {
                [self remotePlayerJoined:device];
                //NSLog(@"New peer wants to join the game. Send them a dump of all current (local) monsters");
                // for now don't send any existing monsters:
                //for (Monster *monster in self.monsters) {
                //    if (monster.isMine) {
                //        [self sendMonsterBornMessage:monster];
                //    }
                //}
            }
        }
            break;
            
        case kMessageMonsterBorn:
            [self peerMonsterGenerator:dict device:device];
            break;
            
        case kMessageMonsterDead:
            [self remoteKillMonster:dict device:device];
            break;
            
        case kMessagePlayerLeft:
            [self remotePlayerLeft:device];
            break;
            
        case kMessagePlayerTyped:
            [self remotePlayerTyped:dict device:device];
            break;
            
        default:
            NSLog(@"unknown message type received!");
            break;
    }
}


-(void) sendMessage:(NSDictionary *)dict{
    NSData *keyed = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [[HelloWorldLayer sharedMNCenter] sendDataToAllPeers:keyed];
}

-(void) sendJoinRequest:(Device *)device {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5 ];
    [dict setObject:[NSNumber numberWithInt:kMessageJoinRequest]  forKey:MESSAGE_TYPE];
    [self sendMessage:dict];
}

-(void) sendMonsterBornMessage:(Monster *)monster {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5 ];
    [dict setObject:[NSNumber numberWithInt:kMessageMonsterBorn] forKey:MESSAGE_TYPE];
    [dict addEntriesFromDictionary:[monster serialize]];
    [self sendMessage:dict];
}

-(void) sendMonsterDiedMessage:(Monster *)monster {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5 ];
    [dict setObject:[NSNumber numberWithInt:kMessageMonsterDead] forKey:MESSAGE_TYPE];
    [dict addEntriesFromDictionary:[monster serialize]]; // we can use the whole dictionary. The message type says it all so we won't parse the whole thing
    [self sendMessage:dict];
}

// notify that player left game (for whatever reason)
-(void) sendPlayerLeftMessage {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5 ];
    [dict setObject:[NSNumber numberWithInt:kMessagePlayerLeft] forKey:MESSAGE_TYPE];
    [self sendMessage:dict];
}

// notify that player typed a message
-(void) sendPlayerTypedMessage:(NSString *)text {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5 ];
    [dict setObject:[NSNumber numberWithInt:kMessagePlayerTyped] forKey:MESSAGE_TYPE];
    [dict setObject:text forKey:KEY_TEXT];
    [self sendMessage:dict];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)

	self.timerLabel = nil;
    self.scoreLabel = nil;
    self.textEntryLabel = nil;
    self.textEntryFieldUI = nil;
    self.textEntryFieldCC = nil;
    self.lastWord = nil;
    self.myPlayer = nil;
    self.devices = nil;
    self.players = nil;
    self.localMonsters = nil;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
