/*
 
 File: BeamItViewController.m
 Abstract: Main View Controller. Responsible for updating the screen when the devices list changes.
							     Also responsible for properly handling the selection of an item in the list.
 Version: 1.0
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "BeamItViewController.h"
#import "ContactDataProvider.h"
#import "Device.h"
#import "DeviceCell.h"

#define MY_CONTACT_ID_PROP @"MY_CONTACT_ID"
#define AVAILABLE_SOUND_FILE_NAME "available"
#define UNAVAILABLE_SOUND_FILE_NAME "unavailable"

@interface BeamItViewController () <ABPeoplePickerNavigationControllerDelegate>

- (void)loadSounds;

- (NSObject<DataProvider> *)createSpecificDataProvider;
- (void)refreshMyContactButton;
- (void)saveMyContactID:(ABRecordID)recordID;
- (IBAction)configureMyContact:(id)sender;

@end

@implementation BeamItViewController

@synthesize devicesTable;
@synthesize backgroundImageHighlighted;
@synthesize myContactLabel;
@synthesize myDeviceNameLabel;

- (void)viewDidLoad {
	devicesManager = [[DevicesManager alloc] init];
	dataHandler = [[DataHandler alloc] initWithDataProvider:[self createSpecificDataProvider] devicesManager:devicesManager];
	sessionManager = [[SessionManager alloc] initWithDataHandler:dataHandler devicesManager:devicesManager];
	
	// Notifications being called from the SessionManager when devices become available/unavailable
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAvailable:) name:NOTIFICATION_DEVICE_AVAILABLE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceUnavailable:) name:NOTIFICATION_DEVICE_UNAVAILABLE object:nil];
	
	[sessionManager start];

	[self loadSounds];
	
	myContactID = [self getMyContactID];
	if (myContactID != 0) {
		[self refreshMyContactButton];
	} else {
		myContactMustBeDefined = YES;
	}
	
	devicesTable.separatorColor = [UIColor grayColor];
	
	myDeviceNameLabel.text = [[UIDevice currentDevice] name];
	
	backgroundImageHighlighted.alpha = 0.6;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:5];
    [UIView setAnimationRepeatCount:9999999];
	[UIView setAnimationRepeatAutoreverses:YES];
    backgroundImageHighlighted.alpha = 0;
    [UIView commitAnimations];
}

- (void)viewDidAppear:(BOOL)animated {
	if (myContactMustBeDefined) {
		UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CHOOSE_CONTACT_TITLE", @"Defining my contact dialog title.")
																   message:NSLocalizedString(@"CHOOSE_CONTACT_PROMPT", @"Defining my contact dialog text.")
																  delegate:nil
														 cancelButtonTitle:NSLocalizedString(@"CHOOSE_CONTACT_OK_BTN", @"Defining my contact dialog button.")
														 otherButtonTitles:nil];
		
		[confirmationView show];
		[confirmationView release];
		
		[self configureMyContact:nil];
		myContactMustBeDefined = NO;
	}
}

- (void)loadSounds {
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	
	CFURLRef availableURL = CFBundleCopyResourceURL(mainBundle, CFSTR(AVAILABLE_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	CFURLRef unavailableURL = CFBundleCopyResourceURL(mainBundle, CFSTR(UNAVAILABLE_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	
	AudioServicesCreateSystemSoundID(availableURL, &availableSound);
	AudioServicesCreateSystemSoundID(unavailableURL, &unavailableSound);
	
	CFRelease(availableURL);
	CFRelease(unavailableURL);
}

- (NSObject<DataProvider> *)createSpecificDataProvider {
	return [[ContactDataProvider alloc] initWithMainViewController:self];
}

- (void)deviceAvailable:(NSNotification *)notification {
	[devicesTable reloadData];
	AudioServicesPlaySystemSound(availableSound);
}

- (void)deviceUnavailable:(NSNotification *)notification {
	[devicesTable reloadData];
	AudioServicesPlaySystemSound(unavailableSound);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [devicesManager.sortedDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DeviceCell";
    
    DeviceCell *cell = (DeviceCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	Device *device = ((Device *) [devicesManager.sortedDevices objectAtIndex:indexPath.row]);
	cell.device = device;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DeviceCell *cell = (DeviceCell *) [tableView cellForRowAtIndexPath:indexPath];
	Device *device = cell.device;
	
	[dataHandler sendToDevice:device];
	
	[devicesTable deselectRowAtIndexPath:indexPath animated:YES];
}

- (ABRecordID)getMyContactID {
	NSString *loadedContactID = [[NSUserDefaults standardUserDefaults] objectForKey:MY_CONTACT_ID_PROP];
	if (loadedContactID)
		return [loadedContactID intValue];
	else
		return 0;
}

- (void)saveMyContactID:(ABRecordID)recordID {
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", recordID] forKey:MY_CONTACT_ID_PROP];
}

- (void)refreshMyContactButton {
	if (myContactID != 0) {
		ABAddressBookRef addressBook = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, myContactID);
		if (person != NULL) {
			NSString *personName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
			myContactLabel.text = personName;
			[personName release];
		} else {
			// My contact was removed, reset settings
			myContactID = 0;
			[self saveMyContactID:myContactID];
			myContactMustBeDefined = YES;
		}
		CFRelease(addressBook);
	}
}

- (IBAction)configureMyContact:(id)sender {
	ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
	peoplePicker.peoplePickerDelegate = self;
	peoplePicker.navigationBar.topItem.title = NSLocalizedString(@"CHOOSE_CONTACT_TITLE", @"Defining my contact title.");
	[self presentModalViewController:peoplePicker animated:YES];
	[peoplePicker release];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
		
	myContactID = ABRecordGetRecordID(person);
	[self refreshMyContactButton];
	[self saveMyContactID:myContactID];
	
	[self dismissModalViewControllerAnimated:YES];
	
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

- (void)dealloc {
	[devicesTable release];
	[dataHandler release];
	[sessionManager release];
	[devicesManager release];
	[myContactLabel release];
	[myDeviceNameLabel release];
	
    [super dealloc];
}

@end
