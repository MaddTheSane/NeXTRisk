//
// $Id: Risk.h,v 1.1.1.1 1997/12/09 07:18:54 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>
#import "SNUtility.h"

typedef enum _RiskContinent
{
    Unknown = -1,
    SouthAmerica,
    NorthAmerica,
    Europe,
    Africa,
    Asia,
    Australia
} RiskContinent;

typedef int Player;

typedef enum _RiskCardType
{
    Wildcard,
    Soldier,
    Cannon,
    Cavalry
} RiskCardType;

typedef enum _GameState
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
} GameState;

//======================================================================
// Game configuration
//======================================================================

typedef enum _InitialCountryDistribution
{
    PlayerChosen,
    RandomlyChosen
} InitialCountryDistribution;

typedef enum _InitialArmyPlacement
{
    PlaceByOnes,
    PlaceByThrees,
    PlaceByFives
} InitialArmyPlacement;

typedef enum _CardSetRedemption
{
    RemainConstant,
    IncreaseByOne,
    IncreaseByFive
} CardSetRedemption;

typedef enum _FortifyRule
{
    OneToOneNeighbor,
    OneToManyNeighbors,
    ManyToManyNeighbors,
    ManyToManyConnected
} FortifyRule;

typedef struct _DiceRoll
{
    int attackerDieCount;
    int attackerDice[3];
    int defenderDieCount;
    int defenderDice[2];
} DiceRoll;

typedef enum _AttackMethod
{
    AttackOnce,
    AttackMultipleTimes,
    AttackUntilArmiesRemain,
    AttackUntilUnableToContinue
} AttackMethod;

typedef enum _ArmyPlacementType
{
    PlaceInAnyCountry,
    PlaceInTwoCountries,
    PlaceInOneNeighborCountry,
    PlaceInAnyNeighborCountry,
    PlaceInAnyConnectedCountry
} ArmyPlacementType;

typedef struct _AttackResult
{
    BOOL conqueredCountry;
    BOOL phaseChanged;
} AttackResult;

int RiskInitialArmyCountForPlayers (int playerCount);

InitialCountryDistribution initialCountryDistributionFromString (NSString *str);
InitialArmyPlacement initialArmyPlacementFromString (NSString *str);
CardSetRedemption cardSetRedemptionFromString (NSString *str);
FortifyRule fortifyRuleFromString (NSString *str);

NSString *NSStringFromInitialCountryDistribution (InitialCountryDistribution countryDistribution);
NSString *NSStringFromInitialArmyPlacement (InitialArmyPlacement armyPlacement);
NSString *NSStringFromCardSetRedemption (CardSetRedemption cardSetRedemption);
NSString *NSStringFromFortifyRule (FortifyRule fortifyRule);

NSString *NSStringFromRiskCardType (RiskCardType cardType);
NSString *NSStringFromGameState (GameState gameState);
NSString *gameStateInfo (GameState gameState);


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
