//
// $Id: GameConfiguration.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@interface GameConfiguration : NSObject
{
    InitialCountryDistribution initialCountryDistribution;
    InitialArmyPlacement initialArmyPlacement;
    CardSetRedemption cardSetRedemption;
    FortifyRule fortifyRule;
}

+ (void) initialize;

+ defaultConfiguration;

- init;

- (InitialCountryDistribution) initialCountryDistribution;
- (void) setInitialCountryDistribution:(InitialCountryDistribution)newCountryDistribution;

- (InitialArmyPlacement) initialArmyPlacement;
- (void) setInitialArmyPlacement:(InitialArmyPlacement)newArmyPlacement;

- (CardSetRedemption) cardSetRedemption;
- (void) setCardSetRedemption:(CardSetRedemption)newCardSetRedemption;

- (FortifyRule) fortifyRule;
- (void) setFortifyRule:(FortifyRule)newFortifyRule;

- (int) armyPlacementCount;

- (void) writeDefaults;

@end
