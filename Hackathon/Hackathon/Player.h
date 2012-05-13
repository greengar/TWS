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
@property (nonatomic, retain) CCFiniteTimeAction *swayAction, *throwAction;
@property BOOL isLeaving; // YES once player is leaving screen. no new actions on it

-(Player *) initWithName:(NSString *) playerName;
-(void) throwWeaponAt:(Monster *)monster;
-(void) walkOntoScreen; // remote player joining
-(void) walkOffScreen; // and going away
@end
