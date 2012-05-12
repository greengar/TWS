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

@property int x; // x =  is left
@property int y; // y = 0 is top
@property (nonatomic, strong) NSString* word;

- (int)moveForward:(int)amount;
- (void)die;

@end
