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

@synthesize onStateChange;

- (id)initWithDataHandler:(DataHandler *)handler devicesManager:(DevicesManager *)manager {
	self = [super init];
	
	if (self) {
		devicesManager = manager;

		meshSession = [[GKSession alloc] initWithSessionID:MESH_NETWORK_GLOBAL_SESSION_ID displayName:nil sessionMode:GKSessionModePeer];
		meshSession.delegate = self;
		[meshSession setDataReceiveHandler:handler withContext:nil];
	}
	
	return self;
}

- (void)start {
	meshSession.available = YES;
}

- (void)stop {
    meshSession.available = NO;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	Device *currentDevice = [devicesManager deviceWithID:peerID];
	
	// Instead of trying to respond to the event directly, it delegates the events.
	// The availability is checked by the main ViewController.
	// The connection is verified by each Device.
	switch (state) {
		case GKPeerStateConnected:
			if (currentDevice) {
                currentDevice.connected = YES;
                
                // set all disconnected = NO, connecting = NO
                for (Device *d in [devicesManager sortedDevices]) {
                    d.disconnected = NO;
                    d.connecting = NO;
                }
                
                // set some connecting = YES
                NSArray *peerArray = [session peersWithConnectionState:GKPeerStateConnecting];
                for (NSString *p in peerArray) {
                    Device *d = [devicesManager deviceWithID:p];
                    d.connecting = YES;
                    NSLog(@"state of '%@' : connecting", d.deviceName);
                }
                
                // set some disconnected = YES
                NSArray *disconnectedPeers = [session peersWithConnectionState:GKPeerStateDisconnected];
                for (NSString *p in disconnectedPeers) {
                    Device *d = [devicesManager deviceWithID:p];
                    d.disconnected = YES;
                    NSLog(@"state of '%@' : disconnected", d.deviceName);
                }
                
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTED object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
		case GKPeerStateConnecting: // handle this together with 'Available'
		case GKPeerStateAvailable:
			if (!currentDevice) {
				currentDevice = [self addDevice:peerID];
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_AVAILABLE object:nil userInfo:[self getDeviceInfo:currentDevice]];
                
                // automatically connect to all available peers!
                [currentDevice connectAndReplyTo:nil selector:NULL errorSelector:NULL];
			}
            
            // set all connecting = NO, available = NO
            for (Device *d in [devicesManager sortedDevices]) {
                d.connecting = NO;
                d.available = NO;
            }
            
            // set some connecting = YES
            NSArray *peerArray = [session peersWithConnectionState:GKPeerStateConnecting];
            for (NSString *p in peerArray) {
                Device *d = [devicesManager deviceWithID:p];
                d.connecting = YES;
                NSLog(@"state of '%@' : connecting", d.deviceName);
            }
            
            // set some available = YES
            peerArray = [session peersWithConnectionState:GKPeerStateAvailable];
            for (NSString *p in peerArray) {
                Device *d = [devicesManager deviceWithID:p];
                d.available = YES;
                NSLog(@"state of '%@' : available", d.deviceName);
            }
            
			break;
		case GKPeerStateUnavailable:
			if (currentDevice) {
                if (currentDevice.unavailable) {
                    NSLog(@"%@ already unavailable", currentDevice.deviceName);
                } else {
                    currentDevice.unavailable = YES;
                }
				[currentDevice retain];
				[self removeDevice:currentDevice];
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_UNAVAILABLE object:nil userInfo:[self getDeviceInfo:currentDevice]];
				[currentDevice release];
			}
			break;
		case GKPeerStateDisconnected:
			if (currentDevice) {
                currentDevice.disconnected = YES;
                
                // set all connected = NO
                for (Device *d in [devicesManager sortedDevices]) {
                    d.connected = NO;
                }
                
                // set some connected = YES
                NSArray *connectedPeers = [session peersWithConnectionState:GKPeerStateConnected];
                for (NSString *p in connectedPeers) {
                    Device *d = [devicesManager deviceWithID:p];
                    d.connected = YES;
                    NSLog(@"state of '%@' : connected", d.deviceName);
                }
                
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_DISCONNECTED object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
	}
    
    if (onStateChange) {
        onStateChange();
    }
}

- (Device *)addDevice:(NSString *)peerID {
	Device *device = [[Device alloc] initWithSession:meshSession peer:peerID];
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
	[meshSession acceptConnectionFromPeer:peerID error:nil];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	Device *currentDevice = [devicesManager deviceWithID:peerID];
	
	// Does the same thing as the didStateChange method. It tells a Device that the connection failed.
	if (currentDevice) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTION_FAILED object:nil userInfo:[self getDeviceInfo:currentDevice]];
	}
}

- (void)sendStringToAllPeers:(NSString *)string callback:(ErrorBlock)callback
{
    // from DataHandler:
    
//    [self showProcess:[NSString stringWithFormat:NSLocalizedString(@"WAITING_FOR_ACCEPTANCE_PROCESS", @"Waiting for acceptance"), currentStateRelatedDevice.deviceName]];
//	NSString *strToSend = [NSString stringWithFormat:@"%@%@", BEAM_IT_REQUESTING_PERMISSION_TO_SEND, [dataProvider getLabelOfDataToSend]];
//	[currentStateRelatedDevice sendData:[self dataFromString:strToSend] error:nil];
    
    NSError *error = nil;
    BOOL success = [meshSession sendDataToAllPeers:[string dataUsingEncoding:NSUTF8StringEncoding] withDataMode:GKSendDataReliable error:&error];
    if (!success) {
        callback(error);
    }
    // TODO: provide real async callback
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
