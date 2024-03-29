//
//  BossDragon.m
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BossDragon.h"
#import "Fireball.h"
#import "Player.h"

#define TEMPLATE_NAME @"boss-dragon-%@.png"
#define FRAME_ORDER @"1,2,3,4,5,6,5,4,3,2,1"

@implementation BossDragon

-(MonsterType) monsterType {
    return kMonsterTypeBoss;
}

-(BossDragon *) createWithWord:(NSString *)word {
    if ((self = (BossDragon *) [super createWithWord:word animationTemplate:TEMPLATE_NAME frames:FRAME_ORDER])) {
        self.points = BOSS_INITIAL_POINTS;
        self.movementAnimationAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:1 animation:self.animation restoreOriginalFrame:NO]];
        [self runAction:self.movementAnimationAction];
    }
    return self;
}

-(int) getKillScore {
    return self.points;
}
    
-(void) marchTo:(CGPoint)destination {
    return; // no movement for boss dragon
}

-(void) markAsRemote {
    //self.color = ccBLACK;
}

-(void) specialPeerHandling:(Player *)player {
    // we're the boss. need to align with the player:
    self.position = ccp(player.eventualPosition.x, self.position.y);
}

//-(void) throwFireballAt:(Player *)player {
//    CCFiniteTimeAction *fireballAction = [CCCallBlock actionWithBlock:^{
//        CCParticleSystemQuad *fireParticle = [CCParticleSystemQuad particleWithFile:@"Fireball.plist"];
//        Fireball *fireball = [Fireball spriteWithFile:@"blank.png"];
//        [fireball addChild:fireParticle];
//        fireball.position = self.position;
//        [self.parent addChild:fireball];
//
//        CCFiniteTimeAction *playerIsHit = [CCCallBlock actionWithBlock:^{
//            
//        }];
//        
//        CCMoveTo *fireballMove = [CCMoveTo actionWithDuration:STAR_THROW_TIME position:player.position];
//        [fireball runAction:[CCSequence actions:fireballMove, playerIsHit, nil]];
//    }];
//    [self runAction:[CCSequence actions:
//                     fireballAction,
//                     nil]];
//}

@end
