//
// $Id: Risk.h,v 1.1.1.1 1997/12/09 07:18:54 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFAvailability.h>
#import <Foundation/NSObjCRuntime.h>
#import "SNUtility.h"

typedef NS_ENUM(int, RiskContinent)
{
    RiskContinentUnknown = -1,
    RiskContinentSouthAmerica,
    RiskContinentNorthAmerica,
    RiskContinentEurope,
    RiskContinentAfrica,
    RiskContinentAsia,
    RiskContinentAustralia
};

typedef int RiskArmyCount;
typedef NSInteger Player;

typedef NS_ENUM(int, RiskCardType)
{
    RiskCardWildcard,
    RiskCardSoldier,
    RiskCardCannon,
    RiskCardCavalry
};

typedef NS_ENUM(int, GameState)
{
    GameStateNone,
    GameStateEstablishingGame,
    GameStateChoosingCountries,
    GameStatePlaceInitialArmies,
    GameStatePlaceArmies,
    GameStateAttack,
    GameStateMoveAttackingArmies,
    GameStateFortify,
    GameStatePlaceFortifyingArmies
};

//======================================================================
// Game configuration
//======================================================================

typedef NS_ENUM(int, InitialCountryDistribution)
{
    InitialCountryDistributionPlayerChosen,
    InitialCountryDistributionRandomlyChosen
};

typedef NS_ENUM(int, InitialArmyPlacement)
{
    InitialArmyPlaceByOnes,
    InitialArmyPlaceByThrees,
    InitialArmyPlaceByFives
};

typedef NS_ENUM(int, CardSetRedemption)
{
    CardSetRedemptionRemainConstant,
    CardSetRedemptionIncreaseByOne,
    CardSetRedemptionIncreaseByFive
};

typedef NS_ENUM(int, FortifyRule)
{
    FortifyRuleOneToOneNeighbor,
    FortifyRuleOneToManyNeighbors,
    FortifyRuleManyToManyNeighbors,
    FortifyRuleManyToManyConnected
};

typedef struct DiceRoll
{
    int attackerDieCount;
    int attackerDice[3];
    int defenderDieCount;
    int defenderDice[2];
} DiceRoll;

typedef NS_ENUM(int, AttackMethod)
{
    AttackMethodOnce,
    AttackMethodMultipleTimes,
    AttackMethodUntilArmiesRemain,
    AttackMethodUntilUnableToContinue
};

typedef NS_ENUM(int, ArmyPlacementType)
{
    ArmyPlacementAnyCountry,
    ArmyPlacementTwoCountries,
    ArmyPlacementOneNeighborCountry,
    ArmyPlacementAnyNeighborCountry,
    ArmyPlacementAnyConnectedCountry
};

typedef struct AttackResult
{
    BOOL conqueredCountry;
    BOOL phaseChanged;
} AttackResult;

RiskArmyCount RiskInitialArmyCountForPlayers (int playerCount) NS_SWIFT_NAME(RiskInitialArmyCount(forPlayers:));

NS_ASSUME_NONNULL_BEGIN

InitialCountryDistribution initialCountryDistributionFromString (NSString *str) NS_REFINED_FOR_SWIFT;
InitialArmyPlacement initialArmyPlacementFromString (NSString *str) NS_REFINED_FOR_SWIFT;
CardSetRedemption cardSetRedemptionFromString (NSString *str) NS_REFINED_FOR_SWIFT;
FortifyRule fortifyRuleFromString (NSString *str) NS_REFINED_FOR_SWIFT;

NSString *NSStringFromInitialCountryDistribution (InitialCountryDistribution countryDistribution) NS_REFINED_FOR_SWIFT;
NSString *NSStringFromInitialArmyPlacement (InitialArmyPlacement armyPlacement) NS_REFINED_FOR_SWIFT;
NSString *NSStringFromCardSetRedemption (CardSetRedemption cardSetRedemption) NS_REFINED_FOR_SWIFT;
NSString *NSStringFromFortifyRule (FortifyRule fortifyRule) NS_REFINED_FOR_SWIFT;

NSString *NSStringFromRiskCardType (RiskCardType cardType) NS_REFINED_FOR_SWIFT;
NSString *NSStringFromGameState (GameState gameState) NS_REFINED_FOR_SWIFT;
NSString *gameStateInfo (GameState gameState) NS_REFINED_FOR_SWIFT;

NS_ASSUME_NONNULL_END

// Default Key (DK) / Default Value (DV)

#define DK_InitialCountryDistribution   @"InitialCountryDistribution"
#define DV_PlayerChosen                 @"PlayerChosen"
#define DV_RandomlyChosen               @"RandomlyChosen"

#define DK_InitialArmyPlacement @"InitialArmyPlacement"
#define DV_PlaceByOnes          @"PlaceByOnes"
#define DV_PlaceByThrees        @"PlaceByThrees"
#define DV_PlaceByFives         @"PlaceByFives"

#define DK_CardSetRedemption    @"CardSetRedemption"
#define DV_RemainConstant       @"RemainConstant"
#define DV_IncreaseByOne        @"IncreaseByOne"
#define DV_IncreaseByFive       @"IncreaseByFive"

#define DK_FortifyRule          @"FortifyRule"
#define DV_OneToOneNeighbor     @"OneToOneNeighbor"
#define DV_OneToManyNeighbors   @"OneToManyNeighbors"
#define DV_ManyToManyNeighbors  @"ManyToManyNeighbors"
#define DV_ManyToManyConnected  @"ManyToManyConnected"

static const RiskCardType Wildcard API_DEPRECATED_WITH_REPLACEMENT("RiskCardWildcard", macosx(10.0, 10.9)) = RiskCardWildcard;
static const RiskCardType Soldier API_DEPRECATED_WITH_REPLACEMENT("RiskCardSoldier", macosx(10.0, 10.9)) = RiskCardSoldier;
static const RiskCardType Cannon API_DEPRECATED_WITH_REPLACEMENT("RiskCardCannon", macosx(10.0, 10.9)) = RiskCardCannon;
static const RiskCardType Cavalry API_DEPRECATED_WITH_REPLACEMENT("RiskCardCavalry", macosx(10.0, 10.9)) = RiskCardCavalry;

static const RiskContinent Unknown API_DEPRECATED_WITH_REPLACEMENT("RiskContinentUnknown", macosx(10.0, 10.9)) = RiskContinentUnknown;
static const RiskContinent SouthAmerica API_DEPRECATED_WITH_REPLACEMENT("RiskContinentSouthAmerica", macosx(10.0, 10.9)) = RiskContinentSouthAmerica;
static const RiskContinent NorthAmerica API_DEPRECATED_WITH_REPLACEMENT("RiskContinentNorthAmerica", macosx(10.0, 10.9)) = RiskContinentNorthAmerica;
static const RiskContinent Europe API_DEPRECATED_WITH_REPLACEMENT("RiskContinentEurope", macosx(10.0, 10.9)) = RiskContinentEurope;
static const RiskContinent Africa API_DEPRECATED_WITH_REPLACEMENT("RiskContinentAfrica", macosx(10.0, 10.9)) = RiskContinentAfrica;
static const RiskContinent Asia API_DEPRECATED_WITH_REPLACEMENT("RiskContinentAsia", macosx(10.0, 10.9)) = RiskContinentAsia;
static const RiskContinent Australia API_DEPRECATED_WITH_REPLACEMENT("RiskContinentAustralia", macosx(10.0, 10.9)) = RiskContinentAustralia;

static const FortifyRule OneToOneNeighbor API_DEPRECATED_WITH_REPLACEMENT("FortifyRuleOneToOneNeighbor", macosx(10.0, 10.9)) = FortifyRuleOneToOneNeighbor;
static const FortifyRule OneToManyNeighbors API_DEPRECATED_WITH_REPLACEMENT("FortifyRuleOneToManyNeighbors", macosx(10.0, 10.9)) = FortifyRuleOneToManyNeighbors;
static const FortifyRule ManyToManyNeighbors API_DEPRECATED_WITH_REPLACEMENT("FortifyRuleManyToManyNeighbors", macosx(10.0, 10.9)) = FortifyRuleManyToManyNeighbors;
static const FortifyRule ManyToManyConnected API_DEPRECATED_WITH_REPLACEMENT("FortifyRuleManyToManyConnected", macosx(10.0, 10.9)) = FortifyRuleManyToManyConnected;

static const AttackMethod AttackOnce API_DEPRECATED_WITH_REPLACEMENT("AttackMethodOnce", macosx(10.0, 10.9)) = AttackMethodOnce;
static const AttackMethod AttackMultipleTimes API_DEPRECATED_WITH_REPLACEMENT("AttackMethodMultipleTimes", macosx(10.0, 10.9)) = AttackMethodMultipleTimes;
static const AttackMethod AttackUntilArmiesRemain API_DEPRECATED_WITH_REPLACEMENT("AttackMethodUntilArmiesRemain", macosx(10.0, 10.9)) = AttackMethodUntilArmiesRemain;
static const AttackMethod AttackUntilUnableToContinue API_DEPRECATED_WITH_REPLACEMENT("AttackMethodUntilUnableToContinue", macosx(10.0, 10.9)) = AttackMethodUntilUnableToContinue;

static const ArmyPlacementType PlaceInAnyCountry API_DEPRECATED_WITH_REPLACEMENT("ArmyPlacementAnyCountry", macosx(10.0, 10.9)) = ArmyPlacementAnyCountry;
static const ArmyPlacementType PlaceInTwoCountries API_DEPRECATED_WITH_REPLACEMENT("ArmyPlacementTwoCountries", macosx(10.0, 10.9)) = ArmyPlacementTwoCountries;
static const ArmyPlacementType PlaceInOneNeighborCountry API_DEPRECATED_WITH_REPLACEMENT("ArmyPlacementOneNeighborCountry", macosx(10.0, 10.9)) = ArmyPlacementOneNeighborCountry;
static const ArmyPlacementType PlaceInAnyNeighborCountry API_DEPRECATED_WITH_REPLACEMENT("ArmyPlacementAnyNeighborCountry", macosx(10.0, 10.9)) = ArmyPlacementAnyNeighborCountry;
static const ArmyPlacementType PlaceInAnyConnectedCountry API_DEPRECATED_WITH_REPLACEMENT("ArmyPlacementAnyConnectedCountry", macosx(10.0, 10.9)) = ArmyPlacementAnyConnectedCountry;

static const InitialCountryDistribution PlayerChosen API_DEPRECATED_WITH_REPLACEMENT("InitialCountryDistributionPlayerChosen", macosx(10.0, 10.9)) = InitialCountryDistributionPlayerChosen;
static const InitialCountryDistribution RandomlyChosen API_DEPRECATED_WITH_REPLACEMENT("InitialCountryDistributionRandomlyChosen", macosx(10.0, 10.9)) = InitialCountryDistributionRandomlyChosen;

static const CardSetRedemption RemainConstant API_DEPRECATED_WITH_REPLACEMENT("CardSetRedemptionRemainConstant", macosx(10.0, 10.9)) = CardSetRedemptionRemainConstant;
static const CardSetRedemption IncreaseByOne API_DEPRECATED_WITH_REPLACEMENT("CardSetRedemptionIncreaseByOne", macosx(10.0, 10.9)) = CardSetRedemptionIncreaseByOne;
static const CardSetRedemption IncreaseByFive API_DEPRECATED_WITH_REPLACEMENT("CardSetRedemptionIncreaseByFive", macosx(10.0, 10.9)) = CardSetRedemptionIncreaseByFive;

static const InitialArmyPlacement PlaceByOnes API_DEPRECATED_WITH_REPLACEMENT("InitialArmyPlaceByOnes", macosx(10.0, 10.9)) = InitialArmyPlaceByOnes;
static const InitialArmyPlacement PlaceByThrees API_DEPRECATED_WITH_REPLACEMENT("InitialArmyPlaceByThrees", macosx(10.0, 10.9)) = InitialArmyPlaceByThrees;
static const InitialArmyPlacement PlaceByFives API_DEPRECATED_WITH_REPLACEMENT("InitialArmyPlaceByFives", macosx(10.0, 10.9)) = InitialArmyPlaceByFives;

static const GameState gs_no_game API_DEPRECATED_WITH_REPLACEMENT("GameStateNone", macosx(10.0, 10.9)) = GameStateNone;
static const GameState gs_establishing_game API_DEPRECATED_WITH_REPLACEMENT("GameStateEstablishingGame", macosx(10.0, 10.9)) = GameStateEstablishingGame;
static const GameState gs_choose_countries API_DEPRECATED_WITH_REPLACEMENT("GameStateChoosingCountries", macosx(10.0, 10.9)) = GameStateChoosingCountries;
static const GameState gs_place_initial_armies API_DEPRECATED_WITH_REPLACEMENT("GameStatePlaceInitialArmies", macosx(10.0, 10.9)) = GameStatePlaceInitialArmies;
static const GameState gs_place_armies API_DEPRECATED_WITH_REPLACEMENT("GameStatePlaceArmies", macosx(10.0, 10.9)) = GameStatePlaceArmies;
static const GameState gs_attack API_DEPRECATED_WITH_REPLACEMENT("GameStateAttack", macosx(10.0, 10.9)) = GameStateAttack;
static const GameState gs_move_attacking_armies API_DEPRECATED_WITH_REPLACEMENT("GameStateMoveAttackingArmies", macosx(10.0, 10.9)) = GameStateMoveAttackingArmies;
static const GameState gs_fortify API_DEPRECATED_WITH_REPLACEMENT("GameStateFortify", macosx(10.0, 10.9)) = GameStateFortify;
static const GameState gs_place_fortifying_armies API_DEPRECATED_WITH_REPLACEMENT("GameStatePlaceFortifyingArmies", macosx(10.0, 10.9)) = GameStatePlaceFortifyingArmies;
