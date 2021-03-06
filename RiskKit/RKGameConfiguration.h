//
// $Id: GameConfiguration.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import <RiskKit/Risk.h>

NS_ASSUME_NONNULL_BEGIN

//! A \c RKGameConfiguration denotes the rules under which a game will be
//! played.  Newly created instances take their initial values from the
//! defaults database.
@interface RKGameConfiguration : NSObject
{
    RKInitialCountryDistribution initialCountryDistribution;
    RKInitialArmyPlacement initialArmyPlacement;
    RKCardSetRedemption cardSetRedemption;
    RKFortifyRule fortifyRule;
}

+ (instancetype)defaultConfiguration NS_SWIFT_UNAVAILABLE("Use init() instead");

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@property RKInitialCountryDistribution initialCountryDistribution;
@property RKInitialArmyPlacement initialArmyPlacement;
@property RKCardSetRedemption cardSetRedemption;
@property RKFortifyRule fortifyRule;

@property (readonly) RKArmyCount armyPlacementCount;

- (void) writeDefaults;

@end

NS_ASSUME_NONNULL_END
