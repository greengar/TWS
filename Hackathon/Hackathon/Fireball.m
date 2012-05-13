//
//  Fireball.m
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Fireball.h"
#import "Constants.h"

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

// for debugging purposes
-(void) setOwnerMe:(BOOL)isMine uniqueID:(int)theUniqueId peerID:(NSString *)thePeerID {
    [super setOwnerMe:isMine uniqueID:theUniqueId peerID:thePeerID];
    fireParticle.scale = 2;
}

@end
