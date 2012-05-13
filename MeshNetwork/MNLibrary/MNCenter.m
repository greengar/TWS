//
//  MNCenter.m
//  MeshNetwork
//
//  Created by Elliot Michael Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNCenter.h"

@implementation MNCenter

@synthesize sessionManager, deviceAvailableBlock, deviceUnavailableBlock, deviceConnectedCallback, deviceDisconnectedCallback, receiveMessageCallback;

- (id)init {
    if ((self = [super init])) {
        devicesManager = [[DevicesManager alloc] init];
        dataHandler = [[DataHandler alloc] initWithDataProvider:self devicesManager:devicesManager];
        sessionManager = [[SessionManager alloc] initWithDataHandler:dataHandler devicesManager:devicesManager];
    }
    return self;
}

- (void)receiveString:(NSString *)str fromDevice:(Device *)d {
    if (receiveMessageCallback) {
        receiveMessageCallback(str, d);
    }
}

- (void)startWithDeviceAvailable:(DeviceBlock)ab deviceUnavailable:(DeviceBlock)ub
{
    self.deviceAvailableBlock = ab;
    self.deviceUnavailableBlock = ub;
    
    // Notifications being called from the SessionManager when devices become available/unavailable
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAvailableNotification:) name:NOTIFICATION_DEVICE_AVAILABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceUnavailableNotification:) name:NOTIFICATION_DEVICE_UNAVAILABLE object:nil];
    
    [self start];
}

- (void)start {
    [sessionManager start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnectedNotification:) name:NOTIFICATION_DEVICE_CONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDisconnectedNotification:) name:NOTIFICATION_DEVICE_DISCONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
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

- (void)sendDataToAllPeers:(NSData *)data callback:(ErrorBlock)callback
{
    NSError *error = nil;
    BOOL success = [sessionManager.meshSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
    if (!success) {
        callback(error);
    }
    // TODO: provide real async callback
}

- (NSArray *)sortedDevices {
    return devicesManager.sortedDevices;
}

- (NSObject<DataProvider> *)createSpecificDataProvider {
	return nil;
}

- (void)deviceAvailableNotification:(NSNotification *)notification
{
    // TODO: pass the device that became available
    deviceAvailableBlock(nil);
}

- (void)deviceUnavailableNotification:(NSNotification *)notification
{
    // TODO: pass the device that became available
    deviceUnavailableBlock(nil);
}

- (void)applicationWillResignActiveNotification:(NSNotification *)n {
    [sessionManager stop];
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)n
{
    if ((deviceAvailableBlock && deviceUnavailableBlock) ||
        (deviceConnectedCallback && deviceDisconnectedCallback)) {
        [sessionManager start];
    }
}

- (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

@end
