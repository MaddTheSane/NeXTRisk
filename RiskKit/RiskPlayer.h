//
// $Id: RiskPlayer.h,v 1.6 1997/12/15 21:09:42 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/NSObject.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSTextView.h>

#import "Risk.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(uint32_t, RKCountryFlags) {
	RKCountryFlagsPlayerNone = 1 << 0,
	RKCountryFlagsPlayerOne = 1 << 1,
	RKCountryFlagsPlayerTwo = 1 << 2,
	RKCountryFlagsPlayerThree = 1 << 3,
	RKCountryFlagsPlayerFour = 1 << 4,
	RKCountryFlagsPlayerFive = 1 << 5,
	RKCountryFlagsPlayerSix = 1 << 6,
	RKCountryFlagsThisPlayer = 1 << 7,
	RKCountryFlagsWithTroops = 1 << 8,
	RKCountryFlagsWithoutTroops = 1 << 9,
	RKCountryFlagsWithMovableTroops = 1 << 10,
	RKCountryFlagsWithoutMovableTroops = 1 << 11,
	RKCountryFlagsWithEnemyNeighbors = 1 << 12,
	RKCountryFlagsWithoutEnemyNeighbors = 1 << 13,
};

@class RiskGameManager, RKCountry, RKCard, RKCardSet;
@class SNRandom;

/// The RiskPlayer is the base class for all players, both human and
/// computer.  It has generally useful methods, and defines methods
/// the subclasses must implement to provide behavior for distinct
/// parts of game play.
@interface RiskPlayer : NSObject <NSWindowDelegate> {
@protected
    NSString *playerName;
    RKPlayer playerNumber;
    NSMutableArray<RKCard*> *playerCards;
    
    RiskGameManager *gameManager;
    
    // Default attack method (and optional value)
    RKAttackMethod attackMethod;
    int attackMethodValue;
    
    __weak NSMenu *playerToolMenu;
    
    // Console
    IBOutlet NSWindow *consoleWindow;
    IBOutlet NSTextView *consoleMessageText;
    IBOutlet NSButton *continueButton;
    IBOutlet NSButton *pauseForContinueButton;
    
    // For convenient access to a random number generator
    SNRandom *rng;
}

@property (readonly, strong) RiskGameManager *gameManager;

/// Initializes a newly allocated \c RiskPlayer with the given name and
/// number.  The controlling game manager is also saved so that the
/// player can access it during the game.
- (instancetype)initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, copy) NSString *playerName;
@property (readonly) RKPlayer playerNumber;
@property (readonly, copy) NSArray<RKCard*> * playerCards;

/// The Player N menu under the Tool menu for this player.  This
/// allows players easy access for adding new menu items.  Each player
/// always starts out with one menu item to display the Console window.
@property (weak, nullable) NSMenu *playerToolMenu;

/// The default attack method.  This is used mostly by the Human
/// player.
@property RKAttackMethod attackMethod;

/// The value associated with the default attack method.  This is
/// used mostly by the Human player.
@property int attackMethodValue;

- (void) addCardToHand:(RKCard *)newCard;
- (void) removeCardFromHand:(RKCard *)aCard;

//! For convenient access to a random number generator
@property (readonly, strong) SNRandom *rng;

/// The player should call this function at the end of certain phases in
/// order to continue game play.  This is required, as interactive
/// players normally aren't finished the current phase when these
/// functions return.  This is required for the following methods:
///     -placeInitialArmies:
///     -placeArmies:
///     -attackPhase
///     -moveAttackingArmies:between::
///     -fortifyPhase:
///     -placeFortifyingArmies:fromCountry:
///
- (void) turnDone;

- (void) mouseDown:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry;
- (void) mouseUp:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry;

- (void) windowWillClose:(NSNotification *)aNotification;

//======================================================================
// General methods for players
//======================================================================

@property (readonly, copy) NSSet<RKCountry *> *ourCountries;

// - ours AND has enemy neighbors AND has armies
// - ours OR enemies

/// Returns a set of countries from the source set that satisfy all the
/// given options.  The options are the bitwise OR of the \c RKCountryFlags constants
/// that are defined in RiskPlayer.h.
///
/// Note that not all combinations make sense.  For example, no country
/// can be occupied by both player three and player four.
- (NSSet<RKCountry *> *) countriesWithAllOptions:(RKCountryFlags)options from:(NSSet<RKCountry *> *)source;
/// Returns a set of countries from the source set that satisfy any of
/// the given options.  The options are the bitwise OR of the \c RKCountryFlags
/// constants that are defined in RiskPlayer.h.
- (NSSet<RKCountry *> *) countriesWithAnyOptions:(RKCountryFlags)options from:(NSSet<RKCountry *> *)source;

/// Returns \c YES if any of the countries from the source set satisfies
/// all of the given options.  The options are the bitwise OR of the
/// \c RKCountryFlags constants that are defined in RiskPlayer.h.
///
/// Note that not all combinations make sense.  For example, no country
/// can be occupied by both player three and player four.
- (BOOL) hasCountriesWithAllOptions:(RKCountryFlags)options from:(NSSet<RKCountry *> *)source;
/// Returns \c YES if any of the countries from the source set satisfies
/// any of the given options.  The options are the bitwise OR of the
/// \c RKCountryFlags constants that are defined in RiskPlayer.h.
- (BOOL) hasCountriesWithAnyOptions:(RKCountryFlags)options from:(NSSet<RKCountry *> *)source;

/// Returns a set of countries from the source set that are also in the
/// named continent.
- (NSSet<RKCountry *> *) chooseCountriesInContinentNamed:(NSString *)continentName from:(NSSet<RKCountry *> *)source NS_SWIFT_NAME(chooseCountries(inContinent:from:));
/// Returns a set of countries from the source set, ensuring that none
/// are in the named continent.
- (NSSet<RKCountry *> *) removeCountriesInContinentNamed:(NSString *)continentName from:(NSSet<RKCountry *> *)source NS_SWIFT_NAME(removeCountries(inContinent:from:));

//======================================================================
// Card set methods
//======================================================================

/// Returns a set of all the valid card sets from this player's hand.
@property (readonly, copy) NSSet<RKCardSet *> *allOurCardSets;
/// Returns the best set to turn in.  To determine which of all possible
/// sets is best, this method looks for the set:
///     1) with the least jokers in it, and
///     2) with the most countries that this player occupies
/// It does not take into account things like the proximity of the
/// countries to the action or anything amorphous like that.
@property (readonly, strong, nullable) RKCardSet *bestSet;
/// Returns \c YES if this player has at least one valid card set.
@property (readonly) BOOL canTurnInCardSet;

//======================================================================
// Console
//======================================================================

- (IBAction) showConsolePanel:(nullable id)sender;
/// Appends a formatted string to the console window, if it is visible.
/// Subclasses can use this to show debugging information.
- (void) logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
/// Appends a formatted string to the console window, if it is visible.
/// Subclasses can use this to show debugging information.
- (void) logMessage:(NSString *)format format:(va_list)vaList NS_FORMAT_FUNCTION(1,0);

- (void) waitForContinue;
- (IBAction) continueAction:(nullable id)sender;
- (IBAction) pauseCheckAction:(nullable id)sender;

//======================================================================
// Subclass Responsibilities
//======================================================================

/// Returns \c YES if this is an interactive player that will use the
/// shared panels to direct movement.  Human's implementation returns
/// <code>YES</code>; only subclasses that want to use the shared panels and refine
/// the interactive behavior should override this method to return <code>YES</code>.
@property (readonly, getter=isInteractive) BOOL interactive;

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

/// @brief Allows computer players to turn in card before they get \c -placeArmies:
///
/// Notifies the player at the beginning of a turn that it has at least
/// one card set that may be turned in.  This allows computer players to
/// turn in cards before they get the \c -placeArmies: message.  If the
/// player has more than four cards, \c -mustTurnInCards is called instead.
- (void) mayTurnInCards;
/// Notifies the player at the beginning of a turn that it must turn in
/// card sets.  This happens when the player has more than four cards.
/// If a player still doesn't turn in cards, some cards will
/// automatically be turned in before continuing.
- (void) mustTurnInCards;
/// Notifies the player about the number of extra armies that were
/// awarded as a result of turning in a card set.  This is useful for
/// the Human player to allow it to update the number of armies left to
/// place, since it turns in cards after receiving the \c -placeArmies:
/// message.
- (void) didTurnInCards:(RKArmyCount)extraArmyCount;

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

/// Notifies the player that the players will begin choosing countries.
/// Currently, this is called before <b>any</b> player has chosen a country.
- (void) willBeginChoosingCountries;
/// The player should choose a single unoccupied country by calling
/// <code>RiskGameManager -player:choseCountry:</code>.
- (void) chooseCountry;
/// Notifies the player that all of the countries have been chosen.
- (void) willEndChoosingCountries;

/// Notifies the player that the players will begin placing the initial
/// armies.  Currently, this is called before <b>any</b> player has placed
/// initial armies.
- (void) willBeginPlacingInitialArmies;
/// The player should place \c count armies among any of their countries
/// by calling <code>RiskGameManager -player:placesArmies:inCountry:</code>, and then
/// call <code>self -turnDone</code>.
- (void) placeInitialArmies:(RKArmyCount)count;
/// Notifies the player that all of the players have finished placing
/// their initial armies.
- (void) willEndPlacingInitialArmies;

/// Notifies the player that they have lost the game.
- (void) youLostGame;
/// Notifies the player that they have won the game.
- (void) youWonGame;

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

/// Notifies the player that their turn will begin.
- (void) willBeginTurn;

/// Notifies the player that they should place \c count armies among any
/// of their countries by calling
/// <code>RiskGameManager -player:placesArmies:inCountry:</code>, and then call
/// <code>self -turnDone</code>.
- (void) placeArmies:(RKArmyCount)count;
/// Notifies the player that they may attack other players.  When done,
/// it should call <code>self -turnDone</code>.
- (void) attackPhase;
/// Notifies the player that they should distribute \c count armies
/// between the source and destination countries.  This is the result of
/// a successful attack.  The minimum number of armies have already been
/// moved into the destination country.  When done, it should call
/// <code>self -turnDone</code>.
- (void) moveAttackingArmies:(RKArmyCount)count between:(RKCountry *)source :(RKCountry *)destination;
/// Notifies the player that they may fortify armies under the given
/// <code>fortifyRule</code>.  The player may call \c -turnDone to skip fortification,
/// or call <code>RiskGameManager -fortifyArmiesFrom:</code> to specify the source
/// country for fortification. If multiple sources are allowed, this
/// method will be called again, otherwise the game will automatically
/// proceed to the next phase.
///
/// Call either \c -turnDone or \c -fortifyArmiesFrom:
- (void) fortifyPhase:(RKFortifyRule)fortifyRule;
/// Notifies the player that they should place \c count fortifying armies
/// from the source country by calling
/// <code>RiskGameManager -player:placesArmies:inCountry:</code>, and then call
/// <code>self -turnDone</code>.  The current fortify rule will determine the valid
/// destination countries.  Armies that are not placed will be lost.
- (void) placeFortifyingArmies:(RKArmyCount)count fromCountry:(RKCountry *)source;

/// Notifies the player that their turn has ended.
- (void) willEndTurn;

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

/// Notifies this player that player \c number attacked one of this
/// players countries, attackedCountry.  An advanced computer player
/// could use this information, for example, to bias future attacks
/// against the most antagonistic player.
- (void) playerNumber:(RKPlayer)number attackedCountry:(RKCountry *)attackedCountry;
/// Notifies this player that player \c number captured one of this
/// players cuntries, capturedCountry.  An advanced computer player
/// could use this information, for example, to bias future attacks
/// against the most antagonistic player.
- (void) playerNumber:(RKPlayer)number capturedCountry:(RKCountry *)capturedCountry;

@end

NS_ASSUME_NONNULL_END
