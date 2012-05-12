/*
 
 File: SessionManager.m
 Abstract: Delegate for the session and sends notifications when it changes.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "SessionManager.h"

@interface SessionManager ()

- (Device *)addDevice:(NSString *)peerID;
- (void)removeDevice:(Device *)device;
- (NSDictionary *)getDeviceInfo:(Device *)device;

@end


@implementation SessionManager

- (id)initWithDataHandler:(DataHandler *)handler devicesManager:(DevicesManager *)manager {
	self = [super init];
	
	if (self) {
		devicesManager = manager;

		beamItSession = [[GKSession alloc] initWithSessionID:MESH_NETWORK_GLOBAL_SESSION_ID displayName:nil sessionMode:GKSessionModePeer];
		beamItSession.delegate = self;
		[beamItSession setDataReceiveHandler:handler withContext:nil];
	}
	
	return self;
}

- (void)start {
	beamItSession.available = YES;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	Device *currentDevice = [devicesManager deviceWithID:peerID];
	
	// Instead of trying to respond to the event directly, it delegates the events.
	// The availability is checked by the main ViewController.
	// The connection is verified by each Device.
	switch (state) {
		case GKPeerStateConnected:
			if (currentDevice) {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTED object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
		case GKPeerStateConnecting:
		case GKPeerStateAvailable:
			if (!currentDevice) {
				currentDevice = [self addDevice:peerID];
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_AVAILABLE object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
		case GKPeerStateUnavailable:
			if (currentDevice) {
				[currentDevice retain];
				[self removeDevice:currentDevice];
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_UNAVAILABLE object:nil userInfo:[self getDeviceInfo:currentDevice]];
				[currentDevice release];
			}
			break;
		case GKPeerStateDisconnected:
			if (currentDevice) {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_DISCONNECTED object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
	}
}

- (Device *)addDevice:(NSString *)peerID {
	Device *device = [[Device alloc] initWithSession:beamItSession peer:peerID];
	[devicesManager addDevice:device];
	[device release];
	
	return device;
}

- (void)removeDevice:(Device *)device {
	[devicesManager removeDevice:device];
}

- (NSDictionary *)getDeviceInfo:(Device *)device {
	return [NSDictionary dictionaryWithObject:device forKey:DEVICE_KEY];
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	[beamItSession acceptConnectionFromPeer:peerID error:nil];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	Device *currentDevice = [devicesManager deviceWithID:peerID];
	
	// Does the same thing as the didStateChange method. It tells a Device that the connection failed.
	if (currentDevice) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTION_FAILED object:nil userInfo:[self getDeviceInfo:currentDevice]];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	exit(0);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BLUETOOTH_ERROR_TITLE", @"Title for the error dialog.")
														message:NSLocalizedString(@"BLUETOOTH_ERROR", @"Wasn't able to make bluetooth available")
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	
	[errorView show];
	[errorView release];
}

@end
