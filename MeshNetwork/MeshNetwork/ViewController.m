//
//  ViewController.m
//  MeshNetwork
//
//  Created by Elliot Michael Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    networkCenter = [[MNCenter alloc] init];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
    label.numberOfLines = 10;
    label.text = [NSString stringWithFormat:@"Your name: %@\n\nSearching for devices...", [networkCenter deviceName]];
    [self.view addSubview:label];
    
    [networkCenter startWithDeviceAvailable:^(Device *device) {
        NSLog(@"device became available");
        label.text = [NSString stringWithFormat:@"Your name: %@\n\nNearby devices:\n", [networkCenter deviceName]];
        for (Device *d in [networkCenter sortedDevices]) {
            // no harm should come from attempting to connect to already-connected devices
            [d connectAndReplyTo:self selector:@selector(connected) errorSelector:@selector(notConnected)];
            label.text = [label.text stringByAppendingFormat:@"%@ - %@\n", d.deviceName, [d statusString]];
        }
    } deviceUnavailable:^(Device *device) {
        NSLog(@"device became unavailable");
        label.text = [NSString stringWithFormat:@"Your name: %@\n\nNearby devices:\n", [networkCenter deviceName]];
        for (Device *d in [networkCenter sortedDevices]) {
            label.text = [label.text stringByAppendingFormat:@"%@\n", d.deviceName];
        }
    }];
    
    //[label release];
}

- (void)connected {
    label.text = [NSString stringWithFormat:@"Your name: %@\n\nNearby devices:\n", [networkCenter deviceName]];
    for (Device *d in [networkCenter sortedDevices]) {
        label.text = [label.text stringByAppendingFormat:@"%@ - %@\n", d.deviceName, [d statusString]];
    }
}

- (void)notConnected {
    // ...
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
