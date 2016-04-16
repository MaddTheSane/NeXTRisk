//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: CountryShape.m,v 1.2 1997/12/15 07:43:48 nygard Exp $");

#import "CountryShape.h"

#import "RiskPoint.h"
#import "BoardSetup.h"
#import "Country.h"
#import "RiskMapView.h"
#import "SNUserPath.h"

#include <libc.h>

#define ARMYCELL_WIDTH   25.0
#define ARMYCELL_HEIGHT  17.0

static NSTextFieldCell *_armyCell = nil;

//======================================================================
// A CountryShape knows how to draw a country -- it's actual shape and
// where to place the army textfield.
//======================================================================

#define CountryShape_VERSION 1

@implementation CountryShape

+ (void) initialize
{
    if (self == [CountryShape class])
    {
        [self setVersion:CountryShape_VERSION];

        if (_armyCell == nil)
        {
            _armyCell = [[NSTextFieldCell alloc] init];

            [_armyCell setBackgroundColor:[NSColor whiteColor]];
            [_armyCell setBezeled:NO];
            [_armyCell setFont:[NSFont fontWithName:@"Helvetica" size:10.0]];
            [_armyCell setAlignment:NSCenterTextAlignment];
            [_armyCell setEditable:NO];
            [_armyCell setSelectable:NO];
            [_armyCell setBordered:YES];
            [_armyCell setTextColor:[NSColor blackColor]];
            [_armyCell setDrawsBackground:YES];
        }
    }
}

//----------------------------------------------------------------------

+ countryShapeWithUserPath:(NSBezierPath *)aUserPath armyCellPoint:(NSPoint)aPoint
{
    return [[CountryShape alloc] initWithUserPath:aUserPath armyCellPoint:aPoint];
}

//----------------------------------------------------------------------

- initWithUserPath:(NSBezierPath *)aUserPath armyCellPoint:(NSPoint)aPoint
{
    if ([super init] == nil)
        return nil;

    userPath = aUserPath;
    armyCellPoint = aPoint;
    //shapeBoudns = NSZeroRect;

    return self;
}

//----------------------------------------------------------------------

#define kUserPathKey @"BezierUserPath"
#define kArmyCellPoint @"ArmyCellPoint"

//----------------------------------------------------------------------

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:userPath forKey:kUserPathKey];
    [aCoder encodePoint:armyCellPoint forKey:kArmyCellPoint];
    //[aCoder encodeRect:shapeBounds];
}

//----------------------------------------------------------------------

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ([super init] == nil)
        return nil;
	if ([aDecoder allowsKeyedCoding]) {
		userPath = [aDecoder decodeObjectForKey:kUserPathKey];
		armyCellPoint = [aDecoder decodePointForKey:kArmyCellPoint];
	} else {
		//For compatibility reasons, we have to jump through some hoops.
		SNUserPath *oldPath = [aDecoder decodeObject];
		userPath = [oldPath toBezierPath];
		armyCellPoint = [aDecoder decodePoint];
		//shapeBounds = [aDecoder decodeRect];
	}
	
    return self;
}

//----------------------------------------------------------------------

- (void) drawWithCountry:(Country *)aCountry inView:(RiskMapView *)aView isSelected:(BOOL)selected
{
    BoardSetup *boardSetup;

    int troopCount;

    troopCount = [aCountry troopCount];
    if (troopCount == 0)
    {
        [aView drawBackground:NSMakeRect (armyCellPoint.x, armyCellPoint.y, ARMYCELL_WIDTH, ARMYCELL_HEIGHT)];
    }

    boardSetup = [BoardSetup instance];

    if ([aCountry playerNumber] != 0)
        [[boardSetup colorForPlayer:[aCountry playerNumber]] set];
    else
        [[NSColor whiteColor] set];

	[userPath stroke];

    if (selected == YES)
        [[boardSetup selectedBorderColor] set];
    else
        [[boardSetup regularBorderColor] set];
	CGFloat prevWidth = [userPath lineWidth];
	userPath.lineWidth = boardSetup.borderWidth;
	[userPath stroke];
	userPath.lineWidth = prevWidth;

    if ([aCountry playerNumber] != 0 && troopCount > 0)
    {
        // No -- If by default every country has at least one army in it, and it
        // affects combat, add the army at combat.  Otherwise, perhaps it is never an issue...
        //[_armyCell setIntValue:troopCount - 1];
        [_armyCell setIntValue:troopCount];
        [_armyCell drawWithFrame:NSMakeRect (armyCellPoint.x, armyCellPoint.y, ARMYCELL_WIDTH, ARMYCELL_HEIGHT)
                   inView:aView];
    }
}

//----------------------------------------------------------------------

- (BOOL) pointInShape:(NSPoint)aPoint
{
	return [userPath containsPoint:aPoint];
}

//----------------------------------------------------------------------

- (NSPoint) centerPoint
{
    NSRect bbox = [userPath bounds];
	
	return NSMakePoint(NSMidX(bbox), NSMidY(bbox));
}

//----------------------------------------------------------------------

- (NSRect) bounds
{
    return NSUnionRect ([userPath bounds], NSMakeRect (armyCellPoint.x, armyCellPoint.y, ARMYCELL_WIDTH, ARMYCELL_HEIGHT));
    //return [userPath bounds];
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<CountryShape: userPath = %@, armyCellPoint = %f,%f>",
                     userPath, armyCellPoint.x, armyCellPoint.y];
}

@end
