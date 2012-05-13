//
//  BossDragon.m
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BossDragon.h"

#define TEMPLATE_NAME @"small-dragon-%@.png"
#define FRAME_ORDER @"1,2,3,4,5,6,7,8,9,10,11,12"

@implementation BossDragon

-(MonsterType) monsterType {
    return kMonsterTypeBoss;
}

-(BossDragon *) createWithWord:(NSString *)word {
    if ((self = (BossDragon *) [super createWithWord:word animationTemplate:TEMPLATE_NAME frames:FRAME_ORDER])) {
        self.points = BOSS_INITIAL_POINTS;
    }
    return self;
}

-(void) throwFireballAt:(Player *)player {
    CCFiniteTimeAction *fireballAction = [CCCallBlock actionWithBlock:^{
        CCSprite *fireball = [CCSprite spriteWithFile:@"ninja-star-1.png"];
        fireball.position = self.position;
        [self.parent addChild:fireball];

        CCFiniteTimeAction *playerIsHit = [CCCallBlock actionWithBlock:^{
            
        }];
        
        CCMoveTo *fireballMove = [CCMoveTo actionWithDuration:STAR_THROW_TIME position:player.position];
        [fireball runAction:[CCSequence actions:fireballMove, playerIsHit, nil]];
    }];
    [self runAction:[CCSequence actions:
                     fireballAction,
                     nil]];
}

@end
