//
//  ARLRadarViewController.m
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLRadarViewController.h"
#import "ASIHTTPRequest.h"

@interface ARLRadarViewController() {
    int degree;
}
@property(nonatomic, strong) NSTimer* timer;
@property(nonatomic, strong) CLHeading* currentHeading;
@property(nonatomic, strong) CLLocation* currentLocation;
- (void) tick;
- (void) updateUI;
@end

@implementation ARLRadarViewController
@synthesize sweeper, timer, locationManager, currentLocation, currentHeading;

- (void)viewDidLoad {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.headingFilter = kCLHeadingFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
    [self.locationManager startUpdatingHeading];
	[self.locationManager startUpdatingLocation];
	
        
    [self tick];
}

- (void) tick {
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://bozar.dyndns.org:1337/players"]];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    }];
    
    [request setFailedBlock:^{
        NSLog(@"fail!");
    }];
    
    [request startAsynchronous];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	if (newHeading.headingAccuracy > 0) {
		self.currentHeading = newHeading;
        [self updateUI];
	}
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    self.currentLocation = newLocation;
    NSLog(@"Location: %@", [newLocation description]);
    
}

- (void)locationManager:(CLLocationManager *)manager
           didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error description]);
}

- (void) updateUI {
    NSLog(@"currentHeading: %@", currentHeading);
    //NSLog(@"currentLocation: %@", currentLocation);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)close:(id)sender {
    [self.timer invalidate];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
