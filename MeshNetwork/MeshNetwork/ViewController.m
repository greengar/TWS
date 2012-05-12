//
//  ViewController.m
//  MeshNetwork
//
//  Created by Elliot Michael Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MNCenter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    MNCenter *networkCenter = [[MNCenter alloc] init];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
    label.numberOfLines = 10;
    label.text = [NSString stringWithFormat:@"Your name: %@\n\nSearching for devices...", [networkCenter deviceName]];
    [self.view addSubview:label];
    
    [networkCenter startWithDeviceAvailable:^(Device *device) {
        NSLog(@"device became available");
        label.text = [NSString stringWithFormat:@"Your name: %@\n\nNearby devices:\n", [networkCenter deviceName]];
        for (Device *d in [networkCenter sortedDevices]) {
            label.text = [label.text stringByAppendingFormat:@"%@\n", d.deviceName];
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
