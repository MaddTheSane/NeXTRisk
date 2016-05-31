//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskNeighborView.m,v 1.1.1.1 1997/12/09 07:19:18 nygard Exp $");

#import "RiskNeighborView.h"

#import "RiskNeighbor.h"
#import "SNUtility.h"

#define RiskNeighborView_VERSION 1

@implementation RiskNeighborView
@synthesize dataSource = datasource;

+ (void) initialize
{
    if (self == [RiskNeighborView class])
    {
        [self setVersion:RiskNeighborView_VERSION];
    }
}

//----------------------------------------------------------------------

- initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        datasource = nil;
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    //NSLog (@"datasource: %@", datasource);
    
    if (datasource != nil && [datasource respondsToSelector:@selector (riskNeighbors)] == YES)
    {
        CGFloat xthresh = [self bounds].size.width / 2;
        
        for (RiskNeighbor *riskNeighbor in [datasource riskNeighbors])
        {
            //NSLog (@"neighbor: %@", riskNeighbor);
            NSPoint p1 = [[[riskNeighbor country1] countryShape] centerPoint];
            NSPoint p2 = [[[riskNeighbor country2] countryShape] centerPoint];
            //NSLog (@"%f,%f -> %f,%f", p1.x, p1.y, p2.x, p2.y);
            CGFloat xdelta = p1.x - p2.x;
            if (xdelta < -xthresh || xdelta > xthresh)
                [[NSColor blueColor] set]; // Try to make the Alaska-Kamchatka link stand out
            else
                [[NSColor redColor] set];
            
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:p1];
            [path lineToPoint:p2];
            path.lineWidth = 3;
            [path stroke];
        }
    }
}

@end
