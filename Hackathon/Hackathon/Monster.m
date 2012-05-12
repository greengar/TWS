//
//  Monster.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Monster.h"

@implementation Monster

//@synthesize x = _x;
//@synthesize y = _y;
@synthesize word = _word;

int const INITIAL_POINTS = 30;
int const MINIMUM_POINTS = 5;
NSString* const MONSTER_IMAGE = @"icon.png";


- (NSString*)description {
     NSString* description = [NSString stringWithFormat:@"xPos: %@, yPos: %@, word: %@",[NSNumber numberWithFloat:self.position.x],[NSNumber numberWithFloat:self.position.y],self.word];
    return description;
}

- (Monster*)create:(int)x:(int)y:(NSString*)word {
    if (self = [super initWithFile:MONSTER_IMAGE]) {
//        self.x = x;
//        self.y = y;
        self.position = ccp(x,y);
        self.word = word;
    }
    return self;
}

- (CGPoint)move:(int)x:(int)y {
    CGPoint newPosition = CGPointMake(self.position.x - x, self.position.y - y);
    self.position = newPosition;
    return self.position;
}

- (void)die {
    
}

@end
