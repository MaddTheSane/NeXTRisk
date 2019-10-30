//
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>
#import <RiskKit/Risk.h>

RCSID ("$Id: CountryShape.m,v 1.2 1997/12/15 07:43:48 nygard Exp $");

#import "CountryShape.h"

#import <RiskKit/RKBoardSetup.h>
#import <RiskKit/RKCountry.h>
#import "RiskMapView.h"
#import <RiskKit/RiskKit-Swift.h>

#include <libc.h>

#if !__has_feature(objc_arc)
#error this file needs to be compiled with Automatic Reference Counting (ARC)
#endif

#define ARMYCELL_WIDTH   25.0
#define ARMYCELL_HEIGHT  17.0

static NSTextFieldCell *_armyCell = nil;

#define CountryShape_VERSION 1

@implementation CountryShape

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [CountryShape setVersion:CountryShape_VERSION];
        _armyCell = [[NSTextFieldCell alloc] init];
        
        _armyCell.backgroundColor = [NSColor whiteColor];
        [_armyCell setBezeled:NO];
        _armyCell.font = [NSFont fontWithName:@"Helvetica" size:10.0];
        _armyCell.alignment = NSCenterTextAlignment;
        [_armyCell setEditable:NO];
        [_armyCell setSelectable:NO];
        [_armyCell setBordered:YES];
        _armyCell.textColor = [NSColor blackColor];
        [_armyCell setDrawsBackground:YES];
    });
}

//----------------------------------------------------------------------

+ (instancetype) countryShapeWithUserPath:(SNUserPath *)aUserPath armyCellPoint:(NSPoint)aPoint
{
    return [[CountryShape alloc] initWithUserPath:aUserPath armyCellPoint:aPoint];
}

+ (instancetype)countryShapeWithBezierPath:(NSBezierPath *)aUserPath armyCellPoint:(NSPoint)aPoint
{
    return [[CountryShape alloc] initWithBezierPath:aUserPath armyCellPoint:aPoint];
}

//----------------------------------------------------------------------

- (instancetype) initWithBezierPath:(NSBezierPath *)aUserPath armyCellPoint:(NSPoint)aPoint
{
    if (self = [super init]) {
        bezierPath = aUserPath;
        armyCellPoint = aPoint;
        //shapeBoudns = NSZeroRect;
    }
    
    return self;
}

- (instancetype)initWithUserPath:(SNUserPath *)aUserPath armyCellPoint:(NSPoint)aPoint
{
    return [self initWithBezierPath:[aUserPath toBezierPath] armyCellPoint:aPoint];
}

//----------------------------------------------------------------------

#define kUserPathKey @"BezierUserPath"
#define kArmyCellPoint @"ArmyCellPoint"

//----------------------------------------------------------------------

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:bezierPath forKey:kUserPathKey];
    [aCoder encodePoint:armyCellPoint forKey:kArmyCellPoint];
    //[aCoder encodeRect:shapeBounds];
}

//----------------------------------------------------------------------

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        if (aDecoder.allowsKeyedCoding && [aDecoder containsValueForKey:kUserPathKey]) {
            bezierPath = [aDecoder decodeObjectOfClass:[NSBezierPath class] forKey:kUserPathKey];
            armyCellPoint = [aDecoder decodePointForKey:kArmyCellPoint];
        } else {
            //For compatibility reasons, we have to jump through some hoops.
            SNUserPath *oldPath = [aDecoder decodeObject];
            bezierPath = [oldPath toBezierPath];
            armyCellPoint = [aDecoder decodePoint];
            //shapeBounds = [aDecoder decodeRect];
        }
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) drawWithCountry:(RKCountry *)aCountry inView:(RiskMapView *)aView isSelected:(BOOL)selected
{
    int troopCount = aCountry.troopCount;
    if (troopCount == 0)
    {
        [aView drawBackground:NSMakeRect (armyCellPoint.x, armyCellPoint.y, ARMYCELL_WIDTH, ARMYCELL_HEIGHT)];
    }
    
    RKBoardSetup *boardSetup = [RKBoardSetup instance];
    
    if (aCountry.playerNumber != 0) {
        [[boardSetup colorForPlayer:aCountry.playerNumber] set];
    } else {
        [[NSColor whiteColor] set];
    }
    
    [bezierPath fill];
    
    if (selected == YES) {
        [boardSetup.selectedBorderColor set];
    } else {
        [boardSetup.regularBorderColor set];
    }
    CGFloat prevWidth = bezierPath.lineWidth;
    bezierPath.lineWidth = boardSetup.borderWidth;
    [bezierPath stroke];
    bezierPath.lineWidth = prevWidth;
    
    if (aCountry.playerNumber != 0 && troopCount > 0)
    {
        // No -- If by default every country has at least one army in it, and it
        // affects combat, add the army at combat.  Otherwise, perhaps it is never an issue...
        //[_armyCell setIntValue:troopCount - 1];
        _armyCell.intValue = troopCount;
        [_armyCell drawWithFrame:NSMakeRect (armyCellPoint.x, armyCellPoint.y, ARMYCELL_WIDTH, ARMYCELL_HEIGHT)
                          inView:aView];
    }
}

//----------------------------------------------------------------------

- (BOOL) pointInShape:(NSPoint)aPoint
{
    return [bezierPath containsPoint:aPoint];
}

//----------------------------------------------------------------------

- (NSPoint) centerPoint
{
    NSRect bbox = bezierPath.bounds;
    
    return NSMakePoint(NSMidX(bbox), NSMidY(bbox));
}

//----------------------------------------------------------------------

- (NSRect) bounds
{
    return NSUnionRect (bezierPath.bounds, NSMakeRect (armyCellPoint.x, armyCellPoint.y, ARMYCELL_WIDTH, ARMYCELL_HEIGHT));
    //return [userPath bounds];
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<CountryShape: userPath = %@, armyCellPoint = %f,%f>",
            bezierPath, armyCellPoint.x, armyCellPoint.y];
}

@end
