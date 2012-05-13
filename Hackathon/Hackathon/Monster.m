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
@synthesize points = _points;

NSString* const MINION_MONSTER_IMAGE = @"icon.png";

- (NSString*)description {
     NSString* description = [NSString stringWithFormat:@"xPos: %@, yPos: %@, word: %@",[NSNumber numberWithFloat:self.position.x],[NSNumber numberWithFloat:self.position.y],self.word];
    return description;
}

- (Monster*)createWithX:(int)x y:(int)y word:(NSString*)word {
    if (self = [super initWithFile:MINION_MONSTER_IMAGE]) {
        self.position = ccp(x,y);
        self.word = word;
        self.points = INITIAL_POINTS;
        
        CCLabelTTF *name = [CCLabelTTF labelWithString:self.word fontName:@"Arial-BoldMT" fontSize:15];
        [name setAnchorPoint:ccp(0.5, 1)];
        [self addChild:name];
        name.position = ccp(self.boundingBox.size.width / 2,0 );
        
    }
    
    return self;
}

- (void)die {
    [self runAction:[CCSequence actions:
                     [CCScaleTo actionWithDuration:1 scale:0.1],
                     [CCCallBlock actionWithBlock:^{
        [self removeFromParentAndCleanup:YES];
    }],
                     nil]];
}

-(void) marchTo:(CGPoint)destination {
    CCFiniteTimeAction *marchAction = [CCMoveTo actionWithDuration:MONSTER_MOVE_DURATION_SECONDS position:destination];
    [self runAction:marchAction];
}

-(BOOL) attackWithWord:(NSString *)attackWord {
    BOOL equal = [attackWord isEqualToString:self.word];
    //NSLog(@"Equal: %i  %@ <-> %@", self.word, attackWord);
    //NSLog(@"Length: %i <-> %i", [self.word length], [attackWord length]);
    return equal;
}

-(void) decreasePointValue {
    self.points = self.points - POINT_DECREASE_VALUE;
}

@end
