//
// $Id: RiskGameManager.h,v 1.3 1997/12/15 21:09:39 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import <RiskKit/Risk.h>

#define MAX_PLAYERS 7

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const RKGameOverNotification;

@class RiskWorld, RiskPlayer, RKGameConfiguration, RKCountry, RiskMapView, StatusView, ArmyView, RKCardPanelController;
@class RKCard, RKArmyPlacementValidator, RKCardSet, RKDiceInspector, RKWorldInfoController, SNRandom;

//! The \c RiskGameManager controls most of the game play.  It notifies
//! the players of the various phases of game play, and does some
//! checking of messages to try to limit invalid actions by players (or
//! some cheating.)
@interface RiskGameManager : NSObject
{
    RiskWorld *world;
    RKGameConfiguration *configuration;

    IBOutlet RiskMapView *mapView;
    IBOutlet NSTextField *countryNameTextField;
    IBOutlet NSWindow *mapWindow;
    IBOutlet NSWindow *controlPanel;
    IBOutlet NSMenu *toolMenu;

    // Outlets to the control panel views:
    IBOutlet StatusView *statusView;

    // Control Panel, Phase box
    IBOutlet NSTextField *nameTextField;
    IBOutlet NSTextField *phaseTextField;
    IBOutlet NSTextField *infoTextField;
    IBOutlet NSColorWell *playerColorWell;

    // outlets for interchangeable views in right section of control panel
    IBOutlet NSView *phaseComputerMove;
    IBOutlet NSView *phasePlaceArmies;
    IBOutlet NSView *phaseAttack;
    IBOutlet NSView *phaseFortify;
    IBOutlet NSView *phaseChooseCountries;
    NSView *currentPhaseView;
    
    // Place Armies phase
    IBOutlet NSTextField *initialArmiesLeftTextField;
    IBOutlet NSTextField *armiesLeftToPlaceTextField;
    IBOutlet NSButton *turnInCardsButton;
    IBOutlet ArmyView *armyView;

    // Attack phase
    IBOutlet NSPopUpButton *attackMethodPopup;
    IBOutlet NSSlider *methodCountSlider;
    IBOutlet NSTextField *methodCountTextField;
    IBOutlet NSTextField *attackingFromTextField;

    // Game Establishment
    int activePlayerCount;
    RiskPlayer *players[MAX_PLAYERS];
    BOOL playersActive[MAX_PLAYERS];

    //! Game state
    RKGameState gameState;
    RKPlayer currentPlayerNumber;

    //! Place armies phase:
    RKArmyCount initialArmyCount;

    // Keep track of armies left for current player in this turn.
    RKArmyCount armiesLeftToPlace;
    RKArmyPlacementValidator *armyPlacementValidator;

    BOOL playerHasConqueredCountry;

    // Card management
    IBOutlet RKCardPanelController *cardPanelController;
    IBOutlet NSWindow *cardPanelWindow;
    NSMutableArray<RKCard*> *cardDeck;
    NSMutableArray<RKCard*> *discardDeck;
    RKArmyCount nextCardSetValue;

    //! For verifying that armies before fortification == armies after fortification
    RKArmyCount armiesBefore;

    RKDiceInspector *diceInspector;
    RKWorldInfoController *worldInfoController;

    SNRandom *rng;
}

- (instancetype)init;

- (void) _logGameState;

- (IBAction) showControlPanel:(nullable id)sender;
- (IBAction) showDiceInspector:(nullable id)sender;
- (IBAction) showWorldInfoPanel:(nullable id)sender;

- (BOOL) validateMenuItem:(NSMenuItem *)menuCell;

// Delegate of RiskMapView.
- (void) mouseDown:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry;

#pragma mark General access to world data

@property (nonatomic, strong) RiskWorld *world;

@property (nonatomic, strong) RKGameConfiguration *gameConfiguration;

@property (readonly) RKGameState gameState;

#pragma mark For status view.

- (BOOL) isPlayerActive:(RKPlayer)number;
@property (readonly) RKPlayer currentPlayerNumber;
@property (readonly) int activePlayerCount;

- (RiskPlayer *) playerNumber:(RKPlayer)number;

#pragma mark Player menu support

- (IBAction) showPlayerConsole:(nullable id)sender;

#pragma mark Establish Game

- (void) startNewGame;
- (BOOL) addPlayer:(RiskPlayer *)aPlayer number:(RKPlayer)number;
- (void) beginGame;
- (void) tryToStart;
- (void) stopGame;

#pragma mark Game State

@property (readonly) BOOL gameInProgress;

- (void) enteringChooseCountriesPhase;
- (void) leavingChooseCountriesPhase;
- (void) enteringInitialArmyPlacementPhase;
- (void) leavingInitialArmyPlacementPhase;

- (void) endTurn;
- (IBAction) executeCurrentPhase:(nullable id)sender;

//! Advance to next active player (regardless of current phase)
//! Returns whether it wrapped.
- (BOOL) nextActivePlayer;

- (IBAction) fortify:(nullable id)sender;
- (IBAction) endTurn:(nullable id)sender;

- (void) moveAttackingArmies:(RKArmyCount)minimum between:(RKCountry *)source :(RKCountry *)destination;
- (void) fortifyArmiesFrom:(RKCountry *)source;
- (void) forceCurrentPlayerToTurnInCards;

- (void) resetMovableArmiesForPlayerNumber:(RKPlayer)number;

#pragma mark Choose countries

- (BOOL) player:(RiskPlayer *)aPlayer choseCountry:(RKCountry *)country;
@property (readonly, copy) NSArray<RKCountry *> *unoccupiedCountries; // Better in RiskWorld?
- (void) randomlyChooseCountriesForActivePlayers;

#pragma mark Place Armies and Move Attacking armies

- (BOOL) player:(RiskPlayer *)aPlayer placesArmies:(RKArmyCount)count inCountry:(RKCountry *)country;

#pragma mark Attacking

- (RKAttackResult) attackUntilUnableToContinueFromCountry:(RKCountry *)attacker
                                                toCountry:(RKCountry *)defender
                                 moveAllArmiesUponVictory:(BOOL)moveFlag;

- (RKAttackResult) attackMultipleTimes:(RKArmyCount)count
                           fromCountry:(RKCountry *)attacker
                             toCountry:(RKCountry *)defender
              moveAllArmiesUponVictory:(BOOL)moveFlag;

- (RKAttackResult) attackFromCountry:(RKCountry *)attacker
                           toCountry:(RKCountry *)defender
                   untilArmiesRemain:(RKArmyCount)count
            moveAllArmiesUponVictory:(BOOL)moveFlag;

- (RKAttackResult) attackOnceFromCountry:(RKCountry *)attacker
                               toCountry:(RKCountry *)defender
                moveAllArmiesUponVictory:(BOOL)moveFlag;

#pragma mark Game Manager calculations

- (RKArmyCount) earnedArmyCountForPlayer:(RKPlayer)number;
- (RKDiceRoll) rollDiceWithAttackerArmies:(RKArmyCount)attackerArmies defenderArmies:(RKArmyCount)defenderArmies;

#pragma mark General player interaction

- (void) selectCountry:(nullable RKCountry *)aCountry;
- (void) takeAttackMethodFromPlayerNumber:(RKPlayer)number;
- (void) setAttackMethodForPlayerNumber:(RKPlayer)number;
- (void) setAttackingFromCountryName:(NSString *)string;

- (IBAction) attackMethodAction:(id)sender;

- (void) setArmiesLeftToPlace:(RKArmyCount)count;

#pragma mark Card management

- (void) _recycleDiscardedCards;
- (void) dealCardToPlayerNumber:(RKPlayer)number;
- (RKArmyCount) _valueOfNextCardSet:(RKArmyCount)currentValue;
- (RKArmyCount) armiesForNextCardSet;
- (void) turnInCardSet:(RKCardSet *)cardSet forPlayerNumber:(RKPlayer)number;
- (void) automaticallyTurnInCardsForPlayerNumber:(RKPlayer)number;
- (void) transferCardsFromPlayer:(RiskPlayer *)source toPlayer:(RiskPlayer *)destination;

// For the currently active (interactive) player
- (IBAction) reviewCards:(nullable id)sender;
- (IBAction) turnInCards:(nullable id)sender;

- (void) _loadCardPanel;

#pragma mark Other

- (void) updatePhaseBox;
- (RKArmyCount) totalTroopsForPlayerNumber:(RKPlayer)number;

- (void) defaultsChanged:(NSNotification *)aNotification;

#pragma mark End of game stuff:

- (BOOL) checkForEndOfPlayerNumber:(RKPlayer)number;
- (void) playerHasLost:(RKPlayer)number;
- (void) playerHasWon:(RKPlayer)number;
- (void) deactivatePlayerNumber:(RKPlayer)number;

@end

NS_ASSUME_NONNULL_END
