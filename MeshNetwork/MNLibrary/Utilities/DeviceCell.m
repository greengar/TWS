/*
 
 File: DeviceCell.m
 Abstract: A specific cell that stores a reference for a device.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "DeviceCell.h"

@implementation DeviceCell

@synthesize device;

- (void)setDevice:(Device *)d {
	device = d;
	self.textLabel.text = device.deviceName;
	self.selectionStyle = UITableViewCellSelectionStyleGray;
	self.textLabel.textColor = [UIColor whiteColor];
}

@end
