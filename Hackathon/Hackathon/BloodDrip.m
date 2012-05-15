//
//  BloodDrip.m
//  Hackathon
//
//  Created by Kimberly Hsiao on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BloodDrip.h"
#import "Constants.h"

@implementation BloodDrip

-(void) bloodDrip {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    CCFiniteTimeAction *bloodDrip = [CCMoveTo actionWithDuration:BLOOD_MOVE_DURATION_SECONDS position:ccp(screenSize.width/2,-100)];
    CCFiniteTimeAction *bloodCompleteAction = [CCCallFunc actionWithTarget:self.parent selector:@selector(showGameOverScreen)];

    [self runAction:[CCSequence actions:bloodDrip, bloodCompleteAction, nil]];
}

@end