//
//  Player.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "Player.h"
#import "Monster.h"
#import "MinionDragon.h"
#import "Fireball.h"

#define TEMPLATE_NAME @"ninja-sway-%@.png"
#define FRAME_ORDER @"2,1,2,3"

#define THROW_TEMPLATE_NAME @"ninja-throw-%@.png"
#define THROW_FRAME_ORDER @"1,2"

@implementation Player

@synthesize name = _name;
@synthesize isMe;
@synthesize swayAction = _swayAction;
@synthesize throwAction = _throwAction;
@synthesize isLeaving = _isLeaving;
@synthesize eventualPosition;
@synthesize nameLabel = _nameLabel;

-(Player *) initWithName:(NSString *) playerName {
    CCAnimation *animation = [Monster animationFromTemplate:TEMPLATE_NAME andFrames:FRAME_ORDER];
    NSAssert2(animation, @"Could not create animation for template %@ and frames %@", TEMPLATE_NAME, FRAME_ORDER);

    if (self = [super initWithSpriteFrame:[animation.frames lastObject]]) {
        screenSize = [[CCDirector sharedDirector] winSize];
        self.isLeaving = NO;
        self.name = [[playerName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" .,"]] objectAtIndex:0];
        self.color = ccRED;
        self.nameLabel = [CCLabelTTF labelWithString:self.name fontName:@"Arial-BoldMT" fontSize:15];
        [self.nameLabel setAnchorPoint:ccp(0.5, 0)];
        [self addChild:self.nameLabel];
        self.nameLabel.position = ccp(self.boundingBox.size.width / 2, self.boundingBox.size.height );
        self.swayAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:1 animation:animation restoreOriginalFrame:NO]];
        CCAnimation *throwAnim = [Monster animationFromTemplate:THROW_TEMPLATE_NAME andFrames:THROW_FRAME_ORDER];
        self.throwAction = [CCAnimate actionWithDuration:0.2 animation:throwAnim restoreOriginalFrame:YES];
        
        [self runAction:self.swayAction];
    
    }
    return self;
}

-(void) throwWeaponAt:(Monster *)monster {
    if (self.isLeaving) {
        // player is leaving so we're not adding animation
        [monster die];
        return;
    }
    if (!self.swayAction.isDone) {
        [self stopAction:self.swayAction];
    }

    // basically we do some animation on the ninja, then after that's done we add a star to the screen and do animation on it. It's responsible for killing the monster and cleaning up after itself.
    
    CCFiniteTimeAction *revertToSwaying = [CCCallBlock actionWithBlock:^{
        [self runAction:self.swayAction];
    }];
    
    CCFiniteTimeAction *starAction = [CCCallBlock actionWithBlock:^{
        CCNode *projectile;
        if ([monster isKindOfClass:[Fireball class]]) {
            projectile = [CCParticleSystemQuad particleWithFile:@"WaterStrike.plist"];
        } else {
            projectile = [CCSprite spriteWithFile:@"ninja-star-1.png"];
        }
        [self.parent addChild:projectile];
        projectile.position = self.position;
        // tell monster it's dead
        CCFiniteTimeAction *monsterIsDead = [CCCallBlock actionWithBlock:^{
            [monster die];
            [projectile removeFromParentAndCleanup:YES];
            
        }];
        CCMoveTo *starMove = [CCMoveTo actionWithDuration:STAR_THROW_TIME position:monster.position];
        [projectile runAction:[CCSequence actions:starMove, monsterIsDead, nil]];
    }];
    
    
    
    
    [self runAction:[CCSequence actions:
                     self.throwAction,
                     revertToSwaying,
                     starAction,
                     nil]];
}

-(void) walkTo:(CGPoint)newPos {
    self.eventualPosition = newPos;
    [self runAction:[CCMoveTo actionWithDuration:0.5 position:newPos]];

}

-(void) walkOffScreen {
    self.isLeaving = YES;
    CGPoint newPosition = ccp(-self.boundingBox.size.width, self.position.y);
    CCMoveTo *moveAction = [CCMoveTo actionWithDuration:0.5 position:newPosition];
    CCFiniteTimeAction *cleanupAction = [CCCallBlock actionWithBlock:^{
        [self removeFromParentAndCleanup:YES];
    }];
    [self runAction:[CCSequence actions:moveAction, cleanupAction, nil ]];
}

-(void) notifyTypedMessage:(NSString *)text {
    [self.nameLabel setString:text];
}

- (void)dealloc
{
    self.name = nil;
    self.swayAction = nil;
    self.throwAction = nil;
    self.nameLabel = nil;
    [super dealloc];
}


@end
