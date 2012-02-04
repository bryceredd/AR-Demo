//
//  ARLRadarView.m
//  ARTest
//
//  Created by Guy Harding on 2/4/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLRadarView.h"
#import "ARLPlayer.h"
#import "ARLPlayersManager.h"


@implementation ARLRadarView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[ARLPlayersManager instance] addDelegate:self];
        numCircles = 3;
        
        if (self.bounds.size.width > self.bounds.size.height)
        {
            spacing = self.bounds.size.width / (numCircles * 2);
            scale = self.bounds.size.width/1000;
        }
        else
        {
            spacing = self.bounds.size.height / (numCircles * 2);
            scale = self.bounds.size.width/1000;
        }
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
    
    CGContextSaveGState(contextRef);
	
	// Set the border width
	CGContextSetLineWidth(contextRef, 3.0);
	
	// Set the cicle border color 
	CGContextSetRGBStrokeColor(contextRef, 133.0, 130.0, 130.0, 1.0);
	
	// Draw the circles
    for (int i = 1; i <= numCircles; i++)
    {
        CGContextAddArc(contextRef,self.center.x,self.center.y, i*spacing,0,2*3.1415926535898,1);
        CGContextDrawPath(contextRef,kCGPathStroke);
    }
    
    // Draw the line

    // Draw the players
    CGPoint playerCenter;
    CGPoint screenCenter;
    screenCenter.x = self.bounds.size.width / 2;
    screenCenter.y = self.bounds.size.height / 2;
    
	// Set the circle fill color to green
	CGContextSetRGBFillColor(contextRef, 252.0, 130.0, 0.0, 1.0);
    for(ARLPlayer* player in [ARLPlayersManager instance].players) {
    
        float angle = player.angle.floatValue  - degreesToRadian([ARLPlayersManager instance].currentHeading.trueHeading);
        playerCenter.x = screenCenter.x + scale * player.distanceFromMe.floatValue * cos(angle);
        playerCenter.y = screenCenter.y + scale * player.distanceFromMe.floatValue * sin(angle);
        CGContextAddArc(contextRef,playerCenter.x, playerCenter.y, 4, 0,2*3.1415926535898,1);
        CGContextDrawPath(contextRef,kCGPathFill);
    }
    
    
    // Draw the current player
    CGContextSetRGBFillColor(contextRef, 2.0, 251.0, 143.0, 1.0);
    CGContextSetRGBStrokeColor(contextRef, 2.0, 251.0, 143.0, 1.0);
    CGContextSetLineWidth(contextRef, 0.0);
    CGContextAddArc(contextRef, self.center.x,self.center.y, 5.0, 0,2*3.1415926535898,1);
    CGContextDrawPath(contextRef, kCGPathFill);
    
    CGContextRestoreGState(contextRef);
    
}

@end
