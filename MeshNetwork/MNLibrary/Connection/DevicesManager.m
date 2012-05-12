/*
 
 File: DevicesManager.m
 Abstract: Contains a list of devices.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "DevicesManager.h"

@implementation DevicesManager

- (id)init {
	self = [super init];
	
	if (self)
		devices = [[NSMutableArray alloc] init];

	return self;
}

- (NSArray *)sortedDevices {
	return devices;
}

- (void)addDevice:(Device *)device {
	[devices addObject:device];

	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deviceName" ascending:YES];
	[devices sortUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
	[nameDescriptor release];
}

- (void)removeDevice:(Device *)device {
	if (device) {
		[devices removeObject:device];
	}
}

- (Device *)deviceWithID:(NSString *)peerID {
	for (Device *d in devices) {
		if ([d.peerID isEqual:peerID]) {
			return d;
		}
	}
	
	return nil;
}

- (void)dealloc {
	[devices release];
	[super dealloc];
}

@end
