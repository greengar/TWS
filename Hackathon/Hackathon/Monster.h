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

@property int x; // x = 0 is left
@property int y; // y = 0 is bottom
@property (nonatomic, retain) NSString* word;

- (void)create:(int)x:(int)y:(NSString*)word;
- (int)moveForward:(int)amount;
- (void)die;

@end
