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
    
    networkCenter = [[MNCenter alloc] init];
    
    connections.text = [NSString stringWithFormat:@"Your name: %@\n\nSearching for devices...", [networkCenter deviceName]];
    [self.view addSubview:connections];
    
    [networkCenter startWithDeviceAvailable:^(Device *device) {
        NSLog(@"device became available");
        connections.text = [NSString stringWithFormat:@"Your name: %@\n\nNearby devices:\n", [networkCenter deviceName]];
        for (Device *d in [networkCenter sortedDevices]) {
            // no harm should come from attempting to connect to already-connected devices
            [d connectAndReplyTo:self selector:@selector(connected) errorSelector:@selector(notConnected)];
            connections.text = [connections.text stringByAppendingFormat:@"%@ - %@\n", d.deviceName, [d statusString]];
        }
    } deviceUnavailable:^(Device *device) {
        NSLog(@"device became unavailable");
        connections.text = [NSString stringWithFormat:@"Your name: %@\n\nNearby devices:\n", [networkCenter deviceName]];
        for (Device *d in [networkCenter sortedDevices]) {
            connections.text = [connections.text stringByAppendingFormat:@"%@\n", d.deviceName];
        }
    }];
    
    [networkCenter.sessionManager setOnStateChange:^{
        [self connected];
    }];
    
    networkCenter.receiveMessageCallback = ^(NSString *msg, Device *d) {
        messages.text = [self appendMessage:[NSString stringWithFormat:@"%@: %@", d.deviceName, msg] toText:messages.text];
    };
    
    //[connections release];
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

- (void)connected {
    connections.text = [NSString stringWithFormat:@"Your name: %@\n\nNearby devices:\n", [networkCenter deviceName]];
    for (Device *d in [networkCenter sortedDevices]) {
        connections.text = [connections.text stringByAppendingFormat:@"%@ - %@\n", d.deviceName, [d statusString]];
    }
}

- (void)notConnected {
    // ...
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [networkCenter.sessionManager sendStringToAllPeers:textField.text callback:^(NSError *err) {
        NSLog(@"callback");
    }];
    
    messages.text = [self appendMessage:[NSString stringWithFormat:@"%@: %@", [[UIDevice currentDevice] name], textField.text] toText:messages.text];
    
    textField.text = @"";
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
