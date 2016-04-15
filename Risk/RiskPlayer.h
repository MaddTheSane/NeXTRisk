//
// $Id: RiskPlayer.h,v 1.6 1997/12/15 21:09:42 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

#define OPT_PLAYER_NONE             (1 << 0)
#define OPT_PLAYER_ONE              (1 << 1)
#define OPT_PLAYER_TWO              (1 << 2)
#define OPT_PLAYER_THREE            (1 << 3)
#define OPT_PLAYER_FOUR             (1 << 4)
#define OPT_PLAYER_FIVE             (1 << 5)
#define OPT_PLAYER_SIX              (1 << 6)
#define OPT_THIS_PLAYER             (1 << 7)
#define OPT_WITH_TROOPS             (1 << 8)
#define OPT_WITHOUT_TROOPS          (1 << 9)
#define OPT_WITH_MOVABLE_TROOPS     (1 << 10)
#define OPT_WITHOUT_MOVABLE_TROOPS  (1 << 11)
#define OPT_WITH_ENEMY_NEIGHBORS    (1 << 12)
#define OPT_WITHOUT_ENEMY_NEIGHBORS (1 << 13)

@class RiskGameManager, Country, RiskCard, CardSet;
@class SNRandom;

@interface RiskPlayer : NSObject
{
    NSString *playerName;
    Player playerNumber;
    NSMutableArray *playerCards;

    RiskGameManager *gameManager;

    // Default attack method (and optional value)
    AttackMethod attackMethod;
    int attackMethodValue;

    NSMenu *playerToolMenu;

    // Console
    IBOutlet NSWindow *consoleWindow;
    IBOutlet NSTextView *consoleMessageText;
    IBOutlet NSButton *continueButton;
    IBOutlet NSButton *pauseForContinueButton;

    // For convenient access to a random number generator
    SNRandom *rng;
}

+ (void) load;
+ (void) initialize;

- initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager;
- (void) dealloc;

- (NSString *) playerName;
- (Player) playerNumber;
- (NSArray *) playerCards;

- (NSMenu *) playerToolMenu;
- (void) setPlayerToolMenu:(NSMenu *)theMenu;

- (AttackMethod) attackMethod;
- (void) setAttackMethod:(AttackMethod)newMethod;

- (int) attackMethodValue;
- (void) setAttackMethodValue:(int)newValue;

- (void) addCardToHand:(RiskCard *)newCard;
- (void) removeCardFromHand:(RiskCard *)aCard;

- (SNRandom *) rng;

- (void) turnDone;

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry;
- (void) mouseUp:(NSEvent *)theEvent inCountry:(Country *)aCountry;

- (void) windowWillClose:(NSNotification *)aNotification;

//======================================================================
// General methods for players
//======================================================================

- (NSSet *) ourCountries;

// - ours AND has enemy neighbors AND has armies
// - ours OR enemies
- (NSSet *) countriesWithAllOptions:(int)options from:(NSSet *)source;
- (NSSet *) countriesWithAnyOptions:(int)options from:(NSSet *)source;

- (BOOL) hasCountriesWithAllOptions:(int)options from:(NSSet *)source;
- (BOOL) hasCountriesWithAnyOptions:(int)options from:(NSSet *)source;

- (NSSet *) chooseCountriesInContinentNamed:(NSString *)continentName from:(NSSet *)source;
- (NSSet *) removeCountriesInContinentNamed:(NSString *)continentName from:(NSSet *)source;

//======================================================================
// Card set methods
//======================================================================

- (NSSet *) allOurCardSets;
- (CardSet *) bestSet;
- (BOOL) canTurnInCardSet;

//======================================================================
// Console
//======================================================================

- (void) showConsolePanel:sender;
- (void) logMessage:(NSString *)format, ...;

- (void) waitForContinue;
- (void) continueAction:sender;
- (void) pauseCheckAction:sender;

//======================================================================
// Subclass Responsibilities
//======================================================================

- (BOOL) isInteractive;

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

- (void) mayTurnInCards; // Allows computer players to turn in card before they get -placeArmies:
- (void) mustTurnInCards;
- (void) didTurnInCards:(int)extraArmyCount;

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

- (void) willBeginChoosingCountries;
- (void) chooseCountry;
- (void) willEndChoosingCountries;

- (void) willBeginPlacingInitialArmies;
- (void) placeInitialArmies:(int)count;
- (void) willEndPlacingInitialArmies;

- (void) youLostGame;
- (void) youWonGame;

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

- (void) willBeginTurn;

- (void) placeArmies:(int)count;
- (void) attackPhase;
- (void) moveAttackingArmies:(int)count between:(Country *)source:(Country *)destination;
- (void) fortifyPhase:(FortifyRule)fortifyRule;
- (void) placeFortifyingArmies:(int)count fromCountry:(Country *)source;

- (void) willEndTurn;

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

- (void) playerNumber:(Player)number attackedCountry:(Country *)attackedCountry;
- (void) playerNumber:(Player)number capturedCountry:(Country *)capturedCountry;

@end
