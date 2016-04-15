//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: GameConfiguration.m,v 1.2 1997/12/15 07:43:51 nygard Exp $");

#import "GameConfiguration.h"

//======================================================================
// A GameConfiguration denotes the rules under which a game will be
// played.  Newly created instances take their initial values from the
// defaults database.
//======================================================================

#define GameConfiguration_VERSION 1

@implementation GameConfiguration

+ (void) initialize
{
    NSUserDefaults *defaults;
    NSMutableDictionary *gameDefaults;
    
    if (self == [GameConfiguration class])
    {
        [self setVersion:GameConfiguration_VERSION];

        defaults = [NSUserDefaults standardUserDefaults];
        gameDefaults = [NSMutableDictionary dictionary];

        [gameDefaults setObject:DV_PlayerChosen     forKey:DK_InitialCountryDistribution];
        [gameDefaults setObject:DV_PlaceByThrees    forKey:DK_InitialArmyPlacement];
        [gameDefaults setObject:DV_RemainConstant   forKey:DK_CardSetRedemption];
        [gameDefaults setObject:DV_OneToOneNeighbor forKey:DK_FortifyRule];
        [defaults registerDefaults:gameDefaults];
    }
}

//----------------------------------------------------------------------

+ defaultConfiguration
{
    return [[[GameConfiguration alloc] init] autorelease];
}

//----------------------------------------------------------------------

- init
{
    NSUserDefaults *defaults;

    if ([super init] == nil)
        return nil;

    defaults = [NSUserDefaults standardUserDefaults];

    initialCountryDistribution = initialCountryDistributionFromString ([defaults stringForKey:DK_InitialCountryDistribution]);
    initialArmyPlacement = initialArmyPlacementFromString ([defaults stringForKey:DK_InitialArmyPlacement]);
    cardSetRedemption = cardSetRedemptionFromString ([defaults stringForKey:DK_CardSetRedemption]);
    fortifyRule = fortifyRuleFromString ([defaults stringForKey:DK_FortifyRule]);

    return self;
}

//----------------------------------------------------------------------

- (InitialCountryDistribution) initialCountryDistribution
{
    return initialCountryDistribution;
}

//----------------------------------------------------------------------

- (void) setInitialCountryDistribution:(InitialCountryDistribution)newCountryDistribution
{
    initialCountryDistribution = newCountryDistribution;
}

//----------------------------------------------------------------------

- (InitialArmyPlacement) initialArmyPlacement
{
    return initialArmyPlacement;
}

//----------------------------------------------------------------------

- (void) setInitialArmyPlacement:(InitialArmyPlacement)newArmyPlacement
{
    initialArmyPlacement = newArmyPlacement;
}

//----------------------------------------------------------------------

- (CardSetRedemption) cardSetRedemption
{
    return cardSetRedemption;
}

//----------------------------------------------------------------------

- (void) setCardSetRedemption:(CardSetRedemption)newCardSetRedemption
{
    cardSetRedemption = newCardSetRedemption;
}

//----------------------------------------------------------------------

- (FortifyRule) fortifyRule
{
    return fortifyRule;
}

//----------------------------------------------------------------------

- (void) setFortifyRule:(FortifyRule)newFortifyRule
{
    fortifyRule = newFortifyRule;
}

//----------------------------------------------------------------------

- (int) armyPlacementCount
{
    int count;
    
    switch (initialArmyPlacement)
    {
      case PlaceByOnes:
          count = 1;
          break;

      case PlaceByThrees:
          count = 3;
          break;

      case PlaceByFives:
          count = 5;
          break;

      default:
          NSLog (@"Invalid army placement type.");
          count = 1;
    }

    return count;
}

//----------------------------------------------------------------------

- (void) writeDefaults
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:NSStringFromInitialCountryDistribution (initialCountryDistribution) forKey:DK_InitialCountryDistribution];
    [defaults setObject:NSStringFromInitialArmyPlacement (initialArmyPlacement)             forKey:DK_InitialArmyPlacement];
    [defaults setObject:NSStringFromCardSetRedemption (cardSetRedemption)                   forKey:DK_CardSetRedemption];
    [defaults setObject:NSStringFromFortifyRule (fortifyRule)                               forKey:DK_FortifyRule];

    [defaults synchronize];
}

@end
