//
// $Id: RiskGameManager.h,v 1.3 1997/12/15 21:09:39 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

#define MAX_PLAYERS 7

extern NSString *RGMGameOverNotification;

@class RiskWorld, RiskPlayer, GameConfiguration, Country, RiskMapView, StatusView, ArmyView, CardPanelController;
@class RiskCard, ArmyPlacementValidator, CardSet, DiceInspector, WorldInfoController, SNRandom;

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

    // Game state
    GameState gameState;
    Player currentPlayerNumber;

    // Place armies phase:
    int initialArmyCount;

    // Keep track of armies left for current player in this turn.
    int armiesLeftToPlace;
    ArmyPlacementValidator *armyPlacementValidator;

    BOOL playerHasConqueredCountry;

    // Card management
    IBOutlet CardPanelController *cardPanelController;
    IBOutlet NSWindow *cardPanelWindow;
    NSMutableArray *cardDeck;
    NSMutableArray *discardDeck;
    int nextCardSetValue;

    // For verifying that armies before fortification == armies after fortification
    int armiesBefore;

    DiceInspector *diceInspector;
    WorldInfoController *worldInfoController;

    SNRandom *rng;
}

+ (void) initialize;

- init;
- (void) dealloc;
- (void) awakeFromNib;

- (void) _logGameState;

- (void) showControlPanel:sender;
- (void) showDiceInspector:sender;
- (void) showWorldInfoPanel:sender;

- (BOOL) validateMenuItem:(NSMenuItem *)menuCell;

// Delegate of RiskMapView.
- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry;

//======================================================================
// General access to world data
//======================================================================

- (RiskWorld *) world;
- (void) setWorld:(RiskWorld *)newWorld;

- (GameConfiguration *) gameConfiguration;
- (void) setGameConfiguration:(GameConfiguration *)newGameConfiguration;

- (GameState) gameState;

//======================================================================
// For status view.
//======================================================================

- (BOOL) isPlayerActive:(Player)number;
- (Player) currentPlayerNumber;
- (int) activePlayerCount;

- (RiskPlayer *) playerNumber:(Player)number;

//======================================================================
// Player menu support
//======================================================================

- (void) showPlayerConsole:sender;

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

- (BOOL) gameInProgress;

- (void) enteringChooseCountriesPhase;
- (void) leavingChooseCountriesPhase;
- (void) enteringInitialArmyPlacementPhase;
- (void) leavingInitialArmyPlacementPhase;

- (void) endTurn;
- (void) executeCurrentPhase:sender;
- (BOOL) nextActivePlayer;

- (void) fortify:sender;
- (void) endTurn:sender;

- (void) moveAttackingArmies:(int)minimum between:(Country *)source:(Country *)destination;
- (void) fortifyArmiesFrom:(Country *)source;
- (void) forceCurrentPlayerToTurnInCards;

- (void) resetMovableArmiesForPlayerNumber:(Player)number;

//======================================================================
// Choose countries
//======================================================================

- (BOOL) player:(RiskPlayer *)aPlayer choseCountry:(Country *)country;
- (NSArray *) unoccupiedCountries; // Better in RiskWorld?
- (void) randomlyChooseCountriesForActivePlayers;

//======================================================================
// Place Armies and Move Attacking armies
//======================================================================

- (BOOL) player:(RiskPlayer *)aPlayer placesArmies:(int)count inCountry:(Country *)country;

//======================================================================
// Attacking
//======================================================================

- (AttackResult) attackUntilUnableToContinueFromCountry:(Country *)attacker
                                              toCountry:(Country *)defender
                               moveAllArmiesUponVictory:(BOOL)moveFlag;

- (AttackResult) attackMultipleTimes:(int)count
                         fromCountry:(Country *)attacker
                           toCountry:(Country *)defender
            moveAllArmiesUponVictory:(BOOL)moveFlag;

- (AttackResult) attackFromCountry:(Country *)attacker
                         toCountry:(Country *)defender
                 untilArmiesRemain:(int)count
          moveAllArmiesUponVictory:(BOOL)moveFlag;

- (AttackResult) attackOnceFromCountry:(Country *)attacker
                             toCountry:(Country *)defender
              moveAllArmiesUponVictory:(BOOL)moveFlag;

//======================================================================
// Game Manager calculations
//======================================================================

- (int) earnedArmyCountForPlayer:(Player)number;
- (DiceRoll) rollDiceWithAttackerArmies:(int)attackerArmies defenderArmies:(int)defenderArmies;

//======================================================================
// General player interaction
//======================================================================

- (void) selectCountry:(Country *)aCountry;
- (void) takeAttackMethodFromPlayerNumber:(Player)number;
- (void) setAttackMethodForPlayerNumber:(Player)number;
- (void) setAttackingFromCountryName:(NSString *)string;

- (void) attackMethodAction:sender;

- (void) setArmiesLeftToPlace:(int)count;

//======================================================================
// Card management
//======================================================================

- (void) _recycleDiscardedCards;
- (void) dealCardToPlayerNumber:(Player)number;
- (int) _valueOfNextCardSet:(int)currentValue;
- (int) armiesForNextCardSet;
- (void) turnInCardSet:(CardSet *)cardSet forPlayerNumber:(Player)number;
- (void) automaticallyTurnInCardsForPlayerNumber:(Player)number;
- (void) transferCardsFromPlayer:(RiskPlayer *)source toPlayer:(RiskPlayer *)destination;

// For the currently active (interactive) player
- (void) reviewCards:sender;
- (void) turnInCards:sender;

- (void) _loadCardPanel;

//======================================================================
// Other
//======================================================================

- (void) updatePhaseBox;
- (int) totalTroopsForPlayerNumber:(Player)number;

- (void) defaultsChanged:(NSNotification *)aNotification;

//======================================================================
// End of game stuff:
//======================================================================

- (BOOL) checkForEndOfPlayerNumber:(Player)number;
- (void) playerHasLost:(Player)number;
- (void) playerHasWon:(Player)number;
- (void) deactivatePlayerNumber:(Player)number;

@end
