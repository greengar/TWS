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
//typedef void(^MessageBlock)(NSString *, Device *);
typedef void(^DataBlock)(NSData *, Device *);

@interface MNCenter : NSObject <DataProvider>
{
	DataHandler *dataHandler;
	DevicesManager *devicesManager;
    
    DeviceBlock deviceAvailableBlock;
    DeviceBlock deviceUnavailableBlock;
}

@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, copy) DeviceBlock deviceAvailableBlock;
@property (nonatomic, copy) DeviceBlock deviceUnavailableBlock;
@property (nonatomic, copy) DeviceBlock deviceConnectedCallback;
@property (nonatomic, copy) DeviceBlock deviceDisconnectedCallback;
@property (nonatomic, copy) DataBlock dataReceivedCallback;

- (id)initWithSessionID:(NSString *)sessionID;
- (void)startWithDeviceAvailable:(DeviceBlock)ab deviceUnavailable:(DeviceBlock)ub;
- (void)start;
- (void)sendDataToAllPeers:(NSData *)data callback:(ErrorBlock)callback;
- (BOOL)sendData:(NSData *)data toPeerID:(NSString *)peerID;
- (NSArray *)sortedDevices;
- (NSString *)deviceName;

@end
