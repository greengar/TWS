//
//  Monster.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Monster : CCSprite {
    
}

@property (nonatomic, retain) NSString* word;

- (Monster*)createWithX:(int)x y:(int)y word:(NSString*)word;
- (CGPoint)moveX:(int)x y:(int)y;
- (void)moveRandomly;
- (void)die;

-(BOOL) attackWithWord:(NSString *)word; // returns YES if monster dead

@end
