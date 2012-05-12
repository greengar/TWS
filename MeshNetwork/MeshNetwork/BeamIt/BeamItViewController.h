/*
 
 File: BeamItViewController.h
 Abstract: Main View Controller. Responsible for updating the screen when the devices list changes.
		   Also responsible for properly handling the selection of an item in the list.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import <AddressBookUI/AddressBookUI.h>
#import "AudioToolbox/AudioToolbox.h"
#import "SessionManager.h"
#import "DataHandler.h"
#import "DataProvider.h"
#import "DevicesManager.h"

@interface BeamItViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	SessionManager *sessionManager;
	DataHandler *dataHandler;
	ABRecordID myContactID;
	DevicesManager *devicesManager;

	UITableView *devicesTable;
	UILabel *myContactLabel;
	UILabel *myDeviceNameLabel;
	BOOL myContactMustBeDefined;

	SystemSoundID availableSound;
	SystemSoundID unavailableSound;
	
	UIImageView *backgroundImage;
	UIImageView *backgroundImageHighlighted;
}

@property (nonatomic, retain) IBOutlet UITableView *devicesTable;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageHighlighted;
@property (nonatomic, retain) IBOutlet UILabel *myContactLabel;
@property (nonatomic, retain) IBOutlet UILabel *myDeviceNameLabel;

- (ABRecordID)getMyContactID;

@end

