//
//  ARLViewController.h
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import <CoreImage/CoreImage.h>

#import "ARLPlayersManager.h"

@interface ARLViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, ARLPlayersDelegate, UIAccelerometerDelegate>
@property (weak, nonatomic) IBOutlet UIView *face;
@property (weak, nonatomic) IBOutlet UIImageView *monster;
- (IBAction)radar:(id)sender;

@end
