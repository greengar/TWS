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
@synthesize reachedPlayer;
@synthesize walkAction = _walkAction;

NSString* const MINION_MONSTER_IMAGE = @"small-dragon.png";

- (NSString*)description {
     NSString* description = [NSString stringWithFormat:@"xPos: %@, yPos: %@, word: %@",[NSNumber numberWithFloat:self.position.x],[NSNumber numberWithFloat:self.position.y],self.word];
    return description;
}

+(CCAnimation *) animationFromTemplate:(NSString *)animationTemplate andFrames:(NSString *)frames {
    // Look for animation. If doesn't exist, create it.
    NSString *animationName = [NSString stringWithFormat:animationTemplate, @"animation"];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    if (!animation) {
        // prepare set of frame names
        animation = [CCAnimation animation];
        NSArray *frameNumbers = [frames componentsSeparatedByString:@","];
        NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:[frameNumbers count]];
        for (NSString *num in frameNumbers) {
            [animation addFrameWithFilename:[NSString stringWithFormat:animationTemplate, num]];
            //NSLog(@"Adding frame: %@", [frameNames lastObject]);
            
        }
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animationName];
    }
    return animation;
}


- (Monster*)createWithWord:(NSString*)word animationTemplate:(NSString *)animationTemplate frames:(NSString *)frames {
    
    CCAnimation *animation = [Monster animationFromTemplate:animationTemplate andFrames:frames];
    NSAssert2(animation, @"Could not create animation for template %@ and frames %@", animationTemplate, frames);
    
    
    
    
    if (self = [super initWithSpriteFrame:[animation.frames lastObject] ]) {
        self.word = word;
        self.points = INITIAL_POINTS;
        self.reachedPlayer = NO;
        
        CCLabelTTF *name = [CCLabelTTF labelWithString:self.word fontName:@"Arial-BoldMT" fontSize:15];
        [name setAnchorPoint:ccp(0.5, 1)];
        [self addChild:name];
        name.position = ccp(self.boundingBox.size.width / 2,0 );
        self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:2 animation:animation restoreOriginalFrame:NO]];
        [self runAction:self.walkAction];
    }
    
    return self;
}

- (void)die {
    CCParticleSystemQuad *explosion = [CCParticleSystemQuad particleWithFile:@"MonsterPlosion.plist"];
    [self.parent addChild:explosion];
    explosion.position = self.position;
    
    [explosion runAction:[CCSequence actions:
                          //[CCScaleTo actionWithDuration:1 scale:0.1],
                          [CCDelayTime actionWithDuration:1],
                          [CCCallBlock actionWithBlock:^{
        [explosion removeFromParentAndCleanup:YES];
    }],
                          nil]];

    [self removeFromParentAndCleanup:YES];
    
}

-(void) marchTo:(CGPoint)destination {
    CCFiniteTimeAction *marchAction = [CCMoveTo actionWithDuration:MONSTER_MOVE_DURATION_SECONDS position:destination];
    CCFiniteTimeAction *marchCompleteAction = [CCCallBlock actionWithBlock:^{
        self.reachedPlayer = YES;
    }];
    [self runAction:[CCSequence actions:marchAction, marchCompleteAction, nil]];
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

- (void)dealloc
{
    self.word = nil;
    self.walkAction = nil;
    [super dealloc];
}

@end
