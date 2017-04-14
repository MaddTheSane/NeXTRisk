// Chaotic.h
// Part of Risk by Mike Ferris

// Chaotic is the first full-featured Computer Player I wrote.  It provides 
// examples of writing new utility functions to further refine lists
// available with the Computer Player object.  It also shows several examples
// of other neat stuff.  Pay attention to when I free lists!

#import "ComputerPlayer.h" //"Diagnostic.h"

@interface Chaotic:ComputerPlayer //Diagnostic
{
	// I use this new instance variable to try to occupy one country
	// in each continent at the beginning of the game.
	BOOL countryInContinent[6];
}

// it's a good idea to hae this method if only to set the classes version
+ initialize;

// I want to initialize my instance variables
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

// my own utilities, based on the utilities in ComputerPlayer, but taylored
// to the needs of this strategy.
- enemyNeighborsTo:country;
- myNonLandLockedCountriesCapableOfAttack:(BOOL)attack;
- (int)turnInCards;
- (BOOL)placeArmies:(int)numArmies;

// this function implements a chaotic attack from a single country
// it handles everything, and returns whether the game is over.
- (BOOL)doAttackFrom:fromc;

// this method implements fortifying at the end of the turn.  It handles 
// everything.
- fortifyPosition;
- fortifyArmies:(int)numArmies from:country;

@end
