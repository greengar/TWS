/*
 
 File: Device.h
 Abstract: Represents a phisical device.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import <GameKit/GameKit.h>

@interface Device : NSObject {
	GKSession *session;
	
	NSString *peerID;
	NSString *deviceName;
	
	id delegateToCallAboutConnection;
	SEL selectorToPerformWhenConnectionWasStablished;
	SEL selectorToPerformWhenConnectionWasNotStablished;
}

- (id)initWithSession:(GKSession *)openSession peer:(NSString *)peerID;

- (void)connectAndReplyTo:(id)delegate selector:(SEL)connectionStablishedConnection errorSelector:(SEL)connectionNotStablishedConnection;
- (void)disconnect;
- (void)cancelConnection;

- (BOOL)isConnected;
- (NSString *)statusString;

- (BOOL)sendData:(NSData *)data error:(NSError **)error;

@property (nonatomic, readonly) NSString *peerID;
@property (nonatomic, readonly) NSString *deviceName;

@property (nonatomic) BOOL available;
@property (nonatomic) BOOL unavailable;
@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL disconnected;
@property (nonatomic) BOOL connecting;

@end
