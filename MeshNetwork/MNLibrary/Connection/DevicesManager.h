/*
 
 File: DevicesManager.h
 Abstract: Contains a list of devices.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "Device.h"

@interface DevicesManager : NSObject {
	NSMutableArray *devices;
}

- (void)addDevice:(Device *)device;
- (void)removeDevice:(Device *)device;
- (Device *)deviceWithID:(NSString *)peerID;

@property (nonatomic, readonly) NSArray *sortedDevices;

@end
