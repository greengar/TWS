/*
 
 File: DataProvider.h
 Abstract: Provides information about the data to send/store the DataHandler.
           Implement this protocol with the data type you want to beam (eg. Contacts, Pictures, Messages...).
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

@protocol DataProvider

@required

- (void)prepareDataAndReplyTo:(id)delegate selector:(SEL)dataPreparedSelector;
- (NSString *)getLabelOfDataToSend;
- (NSData *)getDataToSend;
- (BOOL)storeData:(NSData*)data andReplyTo:(id)delegate selector:(SEL)selector;

@end