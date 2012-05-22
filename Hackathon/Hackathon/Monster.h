//
//  Monster.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Keys for serialization
#define KEY_WORD @"word"
#define KEY_POINTS @"points"
#define KEY_IS_SLATED_TO_DIE @"slated"
#define KEY_UNIQUE_ID @"unique"
#define KEY_PEER_ID @"peerid"
#define KEY_POSITION @"position"
#define KEY_TIME_LEFT_TO_REACH_PLAYER @"timeleft"
#define KEY_MONSTER_TYPE @"monstertype"

@class Player; // forward reference

typedef enum {
    kMonsterTypeMinion=1,
    kMonsterTypeBoss,
    kMonsterTypeFireball,
} MonsterType;

@interface Monster : CCSprite {
    double timeLeftToReachPlayer; // usually the full monster amount, but when deserializing monsters, might be less
    uint lettersRemaining;
}

// IMPORTANT: If adding new fields that need to transfer between devices, make sure to update the serialize and deserialize methods!!!

@property (nonatomic, retain) NSString* word;
@property int points;
@property BOOL reachedPlayer;
@property (nonatomic, retain) CCFiniteTimeAction *movementAnimationAction; // movement animation
@property (nonatomic, retain) CCActionInterval *moveAction; // actual movement towards player
@property (nonatomic, readonly) CCLabelTTF *name;
@property (nonatomic, retain) CCLabelTTF *completedLabel;
@property BOOL isSlatedToDie; // true if the monster is marked for death, but the star hasn't reached it yet. Make sure it doesnt' kill the player by mistake
@property int uniqueID;
@property (nonatomic, retain) NSString *peerID; // if a remote monster
@property (readonly) MonsterType monsterType; // used in serialization
@property BOOL isMine;
@property (nonatomic, retain) CCAnimation* animation;

+(CCAnimation *) animationFromTemplate:(NSString *)animationTemplate andFrames:(NSString *)frames; // convenience method to return an animation from a list of frames and a template
- (Monster*)createWithWord:(NSString*)word animationTemplate:(NSString *)animationTemplate frames:(NSString *)frames;
- (void)die;

-(BOOL) wouldBeKilledByString:(NSString *)string;
-(BOOL) attackWithString:(NSString *)string didHit:(BOOL *)monsterWasHit; // returns YES if monster dead
-(void) marchTo: (CGPoint) destination;
-(void) decreasePointValue;
-(void) setOwnerMe:(BOOL)isMine uniqueID:(int)theUniqueId peerID:(NSString *)thePeerID; // set me as the owner, or provide a set of IDS to identify the monster

-(NSMutableDictionary *) serialize; // dump the state into a dictionary
+(Monster *) deserialize:(NSDictionary *)dict peerID:(NSString *)thePeerID player:(Player *)player;
-(void) walkOffScreen; // player walked offscreen, so follow them
-(int) getKillScore; // calculates score if monster was just killed
-(void) markAsRemote; // remote monsters can show differently if they so wish
-(void) specialPeerHandling:(Player *)player; // called by the deserialization process to see if any special handling is needed. Player might be nil

@end
