//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskPoint.m,v 1.2 1997/12/15 07:44:13 nygard Exp $");

#import "RiskPoint.h"

#import "NSObjectExtensions.h"

//======================================================================
// A RiskPoint can be encoded on a stream and stored in arrays.
//======================================================================

#define RiskPoint_VERSION 1

@implementation RiskPoint

+ (void) initialize
{
    if (self == [RiskPoint class])
    {
        [self setVersion:RiskPoint_VERSION];
    }
}

//----------------------------------------------------------------------

+ riskPointWithPoint:(NSPoint)aPoint
{
    return [[[RiskPoint alloc] initWithPoint:aPoint] autorelease];
}

//----------------------------------------------------------------------

- initWithPoint:(NSPoint)aPoint
{
    if ([super init] == nil)
        return nil;

    point = aPoint;

    return self;
}

//----------------------------------------------------------------------

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodePoint:point];
}

//----------------------------------------------------------------------

- initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    point = [aDecoder decodePoint];

    return self;
}

//----------------------------------------------------------------------

- (NSPoint) point
{
    return point;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RiskPoint: %f,%f>", point.x, point.y];
}

@end
