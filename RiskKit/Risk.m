//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: Risk.m,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $");

#import <AppKit/AppKit.h>

int RKInitialArmyCountForPlayers (int playerCount)
{
    int armyCountForTotalPlayers[7] = {0, 0, 60, 35, 30, 25, 20};
    
    NSCAssert (playerCount >= 2 && playerCount < 7, @"Player count out of range.");

    if (playerCount < 2 || playerCount > 6) {
        return 0;
    }
    return armyCountForTotalPlayers[playerCount];
}

//----------------------------------------------------------------------

RKInitialCountryDistribution RKInitialCountryDistributionFromString (NSString *str)
{
    RKInitialCountryDistribution dist;
    
    if ([str isEqualToString:DV_PlayerChosen] == YES)
    {
        dist = RKInitialCountryDistributionPlayerChosen;
    }
    else if ([str isEqualToString:DV_RandomlyChosen] == YES)
    {
        dist = RKInitialCountryDistributionRandomlyChosen;
    }
    else
    {
        NSLog (@"Invalid InitialContryDistribution: %@", str);
        dist = RKInitialCountryDistributionPlayerChosen;
    }
    
    return dist;
}

//----------------------------------------------------------------------

RKInitialArmyPlacement RKInitialArmyPlacementFromString (NSString *str)
{
    RKInitialArmyPlacement placement;
    
    if ([str isEqualToString:DV_PlaceByOnes] == YES)
    {
        placement = RKInitialArmyPlaceByOnes;
    }
    else if ([str isEqualToString:DV_PlaceByThrees] == YES)
    {
        placement = RKInitialArmyPlaceByThrees;
    }
    else if ([str isEqualToString:DV_PlaceByFives] == YES)
    {
        placement = RKInitialArmyPlaceByFives;
    }
    else
    {
        NSLog (@"Invalid InitialArmyPlacement: %@", str);
        placement = RKInitialArmyPlaceByThrees;
    }
    
    return placement;
}

//----------------------------------------------------------------------

RKCardSetRedemption RKCardSetRedemptionFromString (NSString *str)
{
    RKCardSetRedemption redemption;
    
    if ([str isEqualToString:DV_RemainConstant] == YES)
    {
        redemption = RKCardSetRedemptionRemainConstant;
    }
    else if ([str isEqualToString:DV_IncreaseByOne] == YES)
    {
        redemption = RKCardSetRedemptionIncreaseByOne;
    }
    else if ([str isEqualToString:DV_IncreaseByFive] == YES)
    {
        redemption = RKCardSetRedemptionIncreaseByFive;
    }
    else
    {
        NSLog (@"Invalid CardSetRedemption: %@", str);
        redemption = RKCardSetRedemptionRemainConstant;
    }
    
    return redemption;
}

//----------------------------------------------------------------------

RKFortifyRule RKFortifyRuleFromString (NSString *str)
{
    RKFortifyRule fortifyRule;
    
    if ([str isEqualToString:DV_OneToOneNeighbor] == YES)
    {
        fortifyRule = RKFortifyRuleOneToOneNeighbor;
    }
    else if ([str isEqualToString:DV_OneToManyNeighbors] == YES)
    {
        fortifyRule = RKFortifyRuleOneToManyNeighbors;
    }
    else if ([str isEqualToString:DV_ManyToManyNeighbors] == YES)
    {
        fortifyRule = RKFortifyRuleManyToManyNeighbors;
    }
    else if ([str isEqualToString:DV_ManyToManyConnected] == YES)
    {
        fortifyRule = RKFortifyRuleManyToManyConnected;
    }
    else
    {
        NSLog (@"Invalid FortifyRule: %@", str);
        fortifyRule = RKFortifyRuleOneToOneNeighbor;
    }
    
    return fortifyRule;
}

//----------------------------------------------------------------------

NSString *NSStringFromInitialCountryDistribution (RKInitialCountryDistribution countryDistribution)
{
    NSString *strings[] = { DV_PlayerChosen, DV_RandomlyChosen };
    
    return strings[countryDistribution];
}

//----------------------------------------------------------------------

NSString *NSStringFromInitialArmyPlacement (RKInitialArmyPlacement armyPlacement)
{
    NSString *strings[] = { DV_PlaceByOnes, DV_PlaceByThrees, DV_PlaceByFives };
    
    return strings[armyPlacement];
}

//----------------------------------------------------------------------

NSString *NSStringFromCardSetRedemption (RKCardSetRedemption cardSetRedemption)
{
    NSString *strings[] = { DV_RemainConstant, DV_IncreaseByOne, DV_IncreaseByFive };
    
    return strings[cardSetRedemption];
}

//----------------------------------------------------------------------

NSString *NSStringFromFortifyRule (RKFortifyRule fortifyRule)
{
    NSString *strings[] = { DV_OneToOneNeighbor, DV_OneToManyNeighbors, DV_ManyToManyNeighbors, DV_ManyToManyConnected };
    
    return strings[fortifyRule];
}

//----------------------------------------------------------------------

NSString *NSStringFromRiskCardType (RKCardType cardType)
{
    NSString *str;
    
    str = nil;
    
    switch (cardType)
    {
        case RKCardWildcard:
            str = @"Wildcard";
            break;
            
        case RKCardSoldier:
            str = @"Soldier";
            break;
            
        case RKCardCannon:
            str = @"Cannon";
            break;
            
        case RKCardCavalry:
            str = @"Cavalry";
            break;
            
        default:
            NSLog (@"Unknown card type: %d", cardType);
            str = @"<Unknown>";
    }
    
    return str;
}

//----------------------------------------------------------------------

NSString *NSStringFromGameState (RKGameState gameState)
{
    NSString *str;
    
    switch (gameState)
    {
        case RKGameStateNone:
            str = @"No game";
            break;
            
        case RKGameStateEstablishingGame:
            str = @"Establishing Game";
            break;
            
        case RKGameStateChoosingCountries:
            str = @"Choose Countries";
            break;
            
        case RKGameStatePlaceInitialArmies:
            str = @"Place Initial Armies";
            break;
            
        case RKGameStatePlaceArmies:
            str = @"Place Armies";
            break;
            
        case RKGameStateAttack:
            str = @"Attack";
            break;
            
        case RKGameStateMoveAttackingArmies:
            str = @"Move Attacking Armies";
            break;
            
        case RKGameStateFortify:
            str = @"Fortify Position";
            break;
            
        case RKGameStatePlaceFortifyingArmies:
            str = @"Place Fortifying Armies";
            break;
            
        default:
            NSLog (@"Unknown game state: %d", gameState);
            str = [NSString stringWithFormat:@"<Unknown>, %d", gameState];
            break;
    }
    
    return str;
}

//----------------------------------------------------------------------

NSString *RKGameStateInfo (RKGameState gameState)
{
    NSString *str;
    
    switch (gameState)
    {
        case RKGameStateNone:
            str = @"No game...";
            break;
            
        case RKGameStateEstablishingGame:
            str = @"Establishing game...";
            break;
            
        case RKGameStateChoosingCountries:
            str = @"Before play begins, take turns choosing the countries on the board.";
            break;
            
        case RKGameStatePlaceInitialArmies:
            str = @"The game begins by players taking turns placing their initial armies a few at a time.";
            break;
            
        case RKGameStatePlaceArmies:
            str = @"Begin your turn by placing new armies and possibly turning in cards.";
            break;
            
        case RKGameStateAttack:
            str = @"Attack opponent's countries which border on your own countries.";
            break;
            
        case RKGameStateMoveAttackingArmies:
            str = @"You have conquered a country.  Now place the available armies in either the attacking or the conquered countries.";
            break;
            
        case RKGameStateFortify:
            str = @"Fortify your position at the end of your move by shifting armies.";
            break;
            
        case RKGameStatePlaceFortifyingArmies:
            // Should be based on current rule.
            str = @"Fortify the armies into the source country or any neighboring countries you control.";
            break;
            
        default:
            NSLog (@"Unknown game state: %d", gameState);
            str = [NSString stringWithFormat:@"<Unknown>, %d", gameState];
            break;
    }
    
    return str;
}
