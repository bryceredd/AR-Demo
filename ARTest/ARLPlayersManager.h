//
//  ARLPlayers.h
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol ARLPlayersDelegate
- (void) didReceiveUpdate;
@end

@interface ARLPlayersManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLHeading* currentHeading;
@property (nonatomic, strong) CLLocation* currentLocation;

+(ARLPlayersManager*) instance;

- (void) addDelegate:(NSObject<ARLPlayersDelegate>*)delegate;

@end
