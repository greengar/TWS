//
//  MNCenter.h
//  MeshNetwork
//
//  Created by Elliot Michael Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionManager.h"
#import "DataHandler.h"
#import "DevicesManager.h"

typedef void(^DeviceBlock)(Device *);

@interface MNCenter : NSObject
{
	DataHandler *dataHandler;
	DevicesManager *devicesManager;
    
    DeviceBlock deviceAvailableBlock;
    DeviceBlock deviceUnavailableBlock;
}

@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, copy) DeviceBlock deviceAvailableBlock;
@property (nonatomic, copy) DeviceBlock deviceUnavailableBlock;

- (void)startWithDeviceAvailable:(DeviceBlock)ab deviceUnavailable:(DeviceBlock)ub;
- (NSArray *)sortedDevices;
- (NSString *)deviceName;

@end
