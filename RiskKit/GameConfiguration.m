//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: GameConfiguration.m,v 1.2 1997/12/15 07:43:51 nygard Exp $");

#import "GameConfiguration.h"

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
        
        gameDefaults[DK_InitialCountryDistribution] = DV_PlayerChosen;
        gameDefaults[DK_InitialArmyPlacement] = DV_PlaceByThrees;
        gameDefaults[DK_CardSetRedemption] = DV_RemainConstant;
        gameDefaults[DK_FortifyRule] = DV_OneToOneNeighbor;
        [defaults registerDefaults:gameDefaults];
    });
}

//----------------------------------------------------------------------

+ (GameConfiguration*) defaultConfiguration
{
    return [[GameConfiguration alloc] init];
}

//----------------------------------------------------------------------

- (instancetype)init
{
    NSUserDefaults *defaults;
    
    if (self = [super init]) {
        defaults = [NSUserDefaults standardUserDefaults];
        
        initialCountryDistribution = RKInitialCountryDistributionFromString ([defaults stringForKey:DK_InitialCountryDistribution]);
        initialArmyPlacement = RKInitialArmyPlacementFromString ([defaults stringForKey:DK_InitialArmyPlacement]);
        cardSetRedemption = RKCardSetRedemptionFromString ([defaults stringForKey:DK_CardSetRedemption]);
        fortifyRule = RKFortifyRuleFromString ([defaults stringForKey:DK_FortifyRule]);
    }
    
    return self;
}

//----------------------------------------------------------------------

- (int) armyPlacementCount
{
    int count;
    
    switch (initialArmyPlacement)
    {
        case RKInitialArmyPlaceByOnes:
            count = 1;
            break;
            
        case RKInitialArmyPlaceByThrees:
            count = 3;
            break;
            
        case RKInitialArmyPlaceByFives:
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
