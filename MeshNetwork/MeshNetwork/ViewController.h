//
//  ViewController.h
//  MeshNetwork
//
//  Created by Elliot Michael Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNCenter.h"

@interface ViewController : UIViewController <UITextFieldDelegate> {
    MNCenter *networkCenter;
    NSMutableArray *connectedDevices;
    IBOutlet UILabel *connections;
    IBOutlet UILabel *messages;
}

@end
