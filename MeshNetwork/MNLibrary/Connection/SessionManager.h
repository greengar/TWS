/*
 
 File: SessionManager.h
 Abstract: Delegate for the session and sends notifications when it changes.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import <GameKit/GameKit.h>
#import "DataHandler.h"
#import "DevicesManager.h"
#import "Device.h"

#define MESH_NETWORK_GLOBAL_SESSION_ID @"meshnetwork"

#define NOTIFICATION_DEVICE_AVAILABLE @"notif_device_available"
#define NOTIFICATION_DEVICE_UNAVAILABLE @"notif_device_unavailable"
#define NOTIFICATION_DEVICE_CONNECTED @"notif_device_connected"
#define NOTIFICATION_DEVICE_CONNECTION_FAILED @"notif_device_connection_failed"
#define NOTIFICATION_DEVICE_DISCONNECTED @"notif_device_disconnected"

#define DEVICE_KEY @"Device"

typedef void(^BasicBlock)(void);

@interface SessionManager : NSObject<GKSessionDelegate> {
	DevicesManager *devicesManager;
}

@property (nonatomic, readonly) GKSession *meshSession;
@property (nonatomic, copy) BasicBlock onStateChange;

- (id)initWithDataHandler:(DataHandler *)handler devicesManager:(DevicesManager *)manager;
- (void)start;
- (void)sendStringToAllPeers:(NSString *)string callback:(ErrorBlock)callback;
- (void)stop;

@end
