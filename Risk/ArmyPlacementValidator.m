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
@synthesize sourceCountry;
@synthesize destinationCountry;

+ (void) initialize
{
    if (self == [ArmyPlacementValidator class])
    {
        [self setVersion:ArmyPlacementValidator_VERSION];
    }
}

//----------------------------------------------------------------------

- (instancetype) initWithRiskWorld:(RiskWorld *)aWorld
{
    if (self = [super init]) {
    world = aWorld;

    sourceCountry = nil;
    destinationCountry = nil;

    armyPlacementType = PlaceInAnyCountry;
    playerNumber = 0;
    primaryCountries = nil;
    secondaryCountries = nil;
    }

    return self;
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

    primaryCountries = [[world countriesForPlayer:playerNumber] mutableCopy];
}

//----------------------------------------------------------------------
// Armies may be placed in either of the two specified countries.
//----------------------------------------------------------------------

- (void) placeInEitherCountry:(Country *)source orCountry:(Country *)other forPlayerNumber:(Player)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = PlaceInTwoCountries;
    sourceCountry = source;
    destinationCountry = other;

    primaryCountries = [[NSMutableSet alloc] initWithObjects:source, other, nil];
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
    sourceCountry = source;

    primaryCountries = [NSMutableSet setWithObject:source];
    secondaryCountries = [[source ourNeighborCountries] mutableCopy];
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
    sourceCountry = source;

    primaryCountries = [NSMutableSet setWithSet:[source ourNeighborCountries]];
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
    sourceCountry = source;

    primaryCountries = [[source ourConnectedCountries] mutableCopy];
}

//----------------------------------------------------------------------

- (BOOL) validatePlacement:(Country *)target
{
    BOOL valid;

    NSAssert ([target playerNumber] != 0, @"Expected army to be in target country.");

    if (target.playerNumber != playerNumber)
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
