//
//  Monster.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Monster.h"
#import "Constants.h"

@implementation Monster

@synthesize word = _word;

NSString* const MINION_MONSTER_IMAGE = @"icon.png";

- (NSString*)description {
     NSString* description = [NSString stringWithFormat:@"xPos: %@, yPos: %@, word: %@",[NSNumber numberWithFloat:self.position.x],[NSNumber numberWithFloat:self.position.y],self.word];
    return description;
}

- (Monster*)createWithX:(int)x y:(int)y word:(NSString*)word {
    if (self = [super initWithFile:MINION_MONSTER_IMAGE]) {
        self.position = ccp(x,y);
        self.word = word;
    }
    
    [self moveRandomly];
    return self;
}

- (CGPoint)moveX:(int)x y:(int)y {
    CGPoint newPosition = CGPointMake(self.position.x - x, self.position.y - y);
    self.position = newPosition;
    return self.position;
}

- (void)moveRandomly {

}

- (void)die {
    
}

@end
