//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: Risk.m,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $");

#import <AppKit/AppKit.h>

int RiskInitialArmyCountForPlayers (int playerCount)
{
    int armyCountForTotalPlayers[7] = {0, 0, 60, 35, 30, 25, 20};
    
    NSCAssert (playerCount >= 2 && playerCount < 7, @"Player count out of range.");

    return armyCountForTotalPlayers[playerCount];
}

//----------------------------------------------------------------------

InitialCountryDistribution initialCountryDistributionFromString (NSString *str)
{
    InitialCountryDistribution dist;
    
    if ([str isEqualToString:DV_PlayerChosen] == YES)
    {
        dist = InitialCountryDistributionPlayerChosen;
    }
    else if ([str isEqualToString:DV_RandomlyChosen] == YES)
    {
        dist = InitialCountryDistributionRandomlyChosen;
    }
    else
    {
        NSLog (@"Invalid InitialContryDistribution: %@", str);
        dist = InitialCountryDistributionPlayerChosen;
    }
    
    return dist;
}

//----------------------------------------------------------------------

InitialArmyPlacement initialArmyPlacementFromString (NSString *str)
{
    InitialArmyPlacement placement;
    
    if ([str isEqualToString:DV_PlaceByOnes] == YES)
    {
        placement = InitialArmyPlaceByOnes;
    }
    else if ([str isEqualToString:DV_PlaceByThrees] == YES)
    {
        placement = InitialArmyPlaceByThrees;
    }
    else if ([str isEqualToString:DV_PlaceByFives] == YES)
    {
        placement = InitialArmyPlaceByFives;
    }
    else
    {
        NSLog (@"Invalid InitialArmyPlacement: %@", str);
        placement = InitialArmyPlaceByThrees;
    }
    
    return placement;
}

//----------------------------------------------------------------------

CardSetRedemption cardSetRedemptionFromString (NSString *str)
{
    CardSetRedemption redemption;
    
    if ([str isEqualToString:DV_RemainConstant] == YES)
    {
        redemption = CardSetRedemptionRemainConstant;
    }
    else if ([str isEqualToString:DV_IncreaseByOne] == YES)
    {
        redemption = CardSetRedemptionIncreaseByOne;
    }
    else if ([str isEqualToString:DV_IncreaseByFive] == YES)
    {
        redemption = CardSetRedemptionIncreaseByFive;
    }
    else
    {
        NSLog (@"Invalid CardSetRedemption: %@", str);
        redemption = CardSetRedemptionRemainConstant;
    }
    
    return redemption;
}

//----------------------------------------------------------------------

FortifyRule fortifyRuleFromString (NSString *str)
{
    FortifyRule fortifyRule;
    
    if ([str isEqualToString:DV_OneToOneNeighbor] == YES)
    {
        fortifyRule = FortifyRuleOneToOneNeighbor;
    }
    else if ([str isEqualToString:DV_OneToManyNeighbors] == YES)
    {
        fortifyRule = FortifyRuleOneToManyNeighbors;
    }
    else if ([str isEqualToString:DV_ManyToManyNeighbors] == YES)
    {
        fortifyRule = FortifyRuleManyToManyNeighbors;
    }
    else if ([str isEqualToString:DV_ManyToManyConnected] == YES)
    {
        fortifyRule = FortifyRuleManyToManyConnected;
    }
    else
    {
        NSLog (@"Invalid FortifyRule: %@", str);
        fortifyRule = FortifyRuleOneToOneNeighbor;
    }
    
    return fortifyRule;
}

//----------------------------------------------------------------------

NSString *NSStringFromInitialCountryDistribution (InitialCountryDistribution countryDistribution)
{
    NSString *strings[] = { DV_PlayerChosen, DV_RandomlyChosen };
    
    return strings[countryDistribution];
}

//----------------------------------------------------------------------

NSString *NSStringFromInitialArmyPlacement (InitialArmyPlacement armyPlacement)
{
    NSString *strings[] = { DV_PlaceByOnes, DV_PlaceByThrees, DV_PlaceByFives };
    
    return strings[armyPlacement];
}

//----------------------------------------------------------------------

NSString *NSStringFromCardSetRedemption (CardSetRedemption cardSetRedemption)
{
    NSString *strings[] = { DV_RemainConstant, DV_IncreaseByOne, DV_IncreaseByFive };
    
    return strings[cardSetRedemption];
}

//----------------------------------------------------------------------

NSString *NSStringFromFortifyRule (FortifyRule fortifyRule)
{
    NSString *strings[] = { DV_OneToOneNeighbor, DV_OneToManyNeighbors, DV_ManyToManyNeighbors, DV_ManyToManyConnected };
    
    return strings[fortifyRule];
}

//----------------------------------------------------------------------

NSString *NSStringFromRiskCardType (RiskCardType cardType)
{
    NSString *str;
    
    str = nil;
    
    switch (cardType)
    {
        case RiskCardWildcard:
            str = @"Wildcard";
            break;
            
        case RiskCardSoldier:
            str = @"Soldier";
            break;
            
        case RiskCardCannon:
            str = @"Cannon";
            break;
            
        case RiskCardCavalry:
            str = @"Cavalry";
            break;
            
        default:
            NSLog (@"Unknown card type: %d", cardType);
            str = @"<Unknown>";
    }
    
    return str;
}

//----------------------------------------------------------------------

NSString *NSStringFromGameState (GameState gameState)
{
    NSString *str;
    
    switch (gameState)
    {
        case GameStateNone:
            str = @"No game";
            break;
            
        case GameStateEstablishingGame:
            str = @"Establishing Game";
            break;
            
        case GameStateChoosingCountries:
            str = @"Choose Countries";
            break;
            
        case GameStatePlaceInitialArmies:
            str = @"Place Initial Armies";
            break;
            
        case GameStatePlaceArmies:
            str = @"Place Armies";
            break;
            
        case GameStateAttack:
            str = @"Attack";
            break;
            
        case GameStateMoveAttackingArmies:
            str = @"Move Attacking Armies";
            break;
            
        case GameStateFortify:
            str = @"Fortify Position";
            break;
            
        case GameStatePlaceFortifyingArmies:
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

NSString *gameStateInfo (GameState gameState)
{
    NSString *str;
    
    switch (gameState)
    {
        case GameStateNone:
            str = @"No game...";
            break;
            
        case GameStateEstablishingGame:
            str = @"Establishing game...";
            break;
            
        case GameStateChoosingCountries:
            str = @"Before play begins, take turns choosing the countries on the board.";
            break;
            
        case GameStatePlaceInitialArmies:
            str = @"The game begins by players taking turns placing their initial armies a few at a time.";
            break;
            
        case GameStatePlaceArmies:
            str = @"Begin your turn by placing new armies and possibly turning in cards.";
            break;
            
        case GameStateAttack:
            str = @"Attack opponent's countries which border on your own countries.";
            break;
            
        case GameStateMoveAttackingArmies:
            str = @"You have conquered a country.  Now place the available armies in either the attacking or the conquered countries.";
            break;
            
        case GameStateFortify:
            str = @"Fortify your position at the end of your move by shifting armies.";
            break;
            
        case GameStatePlaceFortifyingArmies:
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
