//
//  MinionDragon.m
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MinionDragon.h"

#define TEMPLATE_NAME @"small-dragon-%@.png"
#define FRAME_ORDER @"1,2,3,4,5,6,7,8,9,10,11,12"

@implementation MinionDragon

-(MonsterType) monsterType {
    return kMonsterTypeMinion;
}

-(MinionDragon *) createWithWord:(NSString *)word {
    if ((self = (MinionDragon *) [super createWithWord:word animationTemplate:TEMPLATE_NAME frames:FRAME_ORDER])) {
        self.movementAnimationAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:2 animation:self.animation restoreOriginalFrame:NO]];
        [self runAction:self.movementAnimationAction];
    }
    return self;
}


@end
