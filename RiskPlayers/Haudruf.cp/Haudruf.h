#import "ComputerPlayer.h"

@interface Haudruf:ComputerPlayer
{
	id  haudrufPanel;
	id  myPlayerNumForm;
	id  functionCalledForm;
	id	args1Form;
	id  args2Form;
	id  returnValueForm;
	id  notesScrollText;
	id  continueButton;
	id	pauseContinueButton;
	
	int numCountriesPerContinent[6]; // Anzahl meiner Laender pro Kontinent
	int	countriesInContinent[6][12]; // IDs meiner Laender in den Kontinenten
	BOOL gotContinent[6];
	int numGotContinents;
	int round;
	int turn;
	int initialContinent;
}

+ initialize;

- initPlayerNum:(int)pnum mover:mover gameSetup:gamesetup mapView:mapview
				cardManager:cardmanager;

// *****************subclass responsibilities*********************

- yourChooseCountry;
- yourInitialPlaceArmies:(int)numArmies;
- yourTurnWithArmies:(int)numArmies andCards:(int)numCards;
- youWereAttacked:country by:(int)player;
- youLostCountry:country to:(int)player;

// *****************country utilities*********************

- (BOOL)occupyCountry:country;

// *****************card utilities*********************

- (int)playCards:cardList;

// *****************place army utilities*********************

- (BOOL)placeArmies:(int)numArmies inCountry:country;

// *****************attack utilities*********************

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

- (BOOL)moveArmies:(int)numArmies from:fromCountry to:toCountry;

- waitForContinue;
- continueAction:sender;
- checkAction:sender;
- clearArgForms;
- setNotes:(const char *)noteText;

- calcNumCountriesPerContinent;
- (BOOL)countryInContinent:country :(int)continent;
- bestCountryFor:(int)continent;
- fortifyPosition;
- findBestVictimFor:country;
- klotzArmies:(int)armiesLeft;
- (int)conquerContinents:(int)armiesLeft;
- (int)stabilizeContinents:(int)armiesLeft;
- (int)defendContinent:(int)continent:(int)armiesLeft;
- (int)turnInCards;
- enemyNeighborsTo:country;
- getMaxArmyCountry;
- getCountryNamed:(char*)name;
- getMaxArmyWithEnemyCountry;
- (int) checkInitialContinent:(int) numArmies;

@end
