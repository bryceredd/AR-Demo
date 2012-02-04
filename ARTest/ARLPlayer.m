//
//  ARLPlayer.m
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLPlayer.h"
#import "ARLPlayersManager.h"

@implementation ARLPlayer
@synthesize distanceFromMe, angle;

- (id) initWithDefinition:(NSDictionary*)definition {
    if((self = [super init])) {
        // roughly 1 lat/long degree is 66
        
        float hisLatitude = [[definition objectForKey:@"lat"] floatValue];
        float hisLongitude = [[definition objectForKey:@"lon"] floatValue];

        float myLatitude = [ARLPlayersManager instance].currentLocation.coordinate.latitude;
        float myLongitude = [ARLPlayersManager instance].currentLocation.coordinate.longitude;

        CLLocation* hisLoc = [[CLLocation alloc] initWithLatitude:hisLatitude longitude:hisLongitude];
        CLLocation* myLoc = [[CLLocation alloc] initWithLatitude:myLatitude longitude:myLongitude];


        self.distanceFromMe = [NSNumber numberWithFloat:[myLoc distanceFromLocation:hisLoc]];
        self.angle = [NSNumber numberWithFloat:atan2f(myLatitude-hisLatitude, myLongitude-hisLongitude)];


    } return self;
}



@end
