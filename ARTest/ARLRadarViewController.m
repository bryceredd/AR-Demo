//
//  ARLRadarViewController.m
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLRadarViewController.h"

@interface ARLRadarViewController() {
    int degree;
}
@property(nonatomic, strong) NSTimer* timer;
- (void) tick;
- (void)rotateView:(UIView *)view aroundPoint:(CGPoint)point withAngle:(double)angle;
@end

@implementation ARLRadarViewController
@synthesize sweeper, timer;

- (void)viewDidLoad {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [self tick];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)close:(id)sender {
    [self.timer invalidate];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
