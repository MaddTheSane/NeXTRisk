//
// $Id: RiskPlayer.h,v 1.6 1997/12/15 21:09:42 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

typedef NS_OPTIONS(uint32_t, CountryFlags) {
	CountryFlagsPlayerNone = 1 << 0,
	CountryFlagsPlayerOne = 1 << 1,
	CountryFlagsPlayerTwo = 1 << 2,
	CountryFlagsPlayerThree = 1 << 3,
	CountryFlagsPlayerFour = 1 << 4,
	CountryFlagsPlayerFive = 1 << 5,
	CountryFlagsPlayerSix = 1 << 6,
	CountryFlagsThisPlayer = 1 << 7,
	CountryFlagsWithTroops = 1 << 8,
	CountryFlagsWithoutTroops = 1 << 9,
	CountryFlagsWithMovableTroops = 1 << 10,
	CountryFlagsWithoutMovableTroops = 1 << 11,
	CountryFlagsWithEnemyNeighbors = 1 << 12,
	CountryFlagsWithoutEnemyNeighbors = 1 << 13,
};

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

- (NSString *) playerName;
- (Player) playerNumber;
- (NSArray *) playerCards;

- (NSMenu *) playerToolMenu;
- (void) setPlayerToolMenu:(NSMenu *)theMenu;

@property AttackMethod attackMethod;

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

- (NSSet<Country *> *) ourCountries;

// - ours AND has enemy neighbors AND has armies
// - ours OR enemies
- (NSSet<Country *> *) countriesWithAllOptions:(CountryFlags)options from:(NSSet<Country *> *)source;
- (NSSet<Country *> *) countriesWithAnyOptions:(CountryFlags)options from:(NSSet<Country *> *)source;

- (BOOL) hasCountriesWithAllOptions:(CountryFlags)options from:(NSSet<Country *> *)source;
- (BOOL) hasCountriesWithAnyOptions:(CountryFlags)options from:(NSSet<Country *> *)source;

- (NSSet<Country *> *) chooseCountriesInContinentNamed:(NSString *)continentName from:(NSSet<Country *> *)source;
- (NSSet<Country *> *) removeCountriesInContinentNamed:(NSString *)continentName from:(NSSet<Country *> *)source;

//======================================================================
// Card set methods
//======================================================================

- (NSSet<CardSet*> *) allOurCardSets;
- (CardSet *) bestSet;
- (BOOL) canTurnInCardSet;

//======================================================================
// Console
//======================================================================

- (IBAction) showConsolePanel:sender;
- (void) logMessage:(NSString *)format, ...;

- (void) waitForContinue;
- (IBAction) continueAction:sender;
- (IBAction) pauseCheckAction:sender;

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
- (void) moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination;
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
