//
//  ARLRadarView.m
//  ARTest
//
//  Created by Guy Harding on 2/4/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLRadarView.h"
#import "ARLPlayer.h"


@implementation ARLRadarView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[ARLPlayersManager instance] addDelegate:self];
        numCircles = 3;
        if (self.bounds.size.width > self.bounds.size.height)
            spacing = self.bounds.size.width / (numCircles * 2);
        else
            spacing = self.bounds.size.height / (numCircles * 2);
    }
    return self;
}

- (void) didReceiveUpdate
{
        [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
    /* Draw concentric circles */
	// Get the contextRef
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	// Set the border width
	CGContextSetLineWidth(contextRef, 5.0);
	
	// Set the cicle border color to green
	CGContextSetRGBStrokeColor(contextRef, 0.0, 255.0, 0.0, 1.0);
	
	// Draw the circles
    for (int i = 1; i <= numCircles; i++)
    {
        CGContextAddArc(contextRef,self.center.x,self.center.y, i*spacing,0,2*3.1415926535898,1);
        CGContextDrawPath(contextRef,kCGPathStroke);
    }
    
    // Draw the line

    // Draw the players
    CGPoint playerCenter;
	// Set the circle fill color to green
	CGContextSetRGBFillColor(contextRef, 0.0, 255.0, 0.0, 1.0);
    for(ARLPlayer* player in [ARLPlayersManager instance].players) {
        playerCenter.x = center.x + player.distanceFromMe.floatValue * cos(player.angle.floatValue);
        playerCenter.y = center.y + player.distanceFromMe.floatValue * sin(player.angle.floatValue);
        CGContextAddArc(contextRef,playerCenter.x, playerCenter.y, 4, 0,2*3.1415926535898,1);
        CGContextDrawPath(contextRef,kCGPathFillStroke);
//        NSLog(@"player at %f %f away from me", player.angle.floatValue, player.distanceFromMe.floatValue);
    }

    
}

@end
