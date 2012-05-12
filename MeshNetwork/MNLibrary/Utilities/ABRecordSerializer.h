/*
 
 File: ABRecordSerializer.h
 Abstract: Creates a serializable representation of ABRecordRef
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import <AddressBookUI/AddressBookUI.h>

@interface ABRecordSerializer : NSObject {

}

+ (NSData *)personToData:(ABRecordRef)person;
+ (ABRecordRef)createPersonFromData:(NSData *)data;
+ (ABMutableMultiValueRef)multiValuePropertyFromDictionary:(NSDictionary*)dictionary;
+ (NSDictionary*)dictionaryFromMultiValueProperty:(ABMutableMultiValueRef)prop;
+ (void)copyProperty:(ABPropertyID)prop ofPerson:(ABRecordRef)person toDictionary:(NSMutableDictionary*)dict;

@end
