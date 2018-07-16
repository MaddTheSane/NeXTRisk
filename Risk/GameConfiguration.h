//
// $Id: GameConfiguration.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

NS_ASSUME_NONNULL_BEGIN

//! A \c GameConfiguration denotes the rules under which a game will be
//! played.  Newly created instances take their initial values from the
//! defaults database.
@interface GameConfiguration : NSObject
{
    InitialCountryDistribution initialCountryDistribution;
    InitialArmyPlacement initialArmyPlacement;
    CardSetRedemption cardSetRedemption;
    FortifyRule fortifyRule;
}

+ (instancetype)defaultConfiguration NS_SWIFT_UNAVAILABLE("Use init() instead");

- (instancetype)init;

@property InitialCountryDistribution initialCountryDistribution;
@property InitialArmyPlacement initialArmyPlacement;
@property CardSetRedemption cardSetRedemption;
@property FortifyRule fortifyRule;

@property (readonly) RiskArmyCount armyPlacementCount;

- (void) writeDefaults;

@end

NS_ASSUME_NONNULL_END
