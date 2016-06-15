//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: CountryShapeGenerator.m,v 1.1.1.1 1997/12/09 07:19:18 nygard Exp $");

#import "CountryShapeGenerator.h"

#import "Country.h"
#import "CountryShape.h"
#import "RiskUtil-Swift.h"

@implementation CountryShapeGenerator

+ countryShapeGenerator
{
    return [[CountryShapeGenerator alloc] init];
}

//----------------------------------------------------------------------

- init
{
    if (self = [super init]) {
        regionArrays = [[NSMutableArray alloc] init];
        currentRegionPoints = nil;
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) defineNewRegion
{
    NSAssert (currentRegionPoints == nil, @"Already defining a region.");
#if 0
    if (currentRegionPoints != nil)
        [self closeRegion];
#endif
    currentRegionPoints = [NSMutableArray array];
}

//----------------------------------------------------------------------

- (void) addPoint:(NSPoint)newPoint
{
    NSAssert (currentRegionPoints != nil, @"Not defining a region.");
    
    [currentRegionPoints addObject:[[RiskPoint alloc] initWithPoint:newPoint]];
}

//----------------------------------------------------------------------

- (void) closeRegion
{
    NSAssert (currentRegionPoints != nil, @"Not defining a region.");
    
    [regionArrays addObject:currentRegionPoints];
    currentRegionPoints = nil;
}

//----------------------------------------------------------------------

- (CountryShape *) generateCountryShapeWithArmyCellPoint:(NSPoint)aPoint
{
    NSBezierPath *userPath = [[NSBezierPath alloc] init];
    
    for (NSArray<RiskPoint*> *region in regionArrays)
    {
        NSEnumerator<RiskPoint*> *pointEnumerator = [region objectEnumerator];
        RiskPoint *point = [pointEnumerator nextObject];
        [userPath moveToPoint:point.point];
        while (point = [pointEnumerator nextObject])
        {
            [userPath lineToPoint:point.point];
        }
    }
    [userPath closePath];
    
    //return [CountryShape countryShapeWithRegions:regionArrays];
    return [CountryShape countryShapeWithBezierPath:userPath armyCellPoint:aPoint];
}

//----------------------------------------------------------------------

- (void) createUserPath
{
}

@end

//======================================================================

@implementation NSScanner (RiskUtilExtras)

- (void) expect:(NSString *)str
{
    if ([self scanString:str intoString:NULL] == NO)
        [NSException raise:ExpectException format:@"Expected %@", str];
    
    //NSLog (@"Got %@", str);
}

//----------------------------------------------------------------------

- (NSString *) scanQuotedString
{
    NSString *str;
    
    str = nil;
    
    [self expect:@"\""];
    [self scanUpToString:@"\"" intoString:&str];
    [self expect:@"\""];
    
    //NSLog (@"scanned \"%@\"", str);
    
    return str;
}

//----------------------------------------------------------------------

- (NSString *) scanString
{
    NSString *str;
    
    str = nil;
    
    if ([self scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&str] == NO)
        [NSException raise:ExpectException format:@"Expected letter"];
    
    //NSLog (@"scanned %@", str);
    
    return str;
}

//----------------------------------------------------------------------

- (void) scanPoint:(NSPoint *)point
{
    NSPoint aPoint;
    float anX = 0, anY = 0;
    
    if ([self scanFloat:&anX] == NO)
        [NSException raise:ExpectException format:@"Expected float"];
    //NSLog (@"Scanned %f", aPoint.x);
    if ([self scanFloat:&anY] == NO)
        [NSException raise:ExpectException format:@"Expected float"];
    //NSLog (@"Scanned %f", aPoint.y);
    
    aPoint.x = anX;
    aPoint.y = anY;
    
    *point = aPoint;
}

@end
