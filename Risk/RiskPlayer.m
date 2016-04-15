//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskPlayer.m,v 1.7 1997/12/15 21:09:43 nygard Exp $");

#import "RiskPlayer.h"

#import "RiskGameManager.h"
#import "Country.h"
#import "RiskWorld.h"
#import "SNRandom.h"
#import "RiskCard.h"
#import "CardSet.h"

//======================================================================
// The RiskPlayer is the base class for all players, both human and
// computer.  It has generally useful methods, and defines methods
// the subclasses must implement to provide behavior for distinct
// parts of game play.
//======================================================================

#define RiskPlayer_VERSION 1

@implementation RiskPlayer
@synthesize rng;
@synthesize gameManager;
@synthesize playerToolMenu;
@synthesize attackMethod;
@synthesize attackMethodValue;
@synthesize playerName;
@synthesize playerNumber;

+ (void) load
{
    //NSLog (@"RiskPlayer.");
}

//----------------------------------------------------------------------

+ (void) initialize
{
    if (self == [RiskPlayer class])
    {
        [self setVersion:RiskPlayer_VERSION];
    }
}

//----------------------------------------------------------------------
// Initializes a newly allocated RiskPlayer with the given name and
// number.  The controlling game manager is also saved so that the
// player can access it during the game.
//----------------------------------------------------------------------

- initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager
{
    if ([super init] == nil)
        return nil;

    playerName = [aName retain];
    playerNumber = number;
    playerCards = [[NSMutableArray array] retain];
    gameManager = [aManager retain];

    attackMethod = AttackOnce;
    attackMethodValue = 1;

    consoleWindow = nil;
    consoleMessageText = nil;
    continueButton = nil;
    pauseForContinueButton = nil;

    playerToolMenu = nil;

    rng = [[SNRandom instance] retain];

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (playerName);
    SNRelease (gameManager);
    SNRelease (playerCards);
    SNRelease (rng);

    if (consoleWindow != nil)
    {
        // What happens to a window that is already closed when it gets this message?
        [consoleWindow setReleasedWhenClosed:YES];
        [continueButton setEnabled:NO];
        [pauseForContinueButton setEnabled:NO];
    }

    [super dealloc];
}

//----------------------------------------------------------------------

- (NSArray *) playerCards
{
    return playerCards;
}

//----------------------------------------------------------------------

- (void) addCardToHand:(RiskCard *)newCard
{
    [playerCards addObject:newCard];
}

//----------------------------------------------------------------------

- (void) removeCardFromHand:(RiskCard *)aCard
{
    [playerCards removeObject:aCard];
}

//----------------------------------------------------------------------
// The player should call this function at the end of certain phases in
// order to continue game play.  This is required, as interactive
// players normally aren't finished the current phase when these
// functions return.  This is required for the following methods:
//
//     -placeInitialArmies:
//     -placeArmies:
//     -attackPhase
//     -moveAttackingArmies:between::
//     -fortifyPhase:
//     -placeFortifyingArmies:fromCountry:
//
//----------------------------------------------------------------------

- (void) turnDone
{
    [gameManager endTurn];
}

//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry
{
}

//----------------------------------------------------------------------

- (void) mouseUp:(NSEvent *)theEvent inCountry:(Country *)aCountry
{
}

//----------------------------------------------------------------------

- (void) windowWillClose:(NSNotification *)aNotification
{
    // Stop pausing if we close the window, otherwise we're stuck!
    if ([aNotification object] == consoleWindow && [pauseForContinueButton state] == 1)
    {
        [NSApp stopModal];
        [pauseForContinueButton setState:0];
        [continueButton setEnabled:NO];
    }
}

//======================================================================
// General methods for players
//======================================================================

- (NSSet *) ourCountries
{
    return [[gameManager world] countriesForPlayer:playerNumber];
}

//----------------------------------------------------------------------
// Returns a set of countries from the source set that satisfy all the
// given options.  The options are the bitwise OR of the OPT_ constants
// that are defined in RiskPlayer.h.
//
// Note that not all combinations make send.  For example, no country
// can be occupied by both player three and player four.
//----------------------------------------------------------------------

- (NSSet *) countriesWithAllOptions:(CountryFlags)options from:(NSSet *)source
{
    NSEnumerator *countryEnumerator;
    NSMutableSet *resultingSet;
    Country *country;

    Player number;
    int troopCount, movableTroopCount;
    BOOL hasEnemyNeighbors;
    resultingSet = [NSMutableSet set];
    countryEnumerator = [source objectEnumerator];
    for (country in source)
    {
        number = [country playerNumber];
        troopCount = [country troopCount];
        movableTroopCount = [country movableTroopCount];
        hasEnemyNeighbors = [country hasEnemyNeighbors];

        if (((options & CountryFlagsPlayerNone) && number != 0)
            || ((options & CountryFlagsPlayerOne) && number != 1)
            || ((options & CountryFlagsPlayerTwo) && number != 2)
            || ((options & CountryFlagsPlayerThree) && number != 3)
            || ((options & CountryFlagsPlayerFour) && number != 4)
            || ((options & CountryFlagsPlayerFive) && number != 5)
            || ((options & CountryFlagsPlayerSix) && number != 6)
            || ((options & CountryFlagsThisPlayer) && number != playerNumber)
            || ((options & CountryFlagsWithTroops) && troopCount < 1)
            || ((options & CountryFlagsWithoutTroops) && troopCount > 0)
            || ((options & CountryFlagsWithMovableTroops) && movableTroopCount < 1)
            || ((options & CountryFlagsWithoutMovableTroops) && movableTroopCount > 0)
            || ((options & CountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == NO)
            || ((options & CountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == YES))
        {
            continue;
        }

        [resultingSet addObject:country];
    }
    
    return resultingSet;
}

//----------------------------------------------------------------------
// Returns a set of countries from the source set that satisfy any of
// the given options.  The options are the bitwise OR of the OPT_
// constants that are defined in RiskPlayer.h.
//----------------------------------------------------------------------

- (NSSet *) countriesWithAnyOptions:(CountryFlags)options from:(NSSet *)source
{
    NSEnumerator *countryEnumerator;
    NSMutableSet *resultingSet;
    Country *country;

    Player number;
    int troopCount, movableTroopCount;
    BOOL hasEnemyNeighbors;

    resultingSet = [NSMutableSet set];
    countryEnumerator = [source objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        number = [country playerNumber];
        troopCount = [country troopCount];
        movableTroopCount = [country movableTroopCount];
        hasEnemyNeighbors = [country hasEnemyNeighbors];

        if (((options & CountryFlagsPlayerNone) && number == 0)
            || ((options & CountryFlagsPlayerOne) && number == 1)
            || ((options & CountryFlagsPlayerTwo) && number == 2)
            || ((options & CountryFlagsPlayerThree) && number == 3)
            || ((options & CountryFlagsPlayerFour) && number == 4)
            || ((options & CountryFlagsPlayerFive) && number == 5)
            || ((options & CountryFlagsPlayerSix) && number == 6)
            || ((options & CountryFlagsThisPlayer) && number == playerNumber)
            || ((options & CountryFlagsWithTroops) && troopCount > 0)
            || ((options & CountryFlagsWithoutTroops) && troopCount < 1)
            || ((options & CountryFlagsWithMovableTroops) && movableTroopCount > 0)
            || ((options & CountryFlagsWithoutMovableTroops) && movableTroopCount < 1)
            || ((options & CountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == YES)
            || ((options & CountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == NO))
        {
            [resultingSet addObject:country];
        }
    }
    
    return resultingSet;
}

//----------------------------------------------------------------------
// Returns YES if any of the countries from the source set satisfies
// all of the given options.  The options are the bitwise OR of the
// OPT_ constants that are defined in RiskPlayer.h.
//
// Note that not all combinations make send.  For example, no country
// can be occupied by both player three and player four.
//----------------------------------------------------------------------

- (BOOL) hasCountriesWithAllOptions:(CountryFlags)options from:(NSSet *)source
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;

    Player number;
    int troopCount, movableTroopCount;
    BOOL hasEnemyNeighbors;

    flag = NO;

    countryEnumerator = [source objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        number = [country playerNumber];
        troopCount = [country troopCount];
        movableTroopCount = [country movableTroopCount];
        hasEnemyNeighbors = [country hasEnemyNeighbors];

        if (((options & CountryFlagsPlayerNone) && number != 0)
            || ((options & CountryFlagsPlayerOne) && number != 1)
            || ((options & CountryFlagsPlayerTwo) && number != 2)
            || ((options & CountryFlagsPlayerThree) && number != 3)
            || ((options & CountryFlagsPlayerFour) && number != 4)
            || ((options & CountryFlagsPlayerFive) && number != 5)
            || ((options & CountryFlagsPlayerSix) && number != 6)
            || ((options & CountryFlagsThisPlayer) && number != playerNumber)
            || ((options & CountryFlagsWithTroops) && troopCount < 1)
            || ((options & CountryFlagsWithoutTroops) && troopCount > 0)
            || ((options & CountryFlagsWithMovableTroops) && movableTroopCount < 1)
            || ((options & CountryFlagsWithoutMovableTroops) && movableTroopCount > 0)
            || ((options & CountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == NO)
            || ((options & CountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == YES))
        {
            continue;
        }

        flag = YES;
        break;
    }

    return flag;
}

//----------------------------------------------------------------------
// Returns YES if any of the countries from the source set satisfies
// any of the given options.  The options are the bitwise OR of the
// OPT_ constants that are defined in RiskPlayer.h.
//----------------------------------------------------------------------

- (BOOL) hasCountriesWithAnyOptions:(CountryFlags)options from:(NSSet *)source
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;

    Player number;
    int troopCount, movableTroopCount;
    BOOL hasEnemyNeighbors;

    flag = NO;
    countryEnumerator = [source objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        number = [country playerNumber];
        troopCount = [country troopCount];
        movableTroopCount = [country movableTroopCount];
        hasEnemyNeighbors = [country hasEnemyNeighbors];

        if (((options & CountryFlagsPlayerNone) && number == 0)
            || ((options & CountryFlagsPlayerOne) && number == 1)
            || ((options & CountryFlagsPlayerTwo) && number == 2)
            || ((options & CountryFlagsPlayerThree) && number == 3)
            || ((options & CountryFlagsPlayerFour) && number == 4)
            || ((options & CountryFlagsPlayerFive) && number == 5)
            || ((options & CountryFlagsPlayerSix) && number == 6)
            || ((options & CountryFlagsThisPlayer) && number == playerNumber)
            || ((options & CountryFlagsWithTroops) && troopCount > 0)
            || ((options & CountryFlagsWithoutTroops) && troopCount < 1)
            || ((options & CountryFlagsWithMovableTroops) && movableTroopCount > 0)
            || ((options & CountryFlagsWithoutMovableTroops) && movableTroopCount < 1)
            || ((options & CountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == YES)
            || ((options & CountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == NO))
        {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

//----------------------------------------------------------------------
// Returns a set of countries from the source set that are also in the
// named continent.
//----------------------------------------------------------------------

- (NSSet *) chooseCountriesInContinentNamed:(NSString *)continentName from:(NSSet *)source
{
    NSEnumerator *countryEnumerator;
    NSMutableSet *resultingSet;
    Country *country;

    resultingSet = [NSMutableSet set];
    countryEnumerator = [source objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if ([[country continentName] isEqualToString:continentName] == YES)
            [resultingSet addObject:country];
    }
    
    return resultingSet;
}

//----------------------------------------------------------------------
// Returns a set of countries from the source set, ensuring that none
// are in the named continent.
//----------------------------------------------------------------------

- (NSSet *) removeCountriesInContinentNamed:(NSString *)continentName from:(NSSet *)source
{
    NSEnumerator *countryEnumerator;
    NSMutableSet *resultingSet;
    Country *country;

    resultingSet = [NSMutableSet set];
    countryEnumerator = [source objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if ([[country continentName] isEqualToString:continentName] == NO)
            [resultingSet addObject:country];
    }
    
    return resultingSet;
}

//======================================================================
// Card set methods
//======================================================================

//----------------------------------------------------------------------
// Returns a set of all the valid card sets from this player's hand.
//----------------------------------------------------------------------

- (NSSet *) allOurCardSets
{
    NSMutableSet *allCardSets;
    NSInteger i, j, k;
    NSInteger count;
    RiskCard *card1, *card2, *card3;
    CardSet *cardSet;

    count = [playerCards count];

    allCardSets = [NSMutableSet set];

    for (i = 0; i < count; i++)
    {
        card1 = [playerCards objectAtIndex:i];
        for (j = i + 1; j < count; j++)
        {
            card2 = [playerCards objectAtIndex:j];
            for (k = j + 1; k < count; k++)
            {
                card3 = [playerCards objectAtIndex:k];

                cardSet = [CardSet cardSet:card1:card2:card3];
                if (cardSet != nil)
                    [allCardSets addObject:cardSet];
            }
        }
    }

    return allCardSets;
}

//----------------------------------------------------------------------
// Returns the best set to turn in.  To determine which of all possible
// sets is best, this method looks for the set:
//     1) with the least jokers in it, and
//     2) with the most countries that this player occupies
// It does not take into account things like the proximity of the
// countries to the action or anything amorphous like that.
//----------------------------------------------------------------------

- (CardSet *) bestSet
{
    CardSet *bestSet;
    NSSet *allSets;
    NSEnumerator *cardSetEnumerator;
    CardSet *cardSet;

    bestSet = nil;
    allSets = [self allOurCardSets];
    cardSetEnumerator = [allSets objectEnumerator];

    while (cardSet = [cardSetEnumerator nextObject])
    {
        if (compareCardSetValues (cardSet, bestSet, (void *)playerNumber) == NSOrderedAscending)
            bestSet = cardSet;
    }

    return bestSet;
}

//----------------------------------------------------------------------
// Returns YES if this player has at least one valid card set.
//----------------------------------------------------------------------

- (BOOL) canTurnInCardSet
{
    NSInteger i, j, k;
    NSInteger count;
    RiskCard *card1, *card2, *card3;
    BOOL hasValidSet;

    hasValidSet = NO;
    count = [playerCards count];

    for (i = 0; hasValidSet == NO && i < count; i++)
    {
        card1 = [playerCards objectAtIndex:i];
        for (j = i + 1; hasValidSet == NO && j < count; j++)
        {
            card2 = [playerCards objectAtIndex:j];
            for (k = j + 1; k < count; k++)
            {
                card3 = [playerCards objectAtIndex:k];

                if ([CardSet isValidCardSet:card1:card2:card3] == YES)
                {
                    hasValidSet = YES;
                    break;
                }
            }
        }
    }

    return hasValidSet;
}

//======================================================================
// Console
//======================================================================

- (void) showConsolePanel:sender
{
    NSString *nibFile;
    BOOL loaded;
    
    if (consoleWindow == nil)
    {
        nibFile = @"PlayerConsole";
        loaded = [NSBundle loadNibNamed:nibFile owner:self];

        NSAssert1 (loaded == YES, @"Could not load %@.", nibFile);

        [consoleWindow setTitle:[NSString stringWithFormat:@"Player %ld Console", (long)playerNumber]];
    }

    [consoleWindow orderFront:self];
}

//----------------------------------------------------------------------
// Appends a formatted string to the console window, if it is visible.
// Subclasses can use this to show debugging information.
//----------------------------------------------------------------------

- (void) logMessage:(NSString *)format, ...
{
	va_list ap;
	va_start(ap, format);
	[self logMessage:format format:ap];
	va_end(ap);
}

- (void) logMessage:(NSString *)format format:(va_list)ap
{
	NSRange selected;
	NSMutableString *str;
	
	if (consoleMessageText != nil)
	{
		str = [[[NSMutableString alloc] initWithFormat:format arguments:ap] autorelease];
		[str appendString:@"\n"];
		
		[consoleMessageText selectAll:nil];
		selected = [consoleMessageText selectedRange];
		selected.location = selected.length;
		selected.length = 0;
		[consoleMessageText setSelectedRange:selected];
		[consoleMessageText replaceCharactersInRange:selected withString:str];
		[consoleMessageText scrollRangeToVisible:selected];
		
		if ([pauseForContinueButton state] == 1)
			[self waitForContinue];
	}
}

//----------------------------------------------------------------------

- (void) waitForContinue
{
    [consoleWindow orderFront:self];
    [NSApp runModalForWindow:consoleWindow];
}

//----------------------------------------------------------------------

- (void) continueAction:sender
{
    [NSApp stopModal];
}

//----------------------------------------------------------------------

- (void) pauseCheckAction:sender
{
    [NSApp stopModal];

    if ([sender state] == 1)
    {
        [continueButton setEnabled:YES];
    }
    else
    {
        [continueButton setEnabled:NO];
    }
}

//======================================================================
// Subclass Responsibilities
//======================================================================

//----------------------------------------------------------------------
// Returns YES if this is an interactive player that will use the
// shared panels to direct movement.  Human's implementation returns
// YES; only subclasses that want to use the shared panels and refine
// the interactive behavior should override this method to return YES.
//----------------------------------------------------------------------

- (BOOL) isInteractive
{
    return NO;
}

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Notifies the player at the beginning of a turn that it has at least
// one card set that may be turned in.  This allows computer players to
// turn in cards before they get the -placeArmies: message.  If the
// player has more than four cards, -mustTurnInCards is called instead.
//----------------------------------------------------------------------

- (void) mayTurnInCards
{
}

//----------------------------------------------------------------------
// Notifies the player at the beginning of a turn that it must turn in
// card sets.  This happens when the player has more than four cards.
// If a player still doesn't turn in cards, some cards will
// automatically be turned in before continuing.
//----------------------------------------------------------------------

- (void) mustTurnInCards
{
}

//----------------------------------------------------------------------
// Notifies the player about the number of extra armies that were
// awarded as a result of turning in a card set.  This is useful for
// the Human player to allow it to update the number of armies left to
// place, since it turns in cards after receiving the -placeArmies:
// message.
//----------------------------------------------------------------------

- (void) didTurnInCards:(int)extraArmyCount
{
}

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Notifies the player that the players will begin choosing countries.
// Currently, this is called before *any* player has chosen a country.
//----------------------------------------------------------------------

- (void) willBeginChoosingCountries
{
}

//----------------------------------------------------------------------
// The player should choose a single unoccupied country by calling
// RiskGameManager -player:choseCountry:.
//----------------------------------------------------------------------

- (void) chooseCountry
{
    NSArray *unoccupiedCountries;
    Country *country;

    unoccupiedCountries = [gameManager unoccupiedCountries];
    country = [unoccupiedCountries objectAtIndex:[[self rng] randomNumberModulo:[unoccupiedCountries count]]];

    [gameManager player:self choseCountry:country];
    // Possible to choose more than one country...

    [self turnDone];
}

//----------------------------------------------------------------------
// Notifies the player that all of the countries have been chosen.
//----------------------------------------------------------------------

- (void) willEndChoosingCountries
{
}

//----------------------------------------------------------------------
// Notifies the player that the players will begin placing the initial
// armies.  Currently, this is called before *any* player has placed
// initial armies.
//----------------------------------------------------------------------

- (void) willBeginPlacingInitialArmies
{
}

//----------------------------------------------------------------------
// The player should place 'count' armies among any of their countries
// by calling RiskGameManager -player:placesArmies:inCountry:, and then
// call self -turnDone.
//----------------------------------------------------------------------

- (void) placeInitialArmies:(int)count
{
    [self turnDone];
}

//----------------------------------------------------------------------
// Notifies the player that all of the players have finished placing
// their initial armies.
//----------------------------------------------------------------------

- (void) willEndPlacingInitialArmies
{
}

//----------------------------------------------------------------------
// Notifies the player that they have lost the game.
//----------------------------------------------------------------------

- (void) youLostGame
{
    //NSLog (@"(%d) %@ has lost the game.", playerNumber, playerName);
}

//----------------------------------------------------------------------
// Notifies the player that they have won the game.
//----------------------------------------------------------------------

- (void) youWonGame
{
    //NSLog (@"(%d) %@ has won the game.", playerNumber, playerName);
}

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Notifies the player that their turn will begin.
//----------------------------------------------------------------------

- (void) willBeginTurn
{
}

//----------------------------------------------------------------------
// Notifies the player that they should place 'count' armies among any
// of their countries by calling
// RiskGameManager -player:placesArmies:inCountry:, and then call
// self -turnDone.
//----------------------------------------------------------------------

- (void) placeArmies:(int)count
{
    [self turnDone];
}

//----------------------------------------------------------------------
// Notifies the player that they may attack other players.  When done,
// it should call self -turnDone.
//----------------------------------------------------------------------

- (void) attackPhase
{
    [self turnDone];
}

//----------------------------------------------------------------------
// Notifies the player that they should distribute 'count' armies
// between the source and destination countries.  This is the result of
// a successful attack.  The minimum number of armies have already been
// moved into the destination country.  When done, it should call
// self -turnDone.
//----------------------------------------------------------------------

- (void) moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination
{
    [self turnDone];
}

//----------------------------------------------------------------------
// Notifies the player that they may fortify armies under the given
// 'fortifyRule'.  The player may call -turnDone to skip fortification,
// or call RiskGameManager -fortifyArmiesFrom: to specify the source
// country for fortification. If multiple sources are allowed, this
// method will be called again, otherwise the game will automatically
// proceed to the next phase.
//----------------------------------------------------------------------
// Call either -turnDone or -fortifyArmiesFrom:

- (void) fortifyPhase:(FortifyRule)fortifyRule
{
    [self turnDone];
}

//----------------------------------------------------------------------
// Notifies the player that they should place 'count' fortifying armies
// from the source country by calling
// RiskGameManager -player:placesArmies:inCountry:, and then call
// self -turnDone.  The current fortify rule will determine the valid
// destination countries.  Armies that are not placed will be lost.
//----------------------------------------------------------------------

- (void) placeFortifyingArmies:(int)count fromCountry:(Country *)source
{
    [self turnDone];
}

//----------------------------------------------------------------------
// Notifies the player that their turn has ended.
//----------------------------------------------------------------------

- (void) willEndTurn
{
}

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

//----------------------------------------------------------------------
// Notifies this player that player 'number' attacked one of this
// players countries, attackedCountry.  An advanced computer player
// could use this information, for example, to bias future attacks
// against the most antagonistic player.
//----------------------------------------------------------------------

- (void) playerNumber:(Player)number attackedCountry:(Country *)attackedCountry
{
}

//----------------------------------------------------------------------
// Notifies this player that player 'number' captured one of this
// players cuntries, capturedCountry.  An advanced computer player
// could use this information, for example, to bias future attacks
// against the most antagonistic player.
//----------------------------------------------------------------------

- (void) playerNumber:(Player)number capturedCountry:(Country *)capturedCountry
{
}

@end
