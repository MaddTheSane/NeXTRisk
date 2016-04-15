//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: CountryShape.m,v 1.2 1997/12/15 07:43:48 nygard Exp $");

#import "CountryShape.h"

#import "RiskPoint.h"
#import "BoardSetup.h"
#import "SNUserPath.h"
#import "SNUserPathOperation.h"
#import "Country.h"
#import "RiskMapView.h"

#import <libc.h>

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
            _armyCell = [[NSTextFieldCell allocWithZone:[self zone]] init];

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

+ countryShapeWithUserPath:(SNUserPath *)aUserPath armyCellPoint:(NSPoint)aPoint
{
    return [[[CountryShape alloc] initWithUserPath:aUserPath armyCellPoint:aPoint] autorelease];
}

//----------------------------------------------------------------------

- initWithUserPath:(SNUserPath *)aUserPath armyCellPoint:(NSPoint)aPoint
{
    if ([super init] == nil)
        return nil;

    userPath = [aUserPath retain];
    if ([userPath isPathGenerated] == NO)
        [userPath createPathWithCache:YES];
    armyCellPoint = aPoint;
    //shapeBoudns = NSZeroRect;

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (userPath);

    [super dealloc];
}

//----------------------------------------------------------------------

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:userPath];
    [aCoder encodePoint:armyCellPoint];
    //[aCoder encodeRect:shapeBounds];
}

//----------------------------------------------------------------------

- initWithCoder:(NSCoder *)aDecoder
{
    if ([super init] == nil)
        return nil;

    userPath = [[aDecoder decodeObject] retain];
    if ([userPath isPathGenerated] == NO)
        [userPath createPathWithCache:YES];
    armyCellPoint = [aDecoder decodePoint];
    //shapeBounds = [aDecoder decodeRect];

    return self;
}

//----------------------------------------------------------------------

- (void) drawWithCountry:(Country *)aCountry inView:(RiskMapView *)aView isSelected:(BOOL)selected
{
    BoardSetup *boardSetup;

    DPSUserPathOp *operators;
    float *operands, *bbox;
    int operatorCount, operandCount;
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

    if ([userPath isPathGenerated] == YES)
    {
        [userPath getUserPath:&operators:&operatorCount:&operands:&operandCount:&bbox];
        PSDoUserPath (operands, operandCount, dps_float, operators, operatorCount, bbox, dps_ufill);
    }

    if (selected == YES)
        [[boardSetup selectedBorderColor] set];
    else
        [[boardSetup regularBorderColor] set];
    PSsetlinewidth ([boardSetup borderWidth]);

    if ([userPath isPathGenerated] == YES)
    {
        [userPath getUserPath:&operators:&operatorCount:&operands:&operandCount:&bbox];
        PSDoUserPath (operands, operandCount, dps_float, operators, operatorCount, bbox, dps_ustroke);
    }

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
    BOOL flag;

    flag = NO;

    if ([userPath isPathGenerated] == YES)
    {
        flag = [userPath inFill:aPoint];
    }

    return flag;
}

//----------------------------------------------------------------------

- (NSPoint) centerPoint
{
    float *bbox;
    float midx, midy;

    NSAssert ([userPath isPathGenerated] == YES, @"Path not generated...");

    midx = 0;
    midy = 0;

    bbox = [userPath bbox];

    //NSLog (@"bbox: ll (%f,%f), ur (%f,%f)", bbox[0], bbox[1], bbox[2], bbox[3]);
    midx += *bbox++;
    midy += *bbox++;
    midx += *bbox++;
    midy += *bbox++;

    midx /= 2;
    midy /= 2;

    //NSLog (@"middle: %f,%f", midx, midy);

    return NSMakePoint (midx, midy);
}

//----------------------------------------------------------------------

- (NSRect) bounds
{
    NSAssert ([userPath isPathGenerated] == YES, @"Path not generated...");

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
