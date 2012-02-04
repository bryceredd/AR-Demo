//
//  ARLRadarViewController.h
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ARLRadarViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *sweeper;
@property (nonatomic, strong) CLLocationManager* locationManager;
- (IBAction)close:(id)sender;

@end
