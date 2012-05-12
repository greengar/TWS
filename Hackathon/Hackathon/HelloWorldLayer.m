//
//  HelloWorldLayer.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize timerLabel = _timerLabel;
@synthesize scoreLabel = _scoreLabel;
@synthesize textEntryLabel = _textEntryLabel;
@synthesize textEntryFieldCC = _textEntryFieldCC;
@synthesize textEntryFieldUI = _textEntryFieldUI;

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
    [self.timerLabel setString:[NSString stringWithFormat:@"%i:%i", min, sec]];
}

-(void) notifyScore:(int) theScore {
    [self.scoreLabel setString:[NSString stringWithFormat:@"Score: %i", score]];
}

// reset all re-playable game elements
-(void) resetGame {
    timeLeft = GAME_LENGTH_SECONDS;
    nextMonsterTimer = MONSTER_EVERY_X_SECONDS;
    score = 0;
    [self notifyTime:timeLeft];
    [self notifyScore:score];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// ask director the the window size
		screenSize = [[CCDirector sharedDirector] winSize];
        
/*
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

	
		// position the label on the center of the screen
		label.position =  ccp( screenSize.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
*/
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
        
        // Set up text entry fields. See documentation for CCTextField for the why
  
/*
        // Create the CCTextField from some UITextField and a CCLabelTTF (several CCTextFields can share the same UITextField this way)
        self.textEntryFieldUI = [[[UITextField alloc] initWithFrame:CGRectMake(2000, 200, 150, 50)] autorelease ]; // Make sure it's not visible
        // Set any attributes to your field
        self.textEntryFieldUI.keyboardType = UIKeyboardTypeDefault;
        
        self.textEntryLabel = [CCLabelTTF labelWithString:@"XXXX" fontName:@"Arial-BoldMT" fontSize:30];
        
        // Finally
        self.textEntryFieldCC = [CCTextField textFieldWithLabel:self.textEntryLabel andTextField:self.textEntryFieldUI];
        self.textEntryFieldCC.position = ccp(200, 200);
        [self addChild:self.textEntryFieldCC];
        //[self.textEntryFieldUI becomeFirstResponder];
        
*/        
        self.textEntryFieldCC = [CCTextField textFieldWithFieldSize:CGSizeMake(screenSize.width, 30) fontName:@"Arial-BoldMT" andFontSize:20];
        self.textEntryFieldCC.position = ccp(0,210);
        [self addChild:self.textEntryFieldCC];
        [self.textEntryFieldCC setTextColor:ccWHITE];
        [self.textEntryFieldCC setText:@""];
        [self.textEntryFieldCC setFocus];
        
        [self resetGame]; // reset all counters, labels, etc.
        
        [self schedule: @selector(tick:)];
        
	}
	return self;
}

-(void) randomMonsterGenerator:(ccTime) dt {
    nextMonsterTimer -= dt;
    while (nextMonsterTimer < 0) {
        nextMonsterTimer += MONSTER_EVERY_X_SECONDS;
        // CALL MONSTER GENERATION CODE HERE
        NSLog(@"New monster");
    }
}


// main update loop
-(void) tick: (ccTime) dt {
    if (timeLeft > 0) {
        // game not over yet so:
        timeLeft -= dt;
        [self notifyTime:MAX(timeLeft, 0)];
        [self randomMonsterGenerator:dt];
    }
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




	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
