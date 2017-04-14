// ComputerPlayer.h
// Part of Risk by Mike Ferris

// Abstract superclass for Risk Computer Players
//
// Implements methods to interface with the rest of Risk and
// defines subclass responsibility.  Speaking of responsibility, it
// is possible to cheat from a computer player.  This means it is your
// responsibility as the programmer of a custom Computer Player to be careful
// not to cheat.  I have tried to outline areas where you should be a little
// careful below.  You should read all the comments in this header.
//
// Things for subclasses to watch out for:
// * place all your armies
// * always turn in cards if you have 5 or more
// * be careful when moving armies to make only legal moves


#import <objc/Object.h>
#import "Card.h"
#import "Country.h"
#import "Random.h"

// Continent constants
#define NORTH_AMERICA	0
#define SOUTH_AMERICA	1
#define EUROPE			2
#define AFRICA			3
#define ASIA			4
#define AUSTRALIA		5

// These are the fortify rules returned by the fortifyRule method.
#define FR_NIL				-1	//Invalid garbage.
#define FR_ONE_ONE_N		0	//Fortify from only one country into only
								// only one neighboring country.
#define FR_ONE_MANY_N		1	//Fortify from only one country into as
								// many neighboring countries as you want.
#define FR_MANY_MANY_N		2	//Fortify from as many countries as you
								// want into as many neighboring countries
								// as you want.
#define FR_MANY_MANY_C		3	//Fortify from as many countries as you
								// want into as many connected countries
								// as you want.

@interface ComputerPlayer:Object
{
	// your player number (indexed from zero and going in the order
	// from the set up panel)  This number is needed internally by
	// ComputerPlayer to interface with Risk.  It is automatically set
	// on object creation.
	int myPlayerNum;
	
	// the is a random number generator of the Random class
	// you may use it (as outlined in the Random.h file
	id rng;
	
	// outlets to key information and service providers within Risk
	// If you mess directly with these guys, you're on your own!
	id theMover;
	id theGameSetup;
	id theMapView;
	id theCardManager;
	
}

+ initialize;

- init;
- initPlayerNum:(int)pnum mover:mover gameSetup:gamesetup mapView:mapview
				cardManager:cardmanager;
- free;

// *****************subclass responsibilities*********************

// yourChooseCountry is called when it's your turn to choose a country.
// You should choose a country by calling occupyCountry, and that's all.
- yourChooseCountry;

// yourInitialPlaceArmies is called when it's your turn to place armies
// before the game proper starts.  You should place numArmies armies
// in your countries and that's all.
- yourInitialPlaceArmies:(int)numArmies;

// yourTurn is called when it's your turn to move.
// At the very least you should place numArmies armies in your countries
// and turn in cards if you have 5 or more.  You can also optionally turn 
// in cards if you have 3 or 4 cards from which a set can be made
// and/or attack other players and/or fortify your position.
// If you don't place all your armies, they're gone.  If you place
// more than numArmies armies, you're cheating.  Bad things could
// theoretically happen if you hold cards until you have lots of them
// (say 20-30), and the rules say you must play if you have five or
// more at any time until you have less than five.
- yourTurnWithArmies:(int)numArmies andCards:(int)numCards;

// youWereAttacked is called every time someone attacks you.
// It tells you where you were attacked, and by whom.
// You can store this information and seek vengeance next time your turn
// comes around or just ignore it.  If you try to do "move" things from this 
// method (attacking, placing armies, moving armies, etc...), you are not only
// cheating, but you can really screw things up too.
- youWereAttacked:country by:(int)player;

// youLostCountry is called every time someone conquers one of your countries.
// It tells you what was lost, and who took it.
// You can store this information and seek vengeance next time your turn
// comes around or just ignore it.  If you try to do "move" things from this 
// method (attacking, placing armies, moving armies, etc...), you are not only
// cheating, but you can really screw things up too.
- youLostCountry:country to:(int)player;

// *****************map utilities*********************

// You can find out about the countries by querying the Country objects.  
// ***  NEVER FREE THE COUNTRY OBJECTS***ALWAYS FREE RETURNED LISTS  ***
- countryList;  // returns a List of all the countries.
- myCountries;  // returns a List of your countries.
- myCountriesWithAvailableArmies; // returns a list of your countries which
								  // have more than one army.
- neighborsTo:country;  // returns a List of neighbors to the given country
- countriesInContinent:(int)continent;  // returns a list of all the countries
										// in the given continent.
- playersCountries:(int)pnum;  // returns a list of the given players countries
- unoccupiedCountries;  // returns a list of all unoccupied countries
- (BOOL)occupyCountry:country;  // occupies country placing one army in it

// *****************card utilities*********************

// You can find out about the cards by querying the Card objects.
// ***  NEVER FREE THE CARD OBJECTS***ALWAYS FREE RETURNED LISTS  ***
- myCards;  // returns a list of all your cards
- allMyCardSets;	// returns a Storage object of arrays of cards.
				// each array contains a set of cards.  All possible sets
				// are returned.  Used be bestSet.
- bestSet;  // returns a list of three cards which will result in the most
			// armies out of the cards you have.  If you don't have a set
			// of cards that can be turned in this returns nil.
- (int)playCards:cardList;  // card list should be three cards which make a
							// set.  Returns the number of armies you get
							// for the set.  Returns -1 if the cards didn't
							// make a set.

// *****************place army utilities*********************

// placeArmies increases the number of armies in country by numArmies.
// Returns NO and does nothing if it isn't your country.
// Returns YES if successful.
// This method allows you to CHEAT.  You can place as many armies as you
// want whenever you want.  BE CAREFUL.
- (BOOL)placeArmies:(int)numArmies inCountry:country;

// *****************attack utilities*********************

// All the attack methods return a BOOL which signifies if the attack took 
// place.  Attacks can fail to take place because you don't occupy the
// fromCountry, or because you do own the toCountry, or because the
// fromCountry has only one army.  All versions take the fromCountry and the
// toCountry as arguments.  Two take an integer to control how many times
// or how long to attack.  All versions return several values through
// pointer arguments which are only significant if the method returns YES:
// victory -    a BOOL signifying whether the attacked country was conquered.
// fromArmies - an int.  The number of armies left in the the fromCountry
//				after the attack.  If victory is YES then as many as all but
//				one of these armies can be moved to toCountry if desired.
// toArmies -   an int.  If victory is YES then this number is how many of
//				your armies were moved from fromCountry into toCountry upon
//				conquest.  If victory is NO then this number is how many
//				of the opponent's armies remain in the toCountry after the
//				attack.
// vanquished - a BOOL.  If victory is YES then this signifies whether
//				you totally vanquished the opposing player.  If this
//				is YES then you may have acquired cards.  If you end up with 
//				more than 5 cards, you must play some cards immediately.
// wewin -      a BOOL.  If vanquished is YES, and the player you vanquished
//				has been annihilated, this will be YES.  Otherwise NO.

- (BOOL)attackOnceFrom:fromCountry to:toCountry 
					victory:(BOOL *)victory fromArmies:(int *)fromArmies 
					toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					weWin:(BOOL *)wewin;
- (BOOL)attackTimes:(int)times from:fromCountry to:toCountry 
					victory:(BOOL *)victory fromArmies:(int *)fromArmies 
					toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					weWin:(BOOL *)wewin;
- (BOOL)attackUntilLeft:(int)untilLeft from:fromCountry to:toCountry 
					victory:(BOOL *)victory fromArmies:(int *)fromArmies 
					toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					weWin:(BOOL *)wewin;
- (BOOL)attackUntilCantFrom:fromCountry to:toCountry 
					victory:(BOOL *)victory fromArmies:(int *)fromArmies 
					toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					weWin:(BOOL *)wewin;

// *****************post-attack & fortify utilities*********************

// moveArmies returns YES or NO depending on whether the move was possible.
// It is impossible to move armies if you don't own both the fromCountry
// and the toCountry or if there aren't at least numArmies+1 armies in 
// fromCountry.
// Moves numArmies armies from fromCountry to toCountry.
// Possible CHEATER alert.  This does not and cannot check to see if the
// move is legal.  You must check before you call to make sure it is legal.
// Use this method to move more than the minimum number of armies into a newly 
// conquered country, or to fortify your position at the end of your turn.
- (BOOL)moveArmies:(int)numArmies from:fromCountry to:toCountry;

// Returns the fortify rule in effect.  It's a bit of a bother to have to
// check and abide by this rule, and you don't strictly have to, but a well-
// mannered computer player will play by the rules.  At least distinguish 
// whether you are allowed to fortify from only one country (the first two 
// fortify rules) or multiple countries (the second two rules).
- (int)fortifyRule;

@end
