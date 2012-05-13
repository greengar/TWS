//
//  ViewController.m
//  MeshNetwork
//
//  Created by Elliot Michael Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (NSString *)appendMessage:(NSString *)msg toText:(NSString *)txt;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /////////////////////////////////////////
    // 1. instantiate the Mesh Network Center
    
    networkCenter = [[MNCenter alloc] init];
    
    connections.text = [NSString stringWithFormat:@"Your name: %@\n\nSearching for devices...", [networkCenter deviceName]];
    [self.view addSubview:connections];
    
    connectedDevices = [[NSMutableArray alloc] initWithCapacity:10];
    
    /////////////////////////
    // 2. set three callbacks
    
    networkCenter.deviceConnectedCallback = ^(Device *device) {
        [connectedDevices addObject:device];
        
        [self refreshDeviceList];
    };
    
    networkCenter.deviceDisconnectedCallback = ^(Device *device) {
        [connectedDevices removeObject:device];
        
        [self refreshDeviceList];
    };
    
    networkCenter.dataReceivedCallback = ^(NSData *data, Device *device) {
        NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        
        messages.text = [self appendMessage:[NSString stringWithFormat:@"%@: %@", device.deviceName, msg] toText:messages.text];
    };
    
    /////////////////////////////////////
    // 3. start advertising and searching
    
    [networkCenter start];
}

- (NSString *)appendMessage:(NSString *)msg toText:(NSString *)txt {
    NSMutableArray *components = [[[txt componentsSeparatedByString:@"\n"] mutableCopy] autorelease];
    [components addObject:msg];
    
    // limit to 5 lines
    NSString *result = @"";
    int start = components.count-5;
    if (start < 0) start = 0;
    for (int i=start; i<components.count; i++) {
        if ([[components objectAtIndex:i] isEqualToString:@""] == NO) {
            result = [result stringByAppendingFormat:@"%@\n", [components objectAtIndex:i]];
        }
    }
    return result;
}

- (void)refreshDeviceList {
    connections.text = [NSString stringWithFormat:@"Your name: %@\n\nConnected devices:\n", [networkCenter deviceName]];
    
    for (Device *d in connectedDevices) {
        connections.text = [connections.text stringByAppendingFormat:@"%@", d.deviceName];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //////////////////////////////////////
    // 4. send data to all connected peers
    
    [networkCenter sendDataToAllPeers:[textField.text dataUsingEncoding:NSUTF8StringEncoding]];
    
    // data sent is NOT received by myself, so add my own message to my own log
    messages.text = [self appendMessage:[NSString stringWithFormat:@"%@: %@", [[UIDevice currentDevice] name], textField.text] toText:messages.text];
    textField.text = @"";
    
    ////////////////////////////////////
    // 5. send data to one specific peer
    
    if ([connectedDevices count] > 0) {
        BOOL success = [networkCenter sendData:[@"You're #0!" dataUsingEncoding:NSUTF8StringEncoding] toPeerID:[(Device *)[connectedDevices objectAtIndex:0] peerID]];
        if (!success) {
            NSLog(@"unable to queue data for sending");
        }
    }
    
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
