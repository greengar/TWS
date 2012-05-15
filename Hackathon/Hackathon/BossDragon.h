//
//  MinionDragon.h
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Monster.h"
#import "Constants.h"
#import "Player.h"


@interface BossDragon : Monster {
    
}

-(BossDragon *) createWithWord:(NSString *)word;

//-(void) throwFireballAt:(Player *)player;

@end
