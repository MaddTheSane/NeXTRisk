//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: ArmyPlacementValidator.m,v 1.2 1997/12/15 07:43:36 nygard Exp $");

#import "RKArmyPlacementValidator.h"

#import "RiskWorld.h"
#import "RKCountry.h"

#define ArmyPlacementValidator_VERSION 1

@implementation RKArmyPlacementValidator
@synthesize sourceCountry;
@synthesize destinationCountry;

+ (void) initialize
{
    if (self == [RKArmyPlacementValidator class])
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
        
        armyPlacementType = RKArmyPlacementAnyCountry;
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

- (void) placeInAnyCountryForPlayerNumber:(RKPlayer)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = RKArmyPlacementAnyCountry;
    
    primaryCountries = [[world countriesForPlayer:playerNumber] mutableCopy];
}

//----------------------------------------------------------------------
// Armies may be placed in either of the two specified countries.
//----------------------------------------------------------------------

- (void) placeInEitherCountry:(RKCountry *)source orCountry:(RKCountry *)other forPlayerNumber:(RKPlayer)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = RKArmyPlacementTwoCountries;
    sourceCountry = source;
    destinationCountry = other;
    
    primaryCountries = [[NSMutableSet alloc] initWithObjects:source, other, nil];
}

//----------------------------------------------------------------------
// Armies may be placed in either the source country, or exactly one
// of it's neighbors controlled by the same player.
//----------------------------------------------------------------------

- (void) placeInOneNeighborOfCountry:(RKCountry *)source forPlayerNumber:(RKPlayer)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = RKArmyPlacementOneNeighborCountry;
    sourceCountry = source;
    
    primaryCountries = [NSMutableSet setWithObject:source];
    secondaryCountries = [[source ourNeighborCountries] mutableCopy];
}

//----------------------------------------------------------------------
// Armies may be placed in either the source country or any of it's
// neighboring countries that are controlled by the same player.
//----------------------------------------------------------------------

- (void) placeInAnyNeighborOfCountry:(RKCountry *)source forPlayerNumber:(RKPlayer)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = RKArmyPlacementAnyNeighborCountry;
    sourceCountry = source;
    
    primaryCountries = [[source ourNeighborCountries] mutableCopy];
    [primaryCountries addObject:source];
}

//----------------------------------------------------------------------
// Armies may be place in either the source country or any country
// that is connected to it by countries controlled by the same player.
//----------------------------------------------------------------------

- (void) placeInConnectedCountries:(RKCountry *)source forPlayerNumber:(RKPlayer)number
{
    [self _reset];
    playerNumber = number;
    armyPlacementType = RKArmyPlacementAnyConnectedCountry;
    sourceCountry = source;
    
    primaryCountries = [[source ourConnectedCountries] mutableCopy];
}

//----------------------------------------------------------------------

- (BOOL) validatePlacement:(RKCountry *)target
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

- (BOOL) placeArmies:(int)count inCountry:(RKCountry *)target
{
    BOOL valid = [self validatePlacement:target];
    
    if (valid == YES)
    {
        // Place the armies
        NSAssert ([target playerNumber] != 0, @"Expected army to be in target country.");
        
        [target addTroops:count];
        
        if (armyPlacementType == RKArmyPlacementOneNeighborCountry && [secondaryCountries member:target] != nil)
        {
            [primaryCountries addObject:target];
            [secondaryCountries removeAllObjects];
        }
    }
    
    return valid;
}

@end
