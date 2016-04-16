//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskPoint.m,v 1.2 1997/12/15 07:44:13 nygard Exp $");

#import "RiskPoint.h"

//======================================================================
// A RiskPoint can be encoded on a stream and stored in arrays.
//======================================================================

#define RiskPoint_VERSION 1

@implementation RiskPoint
@synthesize point;

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
    return [[RiskPoint alloc] initWithPoint:aPoint];
}

//----------------------------------------------------------------------

- initWithPoint:(NSPoint)aPoint
{
    if ([super init] == nil)
        return nil;

    point = aPoint;

    return self;
}

- (instancetype)init
{
    return [self initWithPoint:NSZeroPoint];
}

//----------------------------------------------------------------------

#define kRiskPoint @"Point"
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodePoint:point forKey:kRiskPoint];
}

//----------------------------------------------------------------------

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ([super init] == nil)
        return nil;

    if ([aDecoder allowsKeyedCoding]) {
        point = [aDecoder decodePointForKey:kRiskPoint];
    } else {
    point = [aDecoder decodePoint];
    }

    return self;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RiskPoint: %f,%f>", point.x, point.y];
}

@end
