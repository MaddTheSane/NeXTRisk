//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: CountryShapeGenerator.m,v 1.1.1.1 1997/12/09 07:19:18 nygard Exp $");

#import "CountryShapeGenerator.h"

#import "Country.h"
#import "CountryShape.h"
#import "RiskPoint.h"

#import "SNUserPath.h"
#import "SNUserPathOperation.h"

@implementation CountryShapeGenerator

+ countryShapeGenerator
{
    return [[[CountryShapeGenerator alloc] init] autorelease];
}

//----------------------------------------------------------------------

- init
{
    [super init];

    regionArrays = [[NSMutableArray array] retain];
    currentRegionPoints = nil;

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [regionArrays release];
    if (currentRegionPoints != nil)
        [currentRegionPoints release];
    
    [super dealloc];
}

//----------------------------------------------------------------------

- (void) defineNewRegion
{
    NSAssert (currentRegionPoints == nil, @"Already defining a region.");
#if 0
    if (currentRegionPoints != nil)
        [self closeRegion];
#endif
    currentRegionPoints = [[NSMutableArray array] retain];
}

//----------------------------------------------------------------------

- (void) addPoint:(NSPoint)newPoint
{
    NSAssert (currentRegionPoints != nil, @"Not defining a region.");

    [currentRegionPoints addObject:[RiskPoint riskPointWithPoint:newPoint]];
}

//----------------------------------------------------------------------

- (void) closeRegion
{
    NSAssert (currentRegionPoints != nil, @"Not defining a region.");

    [regionArrays addObject:currentRegionPoints];
    [currentRegionPoints release];
    currentRegionPoints = nil;
}

//----------------------------------------------------------------------

- (CountryShape *) generateCountryShapeWithArmyCellPoint:(NSPoint)aPoint
{
    NSEnumerator *regionEnumerator;
    NSEnumerator *pointEnumerator;
    NSArray *region;
    RiskPoint *point;
    SNUserPath *userPath;

    userPath = [[[SNUserPath alloc] init] autorelease];

    regionEnumerator = [regionArrays objectEnumerator];
    while (region = [regionEnumerator nextObject])
    {
        pointEnumerator = [region objectEnumerator];
        point = [pointEnumerator nextObject];
        [userPath addOperation:[SNUserPathOperation moveto:[point point]]];
        while (point = [pointEnumerator nextObject])
        {
            [userPath addOperation:[SNUserPathOperation lineto:[point point]]];
        }
    }
    [userPath addOperation:[SNUserPathOperation closepath]];
    //[userPath createPathWithCache:YES];

    //return [CountryShape countryShapeWithRegions:regionArrays];
    return [CountryShape countryShapeWithUserPath:userPath armyCellPoint:aPoint];
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

    if ([self scanFloat:&aPoint.x] == NO)
        [NSException raise:ExpectException format:@"Expected float"];
    //NSLog (@"Scanned %f", aPoint.x);
    if ([self scanFloat:&aPoint.y] == NO)
        [NSException raise:ExpectException format:@"Expected float"];
    //NSLog (@"Scanned %f", aPoint.y);

    *point = aPoint;
}

@end
