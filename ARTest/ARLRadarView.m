//
//  ARLRadarView.m
//  ARTest
//
//  Created by Guy Harding on 2/4/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLRadarView.h"

@implementation ARLRadarView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        numCircles = 3;
        if (self.bounds.size.width > self.bounds.size.height)
            spacing = self.bounds.size.width / (numCircles * 2);
        else
            spacing = self.bounds.size.height / (numCircles * 2);
//        circles = [NSMutableArray arrayWithCapacity:numCircles];
//        for (int i = 0; i < numCircles; i++)
//        {
//            
//            CGRect rect;
//            rect.origin.x = self.center.x - (i+1) * spacing;
//            rect.origin.y = self.center.y - (i+1) * spacing;
//            rect.size.width = 2 * (i+1) * spacing;
//            [circles addObject:[NSValue valueWithCGRect:rect]];
//        }
    }
    return self;
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
	
    
}

@end
