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
@synthesize initialCountryDistribution;
@synthesize initialArmyPlacement;
@synthesize cardSetRedemption;
@synthesize fortifyRule;

+ (void) initialize
{
    if (self == [GameConfiguration class])
    {
        [self setVersion:GameConfiguration_VERSION];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *gameDefaults = [[NSMutableDictionary alloc] initWithCapacity:4];

        [gameDefaults setObject:DV_PlayerChosen     forKey:DK_InitialCountryDistribution];
        [gameDefaults setObject:DV_PlaceByThrees    forKey:DK_InitialArmyPlacement];
        [gameDefaults setObject:DV_RemainConstant   forKey:DK_CardSetRedemption];
        [gameDefaults setObject:DV_OneToOneNeighbor forKey:DK_FortifyRule];
        [defaults registerDefaults:gameDefaults];
        [gameDefaults release];
    });
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
