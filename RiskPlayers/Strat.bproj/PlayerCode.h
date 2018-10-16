// PlayerCode.h
// Part of Risk by Mike Ferris
// Based on Chaotic.h by Mike Ferris, modified by Royce Howland

// From Mike's original Chaotic.h:
// Chaotic is the first full-featured Computer Player I wrote.  It provides 
// examples of writing new utility functions to further refine lists
// available with the Computer Player object.  It also shows several examples
// of other neat stuff.  Pay attention to when I free lists!

#import "ComputerPlayer.h"
//#import "Diagnostic.h"

#define MINCOUNTRY 0
#define MAXCOUNTRY 41

@interface Strat:ComputerPlayer
//@interface Strat:Diagnostic
{
	// I use this new instance variable to try to occupy one country
	// in each continent at the beginning of the game.
	BOOL countryInContinent[6];

	// This array stores the number of countries on each continent that
	// border another continent.
	int continentExits[6];

	// This array stores, for each continent, the number of neighboring
	// countries on other continents.
	int continentNeighbors[6];

	// This array stores, for each continent, desirability fudge factor.
	// (One is used only at game start, to control initial continent
	// concentration if we get to pick our own countries.)
	int initContinentFudge[6];
	int continentFudge[6];

	// The following array associates a continent integer code (0 - 5)
	// with a country integer code (0 - 41), for fancy game player logic.
	int countryContinents[42];

	// The following array stores the number of neighbors per country.
	int countryNeighbors[42];

	// The following array stores the number of foreign neighbors (on
	// another continent) per country.
	int countryForeignNeighbors[42];

	// The following array stores the turn during which we conquered
	// each country.
	int turnCountryConquered[42];

	// This indicates if we've taken a country yet this turn.
	BOOL takenc;

	// This indicates how many turns since we took a country.
	int turnsSinceVict;

	// The number of turns played so far this game.
	int gameTurn;

	// The number of countries we had at the end of our last turn.
	int numCountriesLastTurn;

	// The country from which we're considering attacking somebody else.
	id theCountryOfAttack;

	// The current fronts of attack that we're concentrating on.
	int front1, front2, front3;

	// Flags indicating whether various feeps should be employed.
	BOOL banzaiMode, limitMode;
}

// it's a good idea to have this method if only to set the class' version
+ initialize;

// I want to initialize my instance variables.
- initPlayerNum:(int)pnum mover:mover gameSetup:gamesetup mapView:mapview
				cardManager:cardmanager;

// *****************subclass responsibilities*********************

- yourChooseCountry;
- yourInitialPlaceArmies:(int)numArmies;
- yourTurnWithArmies:(int)numArmies andCards:(int)numCards;

// this player doesn't implement the two optional methods.
// - youWereAttacked:country by:(int)player;
// - youLostCountry:country to:(int)player;

// *****************utilities*********************

// My own utilities, based on the utilities in ComputerPlayer, but tailored
// to the needs of this strategy.
- (BOOL)takenACountry;
- (float)ourPercentageOfContinent:(int)cont;
- (int)exitsOfContinent:(int)cont;
- (int)neighborsOfContinent:(int)cont;
- (int)fudgeOfContinent:(int)cont;
- countryOfAttack;
- (int)continentOfCountry:country;
- (int)frontOfCountry:country;
- (int)foreignNeighborsOfCountry:country;
- enemyNeighborsTo:country;
- (int)enemyArmiesAround:country;
- friendlyNeighborsTo:country;
- (int)friendlyArmiesAround:country;
- myCountriesCapableOfAttack:(BOOL)attack;
- (int)turnInCards;
- (BOOL)placeArmies:(int)numArmies;

// This function implements most attack logic from a single country;
// it returns whether the game is over.
- (BOOL)doAttackFrom:fromc victory:(BOOL *)victory;

// This method implements fortifying at the end of the turn.  It handles 
// everything.
- fortifyPosition;
- fortifyArmies:(int)numArmies from:country;

@end
