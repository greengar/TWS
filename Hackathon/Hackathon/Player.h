//
//  Player.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Monster.h"

@interface Player : CCSprite {
    CGSize screenSize;
}

@property (nonatomic, retain) NSString *name;
@property BOOL isMe;
@property (nonatomic, retain) CCFiniteTimeAction *swayAction;
@property (nonatomic, retain) CCAnimation *throwAnimation;
@property BOOL isLeaving; // YES once player is leaving screen. no new actions on it
@property CGPoint eventualPosition; // incoming messaged will be shuttled here in case monster is still moving
@property (nonatomic, retain) CCLabelTTF *nameLabel; // starts with player name, gets updated as they type

-(Player *) initWithName:(NSString *) playerName;
-(void) throwWeaponAt:(Monster *)monster;
-(void) walkTo:(CGPoint) newPos; // remote ninja moving
-(void) walkOffScreen; // and going away
-(void) notifyTypedMessage:(NSString *) text; // remote user typd. Show on screen
@end
