// Diagnostic.h
// Part of Risk by Mike Ferris

// This ComputerPlayer is stupid, but it implements an important functionality
// for ComputerPlayer designers.  It provides a debugging window taylored for
// providing pertinent info about what's going on in the player.

#import "ComputerPlayer.h"

@interface Diagnostic:ComputerPlayer
{
	id  diagnosticPanel;
	id  myPlayerNumForm;
	id  functionCalledForm;
	id	args1Form;
	id  args2Form;
	id  returnValueForm;
	id  notesScrollText;
	id  continueButton;
	id	pauseContinueButton;
	
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

@end
