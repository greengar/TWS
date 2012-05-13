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


@interface BossDragon : Monster {
    
}

@property (nonatomic, retain) NSSet* words;

-(BossDragon *) createWithWord:(NSString *)word;

@end
