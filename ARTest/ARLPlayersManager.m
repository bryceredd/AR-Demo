//
//  ARLPlayers.m
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLPlayersManager.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "ARLPlayer.h"

@interface ARLPlayersManager()
@property (nonatomic, strong) NSMutableArray* delegates;
@property(nonatomic, strong) NSTimer* timer;
- (void) sendLocation;
- (void) requestPlayers;
- (void) tick;
- (void) notifyDelegates;
@end

@implementation ARLPlayersManager
@synthesize delegates, locationManager, timer, currentLocation, currentHeading, players;



+(ARLPlayersManager*) instance {
    static dispatch_once_t onceToken;
    static ARLPlayersManager* _instance;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id) init {
    if((self = [super init])) {
        self.delegates = [NSMutableArray array];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.headingFilter = kCLHeadingFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [self.locationManager startUpdatingHeading];
        [self.locationManager startUpdatingLocation];
        
        
    } return self;
}

- (void) tick {
    
    [self sendLocation];
    [self requestPlayers];
    
    for(ARLPlayer* player in self.players) {
        NSLog(@"player at %f %f away from me", player.angle.floatValue, player.distanceFromMe.floatValue);
    }
}

- (void) sendLocation {
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://bozar.dyndns.org/update"]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    NSNumber* latitude = [NSNumber numberWithFloat:self.currentLocation.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithFloat:self.currentLocation.coordinate.longitude];
    
    NSDictionary* body = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[UIDevice currentDevice] uniqueIdentifier], latitude, longitude, nil] forKeys:[NSArray arrayWithObjects:@"playerId", @"lat", @"lon", nil]];
    
    [request appendPostData:[body JSONData]];
    
    [request setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self notifyDelegates];
        });
    }];
    
    [request setFailedBlock:^{
        NSLog(@"fail!");
    }];
    
    [request startAsynchronous];
}

- (void) requestPlayers {
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://bozar.dyndns.org/players"]];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError * err = nil;
            id results = [[JSONDecoder decoder] parseJSONData:[request responseData] error:&err];
            
            NSMutableArray* array = [NSMutableArray array];
            for(NSDictionary* definition in results) {
                [array addObject:[[ARLPlayer alloc] initWithDefinition:definition]];
            }
            
            self.players = array;
            
            [self notifyDelegates];
        });
    }];
    
    [request setFailedBlock:^{
        NSLog(@"fail!");
    }];
    
    [request startAsynchronous];
}

- (BOOL) locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	if (newHeading.headingAccuracy > 0) {
		self.currentHeading = newHeading;
        [self notifyDelegates];
	}
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.currentLocation = newLocation;
    //NSLog(@"Location: %@", [newLocation description]);
    
}

- (void) locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	//NSLog(@"Error: %@", [error description]);
}

- (void) notifyDelegates {
    for(NSObject<ARLPlayersDelegate>* delegate in self.delegates) {
        if([delegate respondsToSelector:@selector(didReceiveUpdate)]) {
            [delegate didReceiveUpdate];
        }
    }
}

- (void) addDelegate:(NSObject<ARLPlayersDelegate>*)delegate {
    if(self.delegates.count == 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(tick) userInfo:nil repeats:YES];
    }
    
    [self.delegates addObject:delegate];
}

- (void) removeDelegate:(NSObject<ARLPlayersDelegate>*)delegate {
    [self.delegates removeObject:delegate];
    
    if(delegates.count == 0) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
