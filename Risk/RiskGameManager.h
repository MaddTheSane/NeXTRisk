//
// $Id: RiskGameManager.h,v 1.3 1997/12/15 21:09:39 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

#define MAX_PLAYERS 7

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const RGMGameOverNotification;

@class RiskWorld, RiskPlayer, GameConfiguration, Country, RiskMapView, StatusView, ArmyView, CardPanelController;
@class RiskCard, ArmyPlacementValidator, CardSet, DiceInspector, WorldInfoController, SNRandom;

//! The \c RiskGameManager controls most of the game play.  It notifies
//! the players of the various phases of game play, and does some
//! checking of messages to try to limit invalid actions by players (or
//! some cheating.)
@interface RiskGameManager : NSObject
{
    RiskWorld *world;
    GameConfiguration *configuration;

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
    GameState gameState;
    Player currentPlayerNumber;

    //! Place armies phase:
    RiskArmyCount initialArmyCount;

    // Keep track of armies left for current player in this turn.
    RiskArmyCount armiesLeftToPlace;
    ArmyPlacementValidator *armyPlacementValidator;

    BOOL playerHasConqueredCountry;

    // Card management
    IBOutlet CardPanelController *cardPanelController;
    IBOutlet NSWindow *cardPanelWindow;
    NSMutableArray *cardDeck;
    NSMutableArray *discardDeck;
    RiskArmyCount nextCardSetValue;

    //! For verifying that armies before fortification == armies after fortification
    RiskArmyCount armiesBefore;

    DiceInspector *diceInspector;
    WorldInfoController *worldInfoController;

    SNRandom *rng;
}

- (instancetype)init;

- (void) _logGameState;

- (IBAction) showControlPanel:(nullable id)sender;
- (IBAction) showDiceInspector:(nullable id)sender;
- (IBAction) showWorldInfoPanel:(nullable id)sender;

- (BOOL) validateMenuItem:(NSMenuItem *)menuCell;

// Delegate of RiskMapView.
- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry;

//======================================================================
// General access to world data
//======================================================================

@property (nonatomic, strong) RiskWorld *world;

@property (nonatomic, strong) GameConfiguration *gameConfiguration;

@property (readonly) GameState gameState;

//======================================================================
// For status view.
//======================================================================

- (BOOL) isPlayerActive:(Player)number;
@property (readonly) Player currentPlayerNumber;
@property (readonly) int activePlayerCount;

- (RiskPlayer *) playerNumber:(Player)number;

//======================================================================
// Player menu support
//======================================================================

- (IBAction) showPlayerConsole:(nullable id)sender;

//======================================================================
// Establish Game
//======================================================================

- (void) startNewGame;
- (BOOL) addPlayer:(RiskPlayer *)aPlayer number:(Player)number;
- (void) beginGame;
- (void) tryToStart;
- (void) stopGame;

//======================================================================
// Game State
//======================================================================

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

- (void) moveAttackingArmies:(RiskArmyCount)minimum between:(Country *)source :(Country *)destination;
- (void) fortifyArmiesFrom:(Country *)source;
- (void) forceCurrentPlayerToTurnInCards;

- (void) resetMovableArmiesForPlayerNumber:(Player)number;

//======================================================================
// Choose countries
//======================================================================

- (BOOL) player:(RiskPlayer *)aPlayer choseCountry:(Country *)country;
@property (readonly, copy) NSArray<Country *> *unoccupiedCountries; // Better in RiskWorld?
- (void) randomlyChooseCountriesForActivePlayers;

//======================================================================
// Place Armies and Move Attacking armies
//======================================================================

- (BOOL) player:(RiskPlayer *)aPlayer placesArmies:(RiskArmyCount)count inCountry:(Country *)country;

//======================================================================
// Attacking
//======================================================================

- (AttackResult) attackUntilUnableToContinueFromCountry:(Country *)attacker
                                              toCountry:(Country *)defender
                               moveAllArmiesUponVictory:(BOOL)moveFlag;

- (AttackResult) attackMultipleTimes:(RiskArmyCount)count
                         fromCountry:(Country *)attacker
                           toCountry:(Country *)defender
            moveAllArmiesUponVictory:(BOOL)moveFlag;

- (AttackResult) attackFromCountry:(Country *)attacker
                         toCountry:(Country *)defender
                 untilArmiesRemain:(RiskArmyCount)count
          moveAllArmiesUponVictory:(BOOL)moveFlag;

- (AttackResult) attackOnceFromCountry:(Country *)attacker
                             toCountry:(Country *)defender
              moveAllArmiesUponVictory:(BOOL)moveFlag;

//======================================================================
// Game Manager calculations
//======================================================================

- (RiskArmyCount) earnedArmyCountForPlayer:(Player)number;
- (DiceRoll) rollDiceWithAttackerArmies:(RiskArmyCount)attackerArmies defenderArmies:(RiskArmyCount)defenderArmies;

//======================================================================
// General player interaction
//======================================================================

- (void) selectCountry:(Country *)aCountry;
- (void) takeAttackMethodFromPlayerNumber:(Player)number;
- (void) setAttackMethodForPlayerNumber:(Player)number;
- (void) setAttackingFromCountryName:(NSString *)string;

- (IBAction) attackMethodAction:(id)sender;

- (void) setArmiesLeftToPlace:(RiskArmyCount)count;

//======================================================================
// Card management
//======================================================================

- (void) _recycleDiscardedCards;
- (void) dealCardToPlayerNumber:(Player)number;
- (RiskArmyCount) _valueOfNextCardSet:(RiskArmyCount)currentValue;
- (RiskArmyCount) armiesForNextCardSet;
- (void) turnInCardSet:(CardSet *)cardSet forPlayerNumber:(Player)number;
- (void) automaticallyTurnInCardsForPlayerNumber:(Player)number;
- (void) transferCardsFromPlayer:(RiskPlayer *)source toPlayer:(RiskPlayer *)destination;

// For the currently active (interactive) player
- (IBAction) reviewCards:(nullable id)sender;
- (IBAction) turnInCards:(nullable id)sender;

- (void) _loadCardPanel;

//======================================================================
// Other
//======================================================================

- (void) updatePhaseBox;
- (RiskArmyCount) totalTroopsForPlayerNumber:(Player)number;

- (void) defaultsChanged:(NSNotification *)aNotification;

//======================================================================
// End of game stuff:
//======================================================================

- (BOOL) checkForEndOfPlayerNumber:(Player)number;
- (void) playerHasLost:(Player)number;
- (void) playerHasWon:(Player)number;
- (void) deactivatePlayerNumber:(Player)number;

@end

NS_ASSUME_NONNULL_END
