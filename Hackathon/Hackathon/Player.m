//
//  Player.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#define NINJA_IMAGE @"ninja-standing.png"

@implementation Player

@synthesize name = _name;
@synthesize isMe;

-(Player *) initWithName:(NSString *) playerName {
    if (self = [super initWithFile:NINJA_IMAGE]) {
        self.name = playerName;
        self.color = ccRED;
        CCLabelTTF *name = [CCLabelTTF labelWithString:self.name fontName:@"Arial-BoldMT" fontSize:15];
        [name setAnchorPoint:ccp(0, 0)];
        [self addChild:name];
        name.position = ccp(self.boundingBox.size.width,0 );

    
    }
    return self;
}

- (void)dealloc
{
    self.name = nil;
    
    [super dealloc];
}


@end
