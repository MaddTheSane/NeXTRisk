//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: ArmyPlacementValidator.m,v 1.2 1997/12/15 07:43:36 nygard Exp $");

#import "ArmyPlacementValidator.h"

#import "RiskWorld.h"
#import "Country.h"

//======================================================================
// The ArmyPlacementValidator controls the placement of armies during
// the game -- for initial army placement, normal army placement, after
// a successful attack and during the fortification phase.
//======================================================================

#define ArmyPlacementValidator_VERSION 1

@implementation ArmyPlacementValidator

+ (void) initialize
{
    if (self == [ArmyPlacementValidator class])
    {
        [self setVersion:ArmyPlacementValidator_VERSION];
    }
}

//----------------------------------------------------------------------

- initWithRiskWorld:(RiskWorld *)aWorld
{
    if ([super init] == nil)
        return nil;

    world = [aWorld retain];

    sourceCountry = nil;
    destinationCountry = nil;

    armyPlacementType = PlaceInAnyCountry;
    playerNumber = 0;
    primaryCountries = nil;
    secondaryCountries = nil;

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (world);

    SNRelease (sourceCountry);
    SNRelease (destinationCountry);

    SNRelease (primaryCountries);
    SNRelease (secondaryCountries);

    [super dealloc];
}

//----------------------------------------------------------------------

- (void) _reset
{
    SNRelease (sourceCountry);
    SNRelease (destinationCountry);

    SNRelease (primaryCountries);
    SNRelease (secondaryCountries);
}

//----------------------------------------------------------------------

- (Country *) sourceCountry
{
    return sourceCountry;
}

//----------------------------------------------------------------------

- (Country *) destinationCountry
{
    return destinationCountry;
}

//----------------------------------------------------------------------
// All of these methods deal only with the given player's countries.
// They include the source country.
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Armies may be placed in any country of the given player.
//----------------------------------------------------------------------

- (void) placeInAnyCountryForPlayerNumber:(Player)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = PlaceInAnyCountry;

    primaryCountries = [[world countriesForPlayer:playerNumber] retain];
}

//----------------------------------------------------------------------
// Armies may be placed in either of the two specified countries.
//----------------------------------------------------------------------

- (void) placeInEitherCountry:(Country *)source orCountry:(Country *)other forPlayerNumber:(Player)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = PlaceInTwoCountries;
    sourceCountry = [source retain];
    destinationCountry = [other retain];

    primaryCountries = [[NSSet setWithObjects:source, other, nil] retain];
}

//----------------------------------------------------------------------
// Armies may be placed in either the source country, or exactly one
// of it's neighbors controlled by the same player.
//----------------------------------------------------------------------

- (void) placeInOneNeighborOfCountry:(Country *)source forPlayerNumber:(Player)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = PlaceInOneNeighborCountry;
    sourceCountry = [source retain];

    primaryCountries = [[NSMutableSet setWithObject:source] retain];
    secondaryCountries = [[NSMutableSet setWithSet:[source ourNeighborCountries]] retain];
}

//----------------------------------------------------------------------
// Armies may be placed in either the source country or any of it's
// neighboring countries that are controlled by the same player.
//----------------------------------------------------------------------

- (void) placeInAnyNeighborOfCountry:(Country *)source forPlayerNumber:(Player)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = PlaceInAnyNeighborCountry;
    sourceCountry = [source retain];

    primaryCountries = [[NSMutableSet setWithSet:[source ourNeighborCountries]] retain];
    [primaryCountries addObject:source];
}

//----------------------------------------------------------------------
// Armies may be place in either the source country or any country
// that is connected to it by countries controlled by the same player.
//----------------------------------------------------------------------

- (void) placeInConnectedCountries:(Country *)source forPlayerNumber:(Player)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = PlaceInAnyConnectedCountry;
    sourceCountry = [source retain];

    primaryCountries = [[source ourConnectedCountries] retain];
}

//----------------------------------------------------------------------

- (BOOL) validatePlacement:(Country *)target
{
    BOOL valid;

    valid = YES;

    NSAssert ([target playerNumber] != 0, @"Expected army to be in target country.");

    if ([target playerNumber] != playerNumber)
    {
        valid = NO;
    }
    else
    {
        valid = [primaryCountries member:target] != nil || [secondaryCountries member:target] != nil;
    }

    return valid;
}

//----------------------------------------------------------------------

- (BOOL) placeArmies:(int)count inCountry:(Country *)target
{
    BOOL valid;

    valid = [self validatePlacement:target];

    if (valid == YES)
    {
        // Place the armies
        NSAssert ([target playerNumber] != 0, @"Expected army to be in target country.");

        [target addTroops:count];

        if (armyPlacementType == PlaceInOneNeighborCountry && [secondaryCountries member:target] != nil)
        {
            [primaryCountries addObject:target];
            [secondaryCountries removeAllObjects];
        }
    }

    return valid;
}

@end
