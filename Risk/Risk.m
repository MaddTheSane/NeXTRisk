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
        dist = PlayerChosen;
    }
    else if ([str isEqualToString:DV_RandomlyChosen] == YES)
    {
        dist = RandomlyChosen;
    }
    else
    {
        NSLog (@"Invalid InitialContryDistribution: %@", str);
        dist = PlayerChosen;
    }
    
    return dist;
}

//----------------------------------------------------------------------

InitialArmyPlacement initialArmyPlacementFromString (NSString *str)
{
    InitialArmyPlacement placement;
    
    if ([str isEqualToString:DV_PlaceByOnes] == YES)
    {
        placement = PlaceByOnes;
    }
    else if ([str isEqualToString:DV_PlaceByThrees] == YES)
    {
        placement = PlaceByThrees;
    }
    else if ([str isEqualToString:DV_PlaceByFives] == YES)
    {
        placement = PlaceByFives;
    }
    else
    {
        NSLog (@"Invalid InitialArmyPlacement: %@", str);
        placement = PlaceByThrees;
    }
    
    return placement;
}

//----------------------------------------------------------------------

CardSetRedemption cardSetRedemptionFromString (NSString *str)
{
    CardSetRedemption redemption;
    
    if ([str isEqualToString:DV_RemainConstant] == YES)
    {
        redemption = RemainConstant;
    }
    else if ([str isEqualToString:DV_IncreaseByOne] == YES)
    {
        redemption = IncreaseByOne;
    }
    else if ([str isEqualToString:DV_IncreaseByFive] == YES)
    {
        redemption = IncreaseByFive;
    }
    else
    {
        NSLog (@"Invalid CardSetRedemption: %@", str);
        redemption = RemainConstant;
    }
    
    return redemption;
}

//----------------------------------------------------------------------

FortifyRule fortifyRuleFromString (NSString *str)
{
    FortifyRule fortifyRule;
    
    if ([str isEqualToString:DV_OneToOneNeighbor] == YES)
    {
        fortifyRule = OneToOneNeighbor;
    }
    else if ([str isEqualToString:DV_OneToManyNeighbors] == YES)
    {
        fortifyRule = OneToManyNeighbors;
    }
    else if ([str isEqualToString:DV_ManyToManyNeighbors] == YES)
    {
        fortifyRule = ManyToManyNeighbors;
    }
    else if ([str isEqualToString:DV_ManyToManyConnected] == YES)
    {
        fortifyRule = ManyToManyConnected;
    }
    else
    {
        NSLog (@"Invalid FortifyRule: %@", str);
        fortifyRule = OneToOneNeighbor;
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
        case Wildcard:
            str = @"Wildcard";
            break;
            
        case Soldier:
            str = @"Soldier";
            break;
            
        case Cannon:
            str = @"Cannon";
            break;
            
        case Cavalry:
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
        case gs_no_game:
            str = @"No game";
            break;
            
        case gs_establishing_game:
            str = @"Establishing Game";
            break;
            
        case gs_choose_countries:
            str = @"Choose Countries";
            break;
            
        case gs_place_initial_armies:
            str = @"Place Initial Armies";
            break;
            
        case gs_place_armies:
            str = @"Place Armies";
            break;
            
        case gs_attack:
            str = @"Attack";
            break;
            
        case gs_move_attacking_armies:
            str = @"Move Attacking Armies";
            break;
            
        case gs_fortify:
            str = @"Fortify Position";
            break;
            
        case gs_place_fortifying_armies:
            str = @"Place Fortifying Armies";
            break;
            
        default:
            NSLog (@"Unknown game state: %d", gameState);
            str = nil;
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
        case gs_no_game:
            str = @"No game...";
            break;
            
        case gs_establishing_game:
            str = @"Establishing game...";
            break;
            
        case gs_choose_countries:
            str = @"Before play begins, take turns choosing the countries on the board.";
            break;
            
        case gs_place_initial_armies:
            str = @"The game begins by players taking turns placing their initial armies a few at a time.";
            break;
            
        case gs_place_armies:
            str = @"Begin your turn by placing new armies and possibly turning in cards.";
            break;
            
        case gs_attack:
            str = @"Attack opponent's countries which border on your own countries.";
            break;
            
        case gs_move_attacking_armies:
            str = @"You have conquered a country.  Now place the available armies in either the attacking or the conquered countries.";
            break;
            
        case gs_fortify:
            str = @"Fortify your position at the end of your move by shifting armies.";
            break;
            
        case gs_place_fortifying_armies:
            // Should be based on current rule.
            str = @"Fortify the armies into the source country or any neighboring countries you control.";
            break;
            
        default:
            NSLog (@"Unknown game state: %d", gameState);
            str = nil;
            break;
    }
    
    return str;
}
