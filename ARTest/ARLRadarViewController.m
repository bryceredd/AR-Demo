//
//  ARLRadarViewController.m
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLRadarViewController.h"
#import "ARLPlayersManager.h"

@interface ARLRadarViewController() {
    int degree;
}
@end

@implementation ARLRadarViewController

- (void)viewDidLoad {
    [[ARLPlayersManager instance] addDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
