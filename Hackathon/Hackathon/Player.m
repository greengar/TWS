//
//  Player.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "Monster.h"
#import "Constants.h"

#define TEMPLATE_NAME @"ninja-sway-%@.png"
#define FRAME_ORDER @"2,1,2,3"

#define THROW_TEMPLATE_NAME @"ninja-throw-%@.png"
#define THROW_FRAME_ORDER @"1,2"

@implementation Player

@synthesize name = _name;
@synthesize isMe;
@synthesize swayAction = _swayAction;
@synthesize throwAction = _throwAction;

-(Player *) initWithName:(NSString *) playerName {
    CCAnimation *animation = [Monster animationFromTemplate:TEMPLATE_NAME andFrames:FRAME_ORDER];
    NSAssert2(animation, @"Could not create animation for template %@ and frames %@", TEMPLATE_NAME, FRAME_ORDER);

    if (self = [super initWithSpriteFrame:[animation.frames lastObject]]) {
        screenSize = [[CCDirector sharedDirector] winSize];
        self.name = playerName;
        self.color = ccRED;
        CCLabelTTF *name = [CCLabelTTF labelWithString:self.name fontName:@"Arial-BoldMT" fontSize:15];
        [name setAnchorPoint:ccp(0, 0)];
        [self addChild:name];
        name.position = ccp(self.boundingBox.size.width,0 );
        self.swayAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:1 animation:animation restoreOriginalFrame:NO]];
        CCAnimation *throwAnim = [Monster animationFromTemplate:THROW_TEMPLATE_NAME andFrames:THROW_FRAME_ORDER];
        self.throwAction = [CCAnimate actionWithDuration:0.2 animation:throwAnim restoreOriginalFrame:YES];
        
        [self runAction:self.swayAction];
    
    }
    return self;
}

-(void) throwWeaponAt:(Monster *)monster {
    if (!self.swayAction.isDone) {
        [self stopAction:self.swayAction];
    }

    // basically we do some animation on the ninja, then after that's done we add a star to the screen and do animation on it. It's responsible for killing the monster and cleaning up after itself.
    
    CCFiniteTimeAction *revertToSwaying = [CCCallBlock actionWithBlock:^{
        [self runAction:self.swayAction];
    }];
    
    CCFiniteTimeAction *starAction = [CCCallBlock actionWithBlock:^{
        CCSprite *star = [CCSprite spriteWithFile:@"ninja-star-1.png"];
        [self.parent addChild:star];
        star.position = self.position;
        // tell monster it's dead
        CCFiniteTimeAction *monsterIsDead = [CCCallBlock actionWithBlock:^{
            [monster die];
            [star removeFromParentAndCleanup:YES];
            
        }];
        CCMoveTo *starMove = [CCMoveTo actionWithDuration:STAR_THROW_TIME position:monster.position];
        [star runAction:[CCSequence actions:starMove, monsterIsDead, nil]];
    }];
    
    
    
    
    [self runAction:[CCSequence actions:
                     self.throwAction,
                     revertToSwaying,
                     starAction,
                     nil]];
}

-(void) walkOntoScreen {
    // for now, just pick a random place for them. Later on we'll do some more interesting positioning
    self.position = ccp(-self.boundingBox.size.width, 215 + self.boundingBox.size.height / 2);
    CGPoint newPosition = ccp(screenSize.width / 3, 215 + self.boundingBox.size.height / 2);
    [self runAction:[CCMoveTo actionWithDuration:0.5 position:newPosition]];

}

-(void) walkOffScreen {
    CGPoint newPosition = ccp(-self.boundingBox.size.width, self.position.y);
    CCMoveTo *moveAction = [CCMoveTo actionWithDuration:0.5 position:newPosition];
    CCFiniteTimeAction *cleanupAction = [CCCallBlock actionWithBlock:^{
        [self removeFromParentAndCleanup:YES];
    }];
    [self runAction:[CCSequence actions:moveAction, cleanupAction, nil ]];
}

- (void)dealloc
{
    self.name = nil;
    self.swayAction = nil;
    self.throwAction = nil;
    
    [super dealloc];
}


@end
