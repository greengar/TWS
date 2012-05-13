//
//  Monster.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Monster.h"
#import "MinionDragon.h"
#import "Constants.h"

@implementation Monster

@synthesize word = _word;
@synthesize points = _points;
@synthesize reachedPlayer;
@synthesize walkAction = _walkAction;
@synthesize isSlatedToDie;
@synthesize peerID;
@synthesize uniqueID;
@synthesize moveAction = _moveAction;

NSString* const MINION_MONSTER_IMAGE = @"small-dragon.png";

- (NSString*)description {
     NSString* description = [NSString stringWithFormat:@"xPos: %@, yPos: %@, word: %@",[NSNumber numberWithFloat:self.position.x],[NSNumber numberWithFloat:self.position.y],self.word];
    return description;
}

+(CCAnimation *) animationFromTemplate:(NSString *)animationTemplate andFrames:(NSString *)frames {
    // Look for animation. If doesn't exist, create it.
    NSString *animationName = [NSString stringWithFormat:animationTemplate, @"animation"];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    if (!animation) {
        // prepare set of frame names
        animation = [CCAnimation animation];
        NSArray *frameNumbers = [frames componentsSeparatedByString:@","];
        NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:[frameNumbers count]];
        for (NSString *num in frameNumbers) {
            [animation addFrameWithFilename:[NSString stringWithFormat:animationTemplate, num]];
            //NSLog(@"Adding frame: %@", [frameNames lastObject]);
            
        }
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animationName];
    }
    return animation;
}


- (Monster*)createWithWord:(NSString*)word animationTemplate:(NSString *)animationTemplate frames:(NSString *)frames {
    
    CCAnimation *animation = [Monster animationFromTemplate:animationTemplate andFrames:frames];
    NSAssert2(animation, @"Could not create animation for template %@ and frames %@", animationTemplate, frames);
    
    
    
    
    if (self = [super initWithSpriteFrame:[animation.frames lastObject] ]) {
        timeLeftToReachPlayer = MONSTER_MOVE_DURATION_SECONDS;
        self.isSlatedToDie = NO;
        self.word = word;
        self.points = INITIAL_POINTS;
        self.reachedPlayer = NO;
        
        CCLabelTTF *name = [CCLabelTTF labelWithString:self.word fontName:@"Arial-BoldMT" fontSize:15];
        [name setAnchorPoint:ccp(0.5, 1)];
        [self addChild:name];
        name.position = ccp(self.boundingBox.size.width / 2,0 );
        self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:2 animation:animation restoreOriginalFrame:NO]];
        [self runAction:self.walkAction];
    }
    
    return self;
}

- (void)die {
    CCParticleSystemQuad *explosion = [CCParticleSystemQuad particleWithFile:@"MonsterPlosion.plist"];
    [self.parent addChild:explosion];
    explosion.position = self.position;
    
    [explosion runAction:[CCSequence actions:
                          //[CCScaleTo actionWithDuration:1 scale:0.1],
                          [CCDelayTime actionWithDuration:1],
                          [CCCallBlock actionWithBlock:^{
        [explosion removeFromParentAndCleanup:YES];
    }],
                          nil]];

    [self removeFromParentAndCleanup:YES];
    
}

-(void) marchTo:(CGPoint)destination {
    CCFiniteTimeAction *marchAction = [CCMoveTo actionWithDuration:timeLeftToReachPlayer position:destination];
    CCFiniteTimeAction *marchCompleteAction = [CCCallBlock actionWithBlock:^{
        self.reachedPlayer = YES;
    }];
    self.moveAction = [CCSequence actions:marchAction, marchCompleteAction, nil];
    [self runAction:self.moveAction];
}

-(BOOL) attackWithWord:(NSString *)attackWord {
    BOOL equal = [attackWord isEqualToString:self.word];
    //NSLog(@"Equal: %i  %@ <-> %@", self.word, attackWord);
    //NSLog(@"Length: %i <-> %i", [self.word length], [attackWord length]);
    return equal;
}

-(void) decreasePointValue {
    self.points = self.points - POINT_DECREASE_VALUE;
}

-(void) setOwnerMe:(BOOL)isMine uniqueID:(int)theUniqueId peerID:(NSString *)thePeerID {
    if (isMine) {
        self.peerID = nil;
        self.uniqueID = arc4random();
    } else {
        self.peerID = thePeerID;
        self.uniqueID = theUniqueId;
    }
    NSLog(@"Peer: %@ ID: %i", self.peerID, self.uniqueID);
}

-(BOOL) isMine {
    return (peerID == nil);
}

#define KEY_WORD @"word"
#define KEY_POINTS @"points"
#define KEY_IS_SLATED_TO_DIE @"slated"
#define KEY_UNIQUE_ID @"unique"
#define KEY_POSITION @"position"
#define KEY_TIME_LEFT_TO_REACH_PLAYER @"timeleft"
#define KEY_MONSTER_TYPE @"monstertype"

-(NSMutableDictionary *) serialize {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dict setObject:self.word forKey:KEY_WORD];
    [dict setObject:[NSNumber numberWithInt:self.points] forKey:KEY_POINTS];
    [dict setObject:[NSNumber numberWithBool:self.isSlatedToDie] forKey:KEY_IS_SLATED_TO_DIE];
    [dict setObject:[NSNumber numberWithInt:uniqueID] forKey:KEY_UNIQUE_ID];
    [dict setObject:[NSValue valueWithCGPoint:self.position] forKey:KEY_POSITION];
    [dict setObject:[NSNumber numberWithDouble:(self.moveAction.duration - self.moveAction.elapsed)] forKey:KEY_TIME_LEFT_TO_REACH_PLAYER];
    [dict setObject:[NSNumber numberWithInt:self.monsterType] forKey:KEY_MONSTER_TYPE];
    return dict;
}

+(Monster *) deserialize:(NSDictionary *)dict peerID:(NSString *)thePeerID {
    MonsterType mt = [[dict objectForKey:KEY_MONSTER_TYPE] intValue];
    NSString *word = [dict objectForKey:KEY_WORD];
    Monster *monster = nil;
    switch (mt) {
        case kMonsterTypeMinion:
            monster = [[MinionDragon alloc] createWithWord:[@"PEER:" stringByAppendingString:  word]];
            break;
            
        default:
            NSLog(@"Unknown monster type: %i - can't deserialize", mt);
            break;
    }
    if (monster) {
        int uid = [[dict objectForKey:KEY_UNIQUE_ID] intValue];
        [monster setOwnerMe:NO uniqueID:uid peerID:thePeerID];
        monster.position = [[dict objectForKey:KEY_POSITION] CGPointValue];
        monster.points = [[dict objectForKey:KEY_POINTS] intValue];
        monster.isSlatedToDie = [[dict objectForKey:KEY_IS_SLATED_TO_DIE] boolValue];
        monster->timeLeftToReachPlayer = [[dict objectForKey:KEY_TIME_LEFT_TO_REACH_PLAYER] doubleValue];
    }
    return monster;

}

- (void)dealloc
{
    self.word = nil;
    self.walkAction = nil;
    self.peerID = nil;
    self.moveAction = nil;
    [super dealloc];
}

@end
