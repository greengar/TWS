/*
 
 File: Device.m
 Abstract: Represents a phisical device.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "Device.h"
#import "SessionManager.h"

#define CONNECTION_TIMEOUT 30

@implementation Device

@synthesize deviceName;
@synthesize peerID;
@synthesize available, unavailable, connected, disconnected, connecting;

- (id)initWithSession:(GKSession *)openSession peer:(NSString *)ID {
	self = [super init];
	if (self) {
		session = [openSession retain];
		
		peerID = [ID copy];
		deviceName = [[session displayNameForPeer:peerID] copy];
	}
	return self;
}

- (BOOL)isEqual:(id)object {
	// Basically, compares the peerIDs
	return object && ([object isKindOfClass:[Device class]]) && ([((Device *) object).peerID isEqual:peerID]);
}

//typedef enum {
//    GKPeerStateAvailable,
//    GKPeerStateUnavailable,
//    GKPeerStateConnected,
//    GKPeerStateDisconnected,
//    GKPeerStateConnecting
//} GKPeerConnectionState;

- (void)connectAndReplyTo:(id)delegate selector:(SEL)connectionStablishedConnection errorSelector:(SEL)connectionNotStablishedConnection
{
    if (unavailable) {
        NSLog(@"device unavailable");
        return;
    }
    if (connected) {
        NSLog(@"device already connected");
        return;
    }
    if (connecting) {
        NSLog(@"device connecting");
        return;
    }
    
	// We need to persist this info, because the call to connect is assynchronous.
	delegateToCallAboutConnection = delegate;
	selectorToPerformWhenConnectionWasStablished = connectionStablishedConnection;
	selectorToPerformWhenConnectionWasNotStablished = connectionNotStablishedConnection;
	
	// The SessionManager will be responsible for sending the notification that will be caught here.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerConnectionSuccessfull:) name:NOTIFICATION_DEVICE_CONNECTED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerConnectionFailed:) name:NOTIFICATION_DEVICE_CONNECTION_FAILED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerConnectionFailed:) name:NOTIFICATION_DEVICE_UNAVAILABLE object:nil];

	[session connectToPeer:peerID withTimeout:CONNECTION_TIMEOUT];
}

- (void)triggerConnectionSuccessfull:(NSNotification *)notification {
    
    // TODO: make sure this isn't triggered multiple times for multiple devices
    NSLog(@"triggerConnectionSuccessfull:");
    
	Device *device = [notification.userInfo objectForKey:DEVICE_KEY];
	
	if ([self isEqual:device] && delegateToCallAboutConnection &&
		[delegateToCallAboutConnection respondsToSelector:selectorToPerformWhenConnectionWasStablished]) {
		[delegateToCallAboutConnection performSelector:selectorToPerformWhenConnectionWasStablished];

		delegateToCallAboutConnection = nil;
		selectorToPerformWhenConnectionWasStablished = nil;
		selectorToPerformWhenConnectionWasNotStablished = nil;
	}
}

- (void)triggerConnectionFailed:(NSNotification *)notification {
	Device *device = [notification.userInfo objectForKey:DEVICE_KEY];
	
	if ([self isEqual:device] && delegateToCallAboutConnection &&
		[delegateToCallAboutConnection respondsToSelector:selectorToPerformWhenConnectionWasNotStablished]) {
		[delegateToCallAboutConnection performSelector:selectorToPerformWhenConnectionWasNotStablished];

		delegateToCallAboutConnection = nil;
		selectorToPerformWhenConnectionWasStablished = nil;
		selectorToPerformWhenConnectionWasNotStablished = nil;
	}
}

- (void)disconnect {
	[session disconnectPeerFromAllPeers:peerID];
}

- (void)cancelConnection {
	[session cancelConnectToPeer:peerID];
}

- (BOOL)isConnected {
	// Checks if this device is in the Sessions Connected List
	NSArray *peers = [session peersWithConnectionState:GKPeerStateConnected];
	
	BOOL found = NO;
	
	for (NSString *p in peers) {
		if ([p isEqual:peerID]) {
			found = YES;
			break;
		}
	}
	
	return found;
}

- (NSString *)appendStatus:(NSString *)status toString:(NSString *)string {
    if (string == nil) {
        return status;
    }
    
    return [string stringByAppendingFormat:@", %@", status];
}

- (NSString *)statusString {
    // states are not mutually exclusive
    
    //    GKPeerStateAvailable,
    //    GKPeerStateUnavailable,
    //    GKPeerStateConnected,
    //    GKPeerStateDisconnected,
    //    GKPeerStateConnecting
    NSString *state = nil;
    if (available) {
        state = @"available";
    }
    if (unavailable) {
        state = [self appendStatus:@"unavailable" toString:state];
    }
    if (connected) {
        state = [self appendStatus:@"connected" toString:state];
    }
    if (disconnected) {
        state = [self appendStatus:@"disconnected" toString:state];
    }
    if (connecting) {
        state = [self appendStatus:@"connecting" toString:state];
    }
    return state;
}

- (BOOL)sendData:(NSData *)data error:(NSError **)error {
	return [session sendData:data toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataReliable error:error];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[session release];
	
	[peerID release];
	[deviceName release];
	
    [super dealloc];
}

@end