//
// $Id: CountryShape.h,v 1.2 1997/12/15 07:43:47 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class SNUserPath, Country, RiskMapView;

@interface CountryShape : NSObject <NSCoding>
{
    SNUserPath *userPath;

    NSPoint armyCellPoint;
    //NSRect shapeBounds;
}

+ (void) initialize;

+ (instancetype)countryShapeWithUserPath:(SNUserPath *)aUserPath armyCellPoint:(NSPoint)aPoint;

- (instancetype)initWithUserPath:(SNUserPath *)aUserPath armyCellPoint:(NSPoint)aPoint;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

- (void) drawWithCountry:(Country *)aCountry inView:(RiskMapView *)aView isSelected:(BOOL)selected;
- (BOOL) pointInShape:(NSPoint)aPoint;

@property (readonly) NSPoint centerPoint;
- (NSRect) bounds;

- (NSString *) description;

@end
