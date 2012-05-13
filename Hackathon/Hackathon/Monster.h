//
//  Monster.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Monster : CCSprite {

}

@property (nonatomic, retain) NSString* word;
@property int points;
@property BOOL reachedPlayer;
@property (nonatomic, retain) CCFiniteTimeAction *walkAction;
@property BOOL isSlatedToDie; // true if the monster is marked for death, but the star hasn't reached it yet. Make sure it doesnt' kill the player by mistake
@property int uniqueID;
@property (nonatomic, retain) NSString *peerID; // if a remote monster


+(CCAnimation *) animationFromTemplate:(NSString *)animationTemplate andFrames:(NSString *)frames; // convenience method to return an animation from a list of frames and a template

    - (Monster*)createWithWord:(NSString*)word animationTemplate:(NSString *)animationTemplate frames:(NSString *)frames;
- (void)die;

-(BOOL) attackWithWord:(NSString *)word; // returns YES if monster dead
-(void) marchTo: (CGPoint) destination;
-(void) decreasePointValue;
-(void) setOwnerMe:(BOOL)isMine uniqueID:(int)theUniqueId peerID:(NSString *)thePeerID; // set me as the owner, or provide a set of IDS to identify the monster

@end
