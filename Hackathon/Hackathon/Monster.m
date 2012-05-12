//
//  Monster.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Monster.h"

@implementation Monster

@synthesize x = _x;
@synthesize y = _y;
@synthesize word = _word;

int const INITIAL_POINTS = 30;
int const MINIMUM_POINTS = 5;

- (void)create:(int)x:(int)y:(NSString*)word {
    self.x = x;
    self.y = y;
    self.word = word;
}

- (int)moveForward:(int)amount {
    self.y = self.y - amount;
    return self.y;
}

- (void)die {
    
}

@end
