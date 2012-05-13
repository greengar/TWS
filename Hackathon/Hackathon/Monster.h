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
@property int points;

- (Monster*)createWithX:(int)x y:(int)y word:(NSString*)word;
- (void)die;

-(BOOL) attackWithWord:(NSString *)word; // returns YES if monster dead
-(void) marchTo: (CGPoint) destination;
-(void) decreasePointValue;

@end
