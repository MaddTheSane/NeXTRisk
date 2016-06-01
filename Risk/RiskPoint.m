//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskPoint.m,v 1.2 1997/12/15 07:44:13 nygard Exp $");

#import "RiskPoint.h"

#if !__has_feature(objc_arc)
#error this file needs to be compiled with Automatic Reference Counting (ARC)
#endif

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

+ (instancetype) riskPointWithPoint:(NSPoint)aPoint
{
    return [[RiskPoint alloc] initWithPoint:aPoint];
}

//----------------------------------------------------------------------

- (instancetype) initWithPoint:(NSPoint)aPoint
{
    if (self = [super init]) {
        point = aPoint;
    }
    
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
    NSPoint bPoint;
    if (aDecoder.allowsKeyedCoding && [aDecoder containsValueForKey:kRiskPoint]) {
        bPoint = [aDecoder decodePointForKey:kRiskPoint];
    } else {
        bPoint = [aDecoder decodePoint];
    }
    return [self initWithPoint:bPoint];
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RiskPoint: %f,%f>", point.x, point.y];
}

@end
