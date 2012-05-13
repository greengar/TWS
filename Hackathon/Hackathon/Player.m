//
//  Player.m
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "Monster.h"

#define TEMPLATE_NAME @"ninja-sway-%@.png"
#define FRAME_ORDER @"2,1,2,3"

#define THROW_TEMPLATE_NAME @"ninja-throw-%@.png"
#define THROW_FRAME_ORDER @"1,2,1"

@implementation Player

@synthesize name = _name;
@synthesize isMe;
@synthesize swayAction = _swayAction;
@synthesize throwAction = _throwAction;

-(Player *) initWithName:(NSString *) playerName {
    CCAnimation *animation = [Monster animationFromTemplate:TEMPLATE_NAME andFrames:FRAME_ORDER];
    NSAssert2(animation, @"Could not create animation for template %@ and frames %@", TEMPLATE_NAME, FRAME_ORDER);

    if (self = [super initWithSpriteFrame:[animation.frames lastObject]]) {
        self.name = playerName;
        self.color = ccRED;
        CCLabelTTF *name = [CCLabelTTF labelWithString:self.name fontName:@"Arial-BoldMT" fontSize:15];
        [name setAnchorPoint:ccp(0, 0)];
        [self addChild:name];
        name.position = ccp(self.boundingBox.size.width,0 );
        self.swayAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:1 animation:animation restoreOriginalFrame:NO]];
        CCAnimation *throwAnim = [Monster animationFromTemplate:THROW_TEMPLATE_NAME andFrames:THROW_FRAME_ORDER];
        self.throwAction = [CCAnimate actionWithAnimation:throwAnim];
        
        [self runAction:self.swayAction];
    
    }
    return self;
}

- (void)dealloc
{
    self.name = nil;
    self.swayAction = nil;
    self.throwAction = nil;
    
    [super dealloc];
}


@end
