//
//  Player.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : CCSprite {
    
}

@property (nonatomic, retain) NSString *name;
@property BOOL isMe;


-(Player *) initWithName:(NSString *) playerName;

@end
