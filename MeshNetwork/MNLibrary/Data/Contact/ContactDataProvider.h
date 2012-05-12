/*
 
 File: ContactDataProvider.h
 Abstract: Implementation of the DataProvider specifically for beaming contacts.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import <AddressBookUI/AddressBookUI.h>
#import "ABRecordSerializer.h"
#import "DataProvider.h"
#import "BeamItViewController.h"

@interface ContactDataProvider : NSObject<DataProvider, ABPeoplePickerNavigationControllerDelegate,  ABUnknownPersonViewControllerDelegate, UIActionSheetDelegate> {
	id delegateToCall;
	SEL selectorToCall;
	
	BeamItViewController *mainViewController;
	
	NSString *contactLabel;
	NSData *contactData;
}

- (id)initWithMainViewController:(BeamItViewController *)viewController;
- (void)sendContact:(ABRecordRef)recordRef;
- (void)sendMyContact;

@end
