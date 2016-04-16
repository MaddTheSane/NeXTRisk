//
// $Id: CountryShapeGenerator.h,v 1.1.1.1 1997/12/09 07:19:18 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h> // Need NSPoint...

@class Country, CountryShape;

@interface CountryShapeGenerator : NSObject
{
    NSMutableArray *regionArrays;

    NSMutableArray *currentRegionPoints;
}

+ (instancetype)countryShapeGenerator;

- (instancetype)init;

- (void) defineNewRegion;
- (void) addPoint:(NSPoint)newPoint;
- (void) closeRegion;

- (CountryShape *) generateCountryShapeWithArmyCellPoint:(NSPoint)aPoint;
- (void) createUserPath;

@end

//======================================================================

#define ExpectException @"ExpectException"

@interface NSScanner (RiskUtilExtras)

- (void) expect:(NSString *)str;
- (NSString *) scanQuotedString;
- (NSString *) scanString;
- (void) scanPoint:(NSPoint *)point;

@end
