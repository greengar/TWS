/*
 
 File: ContactDataProvider.m
 Abstract: Implementation of the DataProvider specifically for beaming contacts.
 Version: 1.0
  
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "ContactDataProvider.h"

@implementation ContactDataProvider

- (id)initWithMainViewController:(BeamItViewController *)viewController {
	self = [super init];
	
	if (self) {
		mainViewController = viewController;
	}
	
	return self;
}

- (void)prepareDataAndReplyTo:(id)delegate selector:(SEL)dataPreparedSelector {
	delegateToCall = delegate;
	selectorToCall = dataPreparedSelector;
	
	// The use may choose between send its own contact or any other contact from the address book
	UIActionSheet *contactTypeActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
														  cancelButtonTitle:@"Cancel" 
													 destructiveButtonTitle:nil 
														  otherButtonTitles:@"My Contact", @"Another Contact", nil];
	[contactTypeActionSheet showInView:mainViewController.view];
	[contactTypeActionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self sendMyContact];
	} else if (buttonIndex == 1) {
		// Displays the AddressBook picker dialog that allows the user to select a contact
		ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
		peoplePicker.peoplePickerDelegate = self;
		[mainViewController presentModalViewController:peoplePicker animated:YES];
		[peoplePicker release];
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	if ([mainViewController getMyContactID] == 0) {
		UIControl *firstButtom = [[actionSheet subviews] objectAtIndex:0];
		firstButtom.enabled = NO;
	}
}

- (void)sendMyContact {
	[mainViewController dismissModalViewControllerAnimated:YES];
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [mainViewController getMyContactID]);
	[self sendContact:person];
	CFRelease(addressBook);
}

- (void)sendContact:(ABRecordRef)person {
	// Serializes the contact
	contactData = [[ABRecordSerializer personToData:person] retain];
	
	// Returns serialized contact and name to the DataHandler
	contactLabel = (NSString*)ABRecordCopyCompositeName(person);
	if (delegateToCall && [delegateToCall respondsToSelector:selectorToCall])
		[delegateToCall performSelector:selectorToCall];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [mainViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	[mainViewController dismissModalViewControllerAnimated:YES];
	[self sendContact:person];
	
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

- (NSString *)getLabelOfDataToSend {
	return contactLabel;
}

- (NSData *)getDataToSend {
	return contactData;
}

- (BOOL)storeData:(NSData*)data andReplyTo:(id)delegate selector:(SEL)selector {
	// Deserializes data received and create a new contact
	ABRecordRef newPerson = [ABRecordSerializer createPersonFromData:data];
	
	if(newPerson != NULL) {
		delegateToCall = delegate;
		selectorToCall = selector;
		
		ABUnknownPersonViewController *addPersonViewController = [[ABUnknownPersonViewController alloc] init];
		addPersonViewController.unknownPersonViewDelegate = self;
		addPersonViewController.displayedPerson = newPerson;
		addPersonViewController.allowsActions = NO;
		addPersonViewController.allowsAddingToAddressBook = YES;
		
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addPersonViewController];
		addPersonViewController.navigationItem.title = @"Contact received";
		UIBarButtonItem *cancelButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																					   target:self action:@selector(cancelContact:)];
		addPersonViewController.navigationItem.leftBarButtonItem = cancelButton;
		[mainViewController presentModalViewController:navController animated:NO];
		
		[cancelButton release];
		[addPersonViewController release];
		[navController release];
		CFRelease(newPerson);
		
		return YES;
	} else {
		return NO;
	}
}

- (void)cancelContact:(id)sender {
	[mainViewController dismissModalViewControllerAnimated:NO];
	[delegateToCall performSelector:selectorToCall];	
}

- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person {
	[mainViewController dismissModalViewControllerAnimated:NO];
	[delegateToCall performSelector:selectorToCall];
}

@end
