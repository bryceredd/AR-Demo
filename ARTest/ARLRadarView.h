//
//  ARLRadarView.h
//  ARTest
//
//  Created by Guy Harding on 2/4/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARLPlayersManager.h"

@interface ARLRadarView : UIView <ARLPlayersDelegate>
{
    int numCircles;
    int spacing;
    // scale is the screen to meters conversion in pixels per meter.
    double scale;
    CGPoint center;
}

- (void) didReceiveUpdate;

@end
