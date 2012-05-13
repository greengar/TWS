//
//  MNCenter.m
//  MeshNetwork
//
//  Created by Elliot Michael Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNCenter.h"

@implementation MNCenter

@synthesize sessionManager, deviceConnectedCallback, deviceDisconnectedCallback, dataReceivedCallback;

- (id)init {
    NSLog(@"warning: using SessionID: mesh-network");
    return [self initWithSessionID:@"mesh-network"];
}

- (id)initWithSessionID:(NSString *)sessionID {
    if ((self = [super init])) {
        devicesManager = [[DevicesManager alloc] init];
        dataHandler = [[DataHandler alloc] initWithDataProvider:self devicesManager:devicesManager];
        sessionManager = [[SessionManager alloc] initWithDataHandler:dataHandler devicesManager:devicesManager sessionID:sessionID];
    }
    return self;
}

- (void)receiveData:(NSData *)data fromDevice:(Device *)d {
    if (dataReceivedCallback) {
        dataReceivedCallback(data, d);
    }
}

- (void)start {
    [sessionManager start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnectedNotification:) name:NOTIFICATION_DEVICE_CONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDisconnectedNotification:) name:NOTIFICATION_DEVICE_DISCONNECTED object:nil];
    
    ////////////////////////////////////////
    //// START APP TERMINATION HANDLING ////
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillTerminateNotification object:nil];
    
    //// END APP TERMINATION HANDLING ////
    //////////////////////////////////////
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)deviceConnectedNotification:(NSNotification *)notification {
    if (deviceConnectedCallback) {
        deviceConnectedCallback([notification.userInfo objectForKey:DEVICE_KEY]);
    }
}

- (void)deviceDisconnectedNotification:(NSNotification *)notification {
    if (deviceDisconnectedCallback) {
        deviceDisconnectedCallback([notification.userInfo objectForKey:DEVICE_KEY]);
    }
}

- (BOOL)sendDataToAllPeers:(NSData *)data
{
    NSError *error = nil;
    BOOL success = [sessionManager.meshSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
    if (!success) {
        NSLog(@"failed to queue data for sending to all peers");
    }
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    return success;
}

- (BOOL)sendData:(NSData *)data toPeerID:(NSString *)peerID
{
    NSError *error = nil;
    BOOL success = [sessionManager.meshSession sendData:data toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataReliable error:&error];
    if (!success) {
        NSLog(@"failed to queue data for sending to one peer");
    }
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    return success;
}

- (NSArray *)sortedDevices {
    return devicesManager.sortedDevices;
}

//UIApplicationDidEnterBackgroundNotification
//UIApplicationWillTerminateNotification
- (void)applicationWillResignActiveNotification:(NSNotification *)n {
    NSLog(@"-applicationWillResignActiveNotification:");
    [sessionManager stop];
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)n
{
    if (deviceConnectedCallback && deviceDisconnectedCallback) {
        [sessionManager start];
    }
}

- (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

- (NSString *)peerID {
    return sessionManager.meshSession.peerID;
}

@end
