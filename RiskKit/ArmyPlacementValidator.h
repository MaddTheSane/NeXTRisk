//
// $Id: ArmyPlacementValidator.h,v 1.2 1997/12/15 07:43:35 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class RiskWorld, RKCountry;

//! The \c ArmyPlacementValidator controls the placement of armies during
//! the game -- for initial army placement, normal army placement, after
//! a successful attack and during the fortification phase.
@interface ArmyPlacementValidator : NSObject
{
    RiskWorld *world;

    RKCountry *sourceCountry;
    RKCountry *destinationCountry;

    RKArmyPlacementType armyPlacementType;
    RKPlayer playerNumber;
    NSMutableSet<RKCountry*> *primaryCountries;
    NSMutableSet<RKCountry*> *secondaryCountries;
}

- (instancetype)initWithRiskWorld:(RiskWorld *)aWorld NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void) _reset;

@property (readonly, strong) RKCountry *sourceCountry;
@property (readonly, strong) RKCountry *destinationCountry;

//----------------------------------------------------------------------
// All of these methods deal only with the given player's countries.
// They include the source country.
//----------------------------------------------------------------------

- (void) placeInAnyCountryForPlayerNumber:(RKPlayer)number;
- (void) placeInEitherCountry:(RKCountry *)source orCountry:(RKCountry *)other forPlayerNumber:(RKPlayer)number;
- (void) placeInOneNeighborOfCountry:(RKCountry *)source forPlayerNumber:(RKPlayer)number;
- (void) placeInAnyNeighborOfCountry:(RKCountry *)source forPlayerNumber:(RKPlayer)number;
- (void) placeInConnectedCountries:(RKCountry *)source forPlayerNumber:(RKPlayer)number;

- (BOOL) validatePlacement:(RKCountry *)target;
- (BOOL) placeArmies:(RKArmyCount)count inCountry:(RKCountry *)target;

@end
