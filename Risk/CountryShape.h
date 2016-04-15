//
// $Id: CountryShape.h,v 1.2 1997/12/15 07:43:47 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class SNUserPath, Country, RiskMapView;

@interface CountryShape : NSObject <NSCoding>
{
    NSBezierPath *userPath;

    NSPoint armyCellPoint;
    //NSRect shapeBounds;
}

+ (void) initialize;

+ (instancetype)countryShapeWithUserPath:(NSBezierPath *)aUserPath armyCellPoint:(NSPoint)aPoint;

- (instancetype)initWithUserPath:(NSBezierPath *)aUserPath armyCellPoint:(NSPoint)aPoint;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

- (void) drawWithCountry:(Country *)aCountry inView:(RiskMapView *)aView isSelected:(BOOL)selected;
- (BOOL) pointInShape:(NSPoint)aPoint;

@property (readonly) NSPoint centerPoint;
@property (readonly) NSRect bounds;

- (NSString *) description;

@end
