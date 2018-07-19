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

typedef int RKArmyCount;
typedef NSInteger RKPlayer;

typedef NS_ENUM(int, RKCardType)
{
    RKCardWildcard,
    RKCardSoldier,
    RKCardCannon,
    RKCardCavalry
};

typedef NS_ENUM(int, RKGameState)
{
    RKGameStateNone,
    RKGameStateEstablishingGame,
    RKGameStateChoosingCountries,
    RKGameStatePlaceInitialArmies,
    RKGameStatePlaceArmies,
    RKGameStateAttack,
    RKGameStateMoveAttackingArmies,
    RKGameStateFortify,
    RKGameStatePlaceFortifyingArmies
};

//======================================================================
// Game configuration
//======================================================================

typedef NS_ENUM(int, RKInitialCountryDistribution)
{
    RKInitialCountryDistributionPlayerChosen,
    RKInitialCountryDistributionRandomlyChosen
};

typedef NS_ENUM(int, RKInitialArmyPlacement)
{
    RKInitialArmyPlaceByOnes,
    RKInitialArmyPlaceByThrees,
    RKInitialArmyPlaceByFives
};

typedef NS_ENUM(int, RKCardSetRedemption)
{
    RKCardSetRedemptionRemainConstant,
    RKCardSetRedemptionIncreaseByOne,
    RKCardSetRedemptionIncreaseByFive
};

typedef NS_ENUM(int, RKFortifyRule)
{
    RKFortifyRuleOneToOneNeighbor,
    RKFortifyRuleOneToManyNeighbors,
    RKFortifyRuleManyToManyNeighbors,
    RKFortifyRuleManyToManyConnected
};

typedef struct RKDiceRoll
{
    int attackerDieCount;
    int attackerDice[3];
    int defenderDieCount;
    int defenderDice[2];
} RKDiceRoll;

typedef NS_ENUM(int, RKAttackMethod)
{
    RKAttackMethodOnce,
    RKAttackMethodMultipleTimes,
    RKAttackMethodUntilArmiesRemain,
    RKAttackMethodUntilUnableToContinue
};

typedef NS_ENUM(int, RKArmyPlacementType)
{
    RKArmyPlacementAnyCountry,
    RKArmyPlacementTwoCountries,
    RKArmyPlacementOneNeighborCountry,
    RKArmyPlacementAnyNeighborCountry,
    RKArmyPlacementAnyConnectedCountry
};

typedef struct RKAttackResult
{
    BOOL conqueredCountry;
    BOOL phaseChanged;
} RKAttackResult;

RKArmyCount RKInitialArmyCountForPlayers (int playerCount) NS_SWIFT_NAME(initialArmyCount(forPlayers:));

NS_ASSUME_NONNULL_BEGIN

RKInitialCountryDistribution RKInitialCountryDistributionFromString (NSString *str) NS_REFINED_FOR_SWIFT;
RKInitialArmyPlacement RKInitialArmyPlacementFromString (NSString *str) NS_REFINED_FOR_SWIFT;
RKCardSetRedemption RKCardSetRedemptionFromString (NSString *str) NS_REFINED_FOR_SWIFT;
RKFortifyRule RKFortifyRuleFromString (NSString *str) NS_REFINED_FOR_SWIFT;

NSString *NSStringFromInitialCountryDistribution (RKInitialCountryDistribution countryDistribution) NS_REFINED_FOR_SWIFT;
NSString *NSStringFromInitialArmyPlacement (RKInitialArmyPlacement armyPlacement) NS_REFINED_FOR_SWIFT;
NSString *NSStringFromCardSetRedemption (RKCardSetRedemption cardSetRedemption) NS_REFINED_FOR_SWIFT;
NSString *NSStringFromFortifyRule (RKFortifyRule fortifyRule) NS_REFINED_FOR_SWIFT;

NSString *NSStringFromRiskCardType (RKCardType cardType) NS_REFINED_FOR_SWIFT;
NSString *NSStringFromGameState (RKGameState gameState) NS_REFINED_FOR_SWIFT;
NSString *RKGameStateInfo (RKGameState gameState) NS_REFINED_FOR_SWIFT;

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

#if defined(RK_INCLUDE_DEPRECATED) && RK_INCLUDE_DEPRECATED
static const RKCardType Wildcard API_DEPRECATED_WITH_REPLACEMENT("RKCardWildcard", macosx(10.0, 10.9)) = RKCardWildcard;
static const RKCardType Soldier API_DEPRECATED_WITH_REPLACEMENT("RKCardSoldier", macosx(10.0, 10.9)) = RKCardSoldier;
static const RKCardType Cannon API_DEPRECATED_WITH_REPLACEMENT("RKCardCannon", macosx(10.0, 10.9)) = RKCardCannon;
static const RKCardType Cavalry API_DEPRECATED_WITH_REPLACEMENT("RKCardCavalry", macosx(10.0, 10.9)) = RKCardCavalry;

static const RiskContinent Unknown API_DEPRECATED_WITH_REPLACEMENT("RKContinentUnknown", macosx(10.0, 10.9)) = RiskContinentUnknown;
static const RiskContinent SouthAmerica API_DEPRECATED_WITH_REPLACEMENT("RKContinentSouthAmerica", macosx(10.0, 10.9)) = RiskContinentSouthAmerica;
static const RiskContinent NorthAmerica API_DEPRECATED_WITH_REPLACEMENT("RKContinentNorthAmerica", macosx(10.0, 10.9)) = RiskContinentNorthAmerica;
static const RiskContinent Europe API_DEPRECATED_WITH_REPLACEMENT("RKContinentEurope", macosx(10.0, 10.9)) = RiskContinentEurope;
static const RiskContinent Africa API_DEPRECATED_WITH_REPLACEMENT("RKContinentAfrica", macosx(10.0, 10.9)) = RiskContinentAfrica;
static const RiskContinent Asia API_DEPRECATED_WITH_REPLACEMENT("RKContinentAsia", macosx(10.0, 10.9)) = RiskContinentAsia;
static const RiskContinent Australia API_DEPRECATED_WITH_REPLACEMENT("RKContinentAustralia", macosx(10.0, 10.9)) = RiskContinentAustralia;

static const RKFortifyRule OneToOneNeighbor API_DEPRECATED_WITH_REPLACEMENT("RKFortifyRuleOneToOneNeighbor", macosx(10.0, 10.9)) = RKFortifyRuleOneToOneNeighbor;
static const RKFortifyRule OneToManyNeighbors API_DEPRECATED_WITH_REPLACEMENT("RKFortifyRuleOneToManyNeighbors", macosx(10.0, 10.9)) = RKFortifyRuleOneToManyNeighbors;
static const RKFortifyRule ManyToManyNeighbors API_DEPRECATED_WITH_REPLACEMENT("RKFortifyRuleManyToManyNeighbors", macosx(10.0, 10.9)) = RKFortifyRuleManyToManyNeighbors;
static const RKFortifyRule ManyToManyConnected API_DEPRECATED_WITH_REPLACEMENT("RKFortifyRuleManyToManyConnected", macosx(10.0, 10.9)) = RKFortifyRuleManyToManyConnected;

static const RKAttackMethod AttackOnce API_DEPRECATED_WITH_REPLACEMENT("RKAttackMethodOnce", macosx(10.0, 10.9)) = RKAttackMethodOnce;
static const RKAttackMethod AttackMultipleTimes API_DEPRECATED_WITH_REPLACEMENT("RKAttackMethodMultipleTimes", macosx(10.0, 10.9)) = RKAttackMethodMultipleTimes;
static const RKAttackMethod AttackUntilArmiesRemain API_DEPRECATED_WITH_REPLACEMENT("RKAttackMethodUntilArmiesRemain", macosx(10.0, 10.9)) = RKAttackMethodUntilArmiesRemain;
static const RKAttackMethod AttackUntilUnableToContinue API_DEPRECATED_WITH_REPLACEMENT("RKAttackMethodUntilUnableToContinue", macosx(10.0, 10.9)) = RKAttackMethodUntilUnableToContinue;

static const RKArmyPlacementType PlaceInAnyCountry API_DEPRECATED_WITH_REPLACEMENT("RKArmyPlacementAnyCountry", macosx(10.0, 10.9)) = RKArmyPlacementAnyCountry;
static const RKArmyPlacementType PlaceInTwoCountries API_DEPRECATED_WITH_REPLACEMENT("RKArmyPlacementTwoCountries", macosx(10.0, 10.9)) = RKArmyPlacementTwoCountries;
static const RKArmyPlacementType PlaceInOneNeighborCountry API_DEPRECATED_WITH_REPLACEMENT("RKArmyPlacementOneNeighborCountry", macosx(10.0, 10.9)) = RKArmyPlacementOneNeighborCountry;
static const RKArmyPlacementType PlaceInAnyNeighborCountry API_DEPRECATED_WITH_REPLACEMENT("RKArmyPlacementAnyNeighborCountry", macosx(10.0, 10.9)) = RKArmyPlacementAnyNeighborCountry;
static const RKArmyPlacementType PlaceInAnyConnectedCountry API_DEPRECATED_WITH_REPLACEMENT("RKArmyPlacementAnyConnectedCountry", macosx(10.0, 10.9)) = RKArmyPlacementAnyConnectedCountry;

static const RKInitialCountryDistribution PlayerChosen API_DEPRECATED_WITH_REPLACEMENT("RKInitialCountryDistributionPlayerChosen", macosx(10.0, 10.9)) = RKInitialCountryDistributionPlayerChosen;
static const RKInitialCountryDistribution RandomlyChosen API_DEPRECATED_WITH_REPLACEMENT("RKInitialCountryDistributionRandomlyChosen", macosx(10.0, 10.9)) = RKInitialCountryDistributionRandomlyChosen;

static const RKCardSetRedemption RemainConstant API_DEPRECATED_WITH_REPLACEMENT("RKCardSetRedemptionRemainConstant", macosx(10.0, 10.9)) = RKCardSetRedemptionRemainConstant;
static const RKCardSetRedemption IncreaseByOne API_DEPRECATED_WITH_REPLACEMENT("RKCardSetRedemptionIncreaseByOne", macosx(10.0, 10.9)) = RKCardSetRedemptionIncreaseByOne;
static const RKCardSetRedemption IncreaseByFive API_DEPRECATED_WITH_REPLACEMENT("RKCardSetRedemptionIncreaseByFive", macosx(10.0, 10.9)) = RKCardSetRedemptionIncreaseByFive;

static const RKInitialArmyPlacement PlaceByOnes API_DEPRECATED_WITH_REPLACEMENT("RKInitialArmyPlaceByOnes", macosx(10.0, 10.9)) = RKInitialArmyPlaceByOnes;
static const RKInitialArmyPlacement PlaceByThrees API_DEPRECATED_WITH_REPLACEMENT("RKInitialArmyPlaceByThrees", macosx(10.0, 10.9)) = RKInitialArmyPlaceByThrees;
static const RKInitialArmyPlacement PlaceByFives API_DEPRECATED_WITH_REPLACEMENT("RKInitialArmyPlaceByFives", macosx(10.0, 10.9)) = RKInitialArmyPlaceByFives;

static const RKGameState gs_no_game API_DEPRECATED_WITH_REPLACEMENT("RKGameStateNone", macosx(10.0, 10.9)) = RKGameStateNone;
static const RKGameState gs_establishing_game API_DEPRECATED_WITH_REPLACEMENT("RKGameStateEstablishingGame", macosx(10.0, 10.9)) = RKGameStateEstablishingGame;
static const RKGameState gs_choose_countries API_DEPRECATED_WITH_REPLACEMENT("RKGameStateChoosingCountries", macosx(10.0, 10.9)) = RKGameStateChoosingCountries;
static const RKGameState gs_place_initial_armies API_DEPRECATED_WITH_REPLACEMENT("RKGameStatePlaceInitialArmies", macosx(10.0, 10.9)) = RKGameStatePlaceInitialArmies;
static const RKGameState gs_place_armies API_DEPRECATED_WITH_REPLACEMENT("RKGameStatePlaceArmies", macosx(10.0, 10.9)) = RKGameStatePlaceArmies;
static const RKGameState gs_attack API_DEPRECATED_WITH_REPLACEMENT("RKGameStateAttack", macosx(10.0, 10.9)) = RKGameStateAttack;
static const RKGameState gs_move_attacking_armies API_DEPRECATED_WITH_REPLACEMENT("RKGameStateMoveAttackingArmies", macosx(10.0, 10.9)) = RKGameStateMoveAttackingArmies;
static const RKGameState gs_fortify API_DEPRECATED_WITH_REPLACEMENT("RKGameStateFortify", macosx(10.0, 10.9)) = RKGameStateFortify;
static const RKGameState gs_place_fortifying_armies API_DEPRECATED_WITH_REPLACEMENT("RKGameStatePlaceFortifyingArmies", macosx(10.0, 10.9)) = RKGameStatePlaceFortifyingArmies;
#endif
