//
//  Fireball.m
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Fireball.h"
#import "Constants.h"
#import "Player.h"

@implementation Fireball

-(MonsterType) monsterType {
    return kMonsterTypeFireball;
}


-(Fireball *) createWithWord:(NSString *)word {
    // there is no fireball animation
    if ((self = (Fireball*)[super createWithWord:word])) {
        fireParticle = [CCParticleSystemQuad particleWithFile:@"Fireball.plist"];
        [self addChild:fireParticle];
        fireParticle.position = ccp(0,0);
        
        timeLeftToReachPlayer = FIREBALL_MOVE_DURATION_SECONDS;
    }
    return self;
}

-(void) markAsRemote {
    return;
    fireParticle.startColor = ccc4FFromccc3B(ccBLACK);
    fireParticle.endColor = ccc4FFromccc3B(ccBLACK);;
}

-(void) specialPeerHandling:(Player *)player {
    // we're from the boss. need to align with the player:
    self.position = ccp(player.eventualPosition.x, self.position.y);
}

@end
