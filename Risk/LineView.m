//
// This file is a part of Risk by Mike Ferris.
//

//#import "Risk.h"

//RCSID ("$Id: LineView.m,v 1.2 1997/12/15 07:43:55 nygard Exp $");

#import "LineView.h"

@implementation LineView
@synthesize lineWidth;

- (void) setLineWidth:(CGFloat)lw
{
    lineWidth = lw;
    [self display];
}

//----------------------------------------------------------------------

- (void) drawRect:(NSRect)rects
{
    CGFloat mp, begin, end;
    NSRect boundsRect = self.bounds;
	
    NSDrawWhiteBezel (boundsRect, boundsRect);
    mp = NSMidY(boundsRect);
    begin = boundsRect.origin.x + 2;
    end = boundsRect.origin.x + boundsRect.size.width - 2;

	[[NSColor blackColor] set];
	NSBezierPath *path = [NSBezierPath bezierPath];
	path.lineWidth = lineWidth;
	[path moveToPoint:NSMakePoint(begin, mp)];
	[path lineToPoint:NSMakePoint(end, mp)];
	[path closePath];
	[path stroke];
}

@end
