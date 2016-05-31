//
// $Id: Risk.h,v 1.1.1.1 1997/12/09 07:18:54 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>
#import "SNUtility.h"

typedef NS_ENUM(int, RiskContinent)
{
    Unknown = -1,
    SouthAmerica,
    NorthAmerica,
    Europe,
    Africa,
    Asia,
    Australia
};

typedef NSInteger Player;

typedef NS_ENUM(int, RiskCardType)
{
    Wildcard,
    Soldier,
    Cannon,
    Cavalry
};

typedef NS_ENUM(int, GameState)
{
    gs_no_game,
    gs_establishing_game,
    gs_choose_countries,
    gs_place_initial_armies,
    gs_place_armies,
    gs_attack,
    gs_move_attacking_armies,
    gs_fortify,
    gs_place_fortifying_armies
};

//======================================================================
// Game configuration
//======================================================================

typedef NS_ENUM(int, InitialCountryDistribution)
{
    PlayerChosen,
    RandomlyChosen
};

typedef NS_ENUM(int, InitialArmyPlacement)
{
    PlaceByOnes,
    PlaceByThrees,
    PlaceByFives
};

typedef NS_ENUM(int, CardSetRedemption)
{
    RemainConstant,
    IncreaseByOne,
    IncreaseByFive
};

typedef NS_ENUM(int, FortifyRule)
{
    OneToOneNeighbor,
    OneToManyNeighbors,
    ManyToManyNeighbors,
    ManyToManyConnected
};

typedef struct _DiceRoll
{
    int attackerDieCount;
    int attackerDice[3];
    int defenderDieCount;
    int defenderDice[2];
} DiceRoll;

typedef NS_ENUM(int, AttackMethod)
{
    AttackOnce,
    AttackMultipleTimes,
    AttackUntilArmiesRemain,
    AttackUntilUnableToContinue
};

typedef NS_ENUM(int, ArmyPlacementType)
{
    PlaceInAnyCountry,
    PlaceInTwoCountries,
    PlaceInOneNeighborCountry,
    PlaceInAnyNeighborCountry,
    PlaceInAnyConnectedCountry
};

typedef struct _AttackResult
{
    BOOL conqueredCountry;
    BOOL phaseChanged;
} AttackResult;

int RiskInitialArmyCountForPlayers (int playerCount);

NS_ASSUME_NONNULL_BEGIN

InitialCountryDistribution initialCountryDistributionFromString (NSString *str);
InitialArmyPlacement initialArmyPlacementFromString (NSString *str);
CardSetRedemption cardSetRedemptionFromString (NSString *str);
FortifyRule fortifyRuleFromString (NSString *str);

NSString *NSStringFromInitialCountryDistribution (InitialCountryDistribution countryDistribution);
NSString *NSStringFromInitialArmyPlacement (InitialArmyPlacement armyPlacement);
NSString *NSStringFromCardSetRedemption (CardSetRedemption cardSetRedemption);
NSString *NSStringFromFortifyRule (FortifyRule fortifyRule);

NSString *NSStringFromRiskCardType (RiskCardType cardType);
NSString *__nullable NSStringFromGameState (GameState gameState);
NSString *__nullable gameStateInfo (GameState gameState);

NS_ASSUME_NONNULL_END

// Default Key (DK) / Default Value (DV)

#define DK_InitialCountryDistribution @"InitialCountryDistribution"
#define DV_PlayerChosen                 @"PlayerChosen"
#define DV_RandomlyChosen               @"RandomlyChosen"

#define DK_InitialArmyPlacement @"InitialArmyPlacement"
#define DV_PlaceByOnes            @"PlaceByOnes"
#define DV_PlaceByThrees          @"PlaceByThrees"
#define DV_PlaceByFives           @"PlaceByFives"

#define DK_CardSetRedemption @"CardSetRedemption"
#define DV_RemainConstant      @"RemainConstant"
#define DV_IncreaseByOne       @"IncreaseByOne"
#define DV_IncreaseByFive      @"IncreaseByFive"

#define DK_FortifyRule         @"FortifyRule"
#define DV_OneToOneNeighbor      @"OneToOneNeighbor"
#define DV_OneToManyNeighbors    @"OneToManyNeighbors"
#define DV_ManyToManyNeighbors   @"ManyToManyNeighbors"
#define DV_ManyToManyConnected   @"ManyToManyConnected"
