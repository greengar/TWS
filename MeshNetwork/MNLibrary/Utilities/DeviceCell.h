/*
 
 File: DeviceCell.h
 Abstract: A specific cell that stores a reference for a device.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "Device.h"

@interface DeviceCell : UITableViewCell {
	Device *device;
}

@property (nonatomic, retain) Device *device;

@end
