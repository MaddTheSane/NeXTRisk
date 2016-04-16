//
// $Id: CountryShape.h,v 1.2 1997/12/15 07:43:47 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class SNUserPath, Country, RiskMapView;

/// A CountryShape knows how to draw a country -- it's actual shape and
/// where to place the army textfield.
@interface CountryShape : NSObject <NSCoding>
{
    NSBezierPath *userPath;

    NSPoint armyCellPoint;
    //NSRect shapeBounds;
}

+ (instancetype)countryShapeWithUserPath:(NSBezierPath *)aUserPath armyCellPoint:(NSPoint)aPoint NS_SWIFT_UNAVAILABLE("Use init(userPath:armyCellPoint:) instead");

- (instancetype)initWithUserPath:(NSBezierPath *)aUserPath armyCellPoint:(NSPoint)aPoint NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (void) drawWithCountry:(Country *)aCountry inView:(RiskMapView *)aView isSelected:(BOOL)selected;
- (BOOL) pointInShape:(NSPoint)aPoint;

@property (readonly) NSPoint centerPoint;
@property (readonly) NSRect bounds;

@end
