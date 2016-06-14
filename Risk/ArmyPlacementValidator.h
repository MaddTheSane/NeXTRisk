//
// $Id: ArmyPlacementValidator.h,v 1.2 1997/12/15 07:43:35 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class RiskWorld, Country;

@interface ArmyPlacementValidator : NSObject
{
    RiskWorld *world;

    Country *sourceCountry;
    Country *destinationCountry;

    ArmyPlacementType armyPlacementType;
    Player playerNumber;
    NSMutableSet<Country*> *primaryCountries;
    NSMutableSet<Country*> *secondaryCountries;
}

- (instancetype)initWithRiskWorld:(RiskWorld *)aWorld NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void) _reset;

@property (readonly, strong) Country *sourceCountry;
@property (readonly, strong) Country *destinationCountry;

//----------------------------------------------------------------------
// All of these methods deal only with the given player's countries.
// They include the source country.
//----------------------------------------------------------------------

- (void) placeInAnyCountryForPlayerNumber:(Player)number;
- (void) placeInEitherCountry:(Country *)source orCountry:(Country *)other forPlayerNumber:(Player)number;
- (void) placeInOneNeighborOfCountry:(Country *)source forPlayerNumber:(Player)number;
- (void) placeInAnyNeighborOfCountry:(Country *)source forPlayerNumber:(Player)number;
- (void) placeInConnectedCountries:(Country *)source forPlayerNumber:(Player)number;

- (BOOL) validatePlacement:(Country *)target;
- (BOOL) placeArmies:(int)count inCountry:(Country *)target;

@end
