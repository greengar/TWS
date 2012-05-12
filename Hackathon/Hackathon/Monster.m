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

- (int)moveForward:(int)amount {
    self.x = self.x + amount;
    return amount;
}

- (void)die {
    
}

@end
