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
#import "MNCenter.h"
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
NSString* const DICTIONARY_FILE = @"CommonWords-SixOrLess";

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


static MNCenter *mnCenter = nil;
+(MNCenter *) sharedMNCenter {

    if (!mnCenter) {
        mnCenter = [[MNCenter alloc] init];
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
    NSLog(@"reset game called");
    gameCount++;
    self.isGameOver = NO;
    self.gameOverReason = 0; // no reason
    timeLeft = GAME_LENGTH_SECONDS;
    nextMonsterTimer = MONSTER_EVERY_X_SECONDS;
    score = 0;
    [self notifyTime:timeLeft];
    [self notifyScore:score];
    
    // remove existing monsters
    for (Monster* monster in self.monsters) {
        [self removeChild:monster cleanup:YES];
    }
    
    [self.monsters removeAllObjects];
    
    if (gameCount > 1) {
        NSLog(@"game over screen is %@",self.gameOverScreen);
        [self removeChild:self.gameOverScreen cleanup:YES];
        [self.textEntryFieldCC setFocus];
    }
}

-(void) initCommChannel {
    MNCenter *networkCenter = [HelloWorldLayer sharedMNCenter];
    networkCenter.deviceConnectedCallback = ^(Device *device) {
        //[connectedDevices addObject:device];
        NSLog(@"Connected: %@", [device deviceName]);
        //[self connected];
    };
    
    networkCenter.deviceDisconnectedCallback = ^(Device *device) {
        //[connectedDevices removeObject:device];
        NSLog(@"Disconnected: %@", [device deviceName]);
        
        //[self connected];
    };
    
    [networkCenter start];
        
    [networkCenter.sessionManager setOnStateChange:^{
        //[self connected];
    }];
    
    networkCenter.dataReceivedCallback = ^(NSData *data, Device *d) {
        NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"Received msg from %@: %@", d.deviceName, msg);
    };
    
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        [self initCommChannel];
        
        self.lastWord = @"";
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

//        self.dictionary = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
//        self.dictionary = [fileContents componentsSeparatedByString:@"\n\r"];

        //NSLog(@"the file contents are %@",fileContents);
        //NSLog(@"the dictionary is : %@",self.dictionary);
        
        
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

-(void)randomMonsterGenerator:(ccTime) dt {
    nextMonsterTimer -= dt;
    while (nextMonsterTimer < 0) {
        nextMonsterTimer += MONSTER_EVERY_X_SECONDS;
        
        // create new monster with random word and random location at the top
        int randomWordGen = arc4random() % [self.dictionary count];
        NSString* newWord = [self.dictionary objectAtIndex:MAX(0,(randomWordGen - 1))];
        int randomXLoc = arc4random() % (int)screenSize.width;
        Monster* newMonster = [[MinionDragon alloc] createWithWord:newWord];
        [newMonster setOwnerMe:YES uniqueID:0 peerID:nil]; // set me as owner
        newMonster.position = ccp(randomXLoc, screenSize.height);
        [self.monsters addObject:newMonster];
        [self addChild:newMonster];
        [newMonster marchTo:playerPosition];
        NSLog(@"new monster is %@",newMonster);
        
        for (Monster* monster in self.monsters) {
            [monster decreasePointValue];
        }
    }
}

-(void) showGameOverScreen {
    // Kim - call the game over layer from here 
    [self.textEntryFieldCC hideKeyboard];
    self.gameOverScreen = [[EndScreen alloc] initWithColor:ccc4(220, 220, 220, 255) width:screenSize.width height:screenSize.height];
    [self.gameOverScreen createWithFinalScore:score withReason:self.gameOverReason];
    [self addChild:self.gameOverScreen z:2];
}


-(void) hitByMonster:(Monster *) monster {
    self.isGameOver = YES;
    self.gameOverReason = kGameOverEaten;
    [self showGameOverScreen];
}

// main update loop
-(void) tick: (ccTime) dt {
    if (self.isGameOver)
        return;
    
    if (timeLeft > 0) { // game not over yet so:
        timeLeft -= dt;
        [self notifyTime:MAX(timeLeft, 0)];
        [self randomMonsterGenerator:dt];

        // check if a new word was entered (very inefficient) and then check against all monsters
        NSString *newWord = self.textEntryFieldCC.text.lowercaseString;
        NSMutableSet *deadMonsters = [NSMutableSet setWithCapacity:1];
        if (![newWord isEqualToString:self.lastWord]) {
            for (Monster *monster in self.monsters) {
                if ([monster attackWithWord:newWord]) {
                    monster.isSlatedToDie = YES;
                    [deadMonsters addObject:monster];
                }
            }
            for (Monster *monster in deadMonsters) {
                [self.myPlayer throwWeaponAt:monster];
                score+=monster.points;
                [self notifyScore:score];
            }
            if ([deadMonsters count] > 0) {
                // we killed a monster, so clear field
                self.textEntryFieldCC.text = @"";
            }
            [self.monsters minusSet:deadMonsters];
            self.lastWord = [NSString stringWithString:newWord];
        }
        
        // Check for monsters that have reached the player
        [deadMonsters removeAllObjects];
        for (Monster *monster in self.monsters) {
            if (monster.reachedPlayer && !monster.isSlatedToDie) {
                [deadMonsters addObject:monster];
                [self hitByMonster:monster];
            }
        }
        [self.monsters minusSet:deadMonsters];
    } else {
        // game over, timed out
        if ([self.monsters count] == 0) {
            self.isGameOver = YES;
            self.gameOverReason = kGameOverTimeOut;
            [self showGameOverScreen];
        }
    }
    
}

-(BOOL) textFieldShouldReturn:(CCTextField *)textField {
    // if we know this text field, allow it to return if game is over, otherwise no returns.
    if (textField == self.textEntryFieldCC) {
        if (self.isGameOver)
            return YES;
        else
            return NO;
    }
    // which text field coudl it be?
    return YES; 
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


	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
