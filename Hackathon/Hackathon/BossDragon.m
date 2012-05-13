//
//  BossDragon.m
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BossDragon.h"
#import "Fireball.h"

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

@end
