// Coop.h
// Part of Risk by Mike Ferris

// This ComputerPlayer is stupid, but it implements an important functionality
// for ComputerPlayer designers.  It provides a debugging window taylored for
// providing pertinent info about what's going on in the player.

#import "Chaotic.h" //"ComputerPlayer.h"
#import <Cocoa/Cocoa.h>
@class Continent;

@interface Coop:Chaotic   //ComputerPlayer
{
	IBOutlet NSWindow		*diagnosticPanel;
	IBOutlet NSForm			*myPlayerNumForm;
	IBOutlet NSForm			*functionCalledForm;
	IBOutlet NSForm			*args1Form;
	IBOutlet NSForm			*args2Form;
	IBOutlet NSForm			*returnValueForm;
	IBOutlet NSScrollView	*notesScrollText;
	IBOutlet NSButton		*pauseContinueButton;
}

- (instancetype)initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager;

// *****************subclass responsibilities*********************

- (void)chooseCountry;
- (void)placeInitialArmies:(RiskArmyCount)count;
- (void)placeArmies:(RiskArmyCount)count;

- yourTurnWithArmies:(RiskArmyCount)numArmies andCards:(int)numCards;
- (void)playerNumber:(Player)number attackedCountry:(Country *)attackedCountry;
- (void)playerNumber:(Player)number capturedCountry:(Country *)capturedCountry;

// *****************country utilities*********************

- (BOOL)occupyCountry:(Country*)country;
/*! return id of adjacent country, which belongs to enemy and has most inferior
 * number of armies compared to number of armieas of country.
 * If no adjacent enemy countries exist, return country itself
 */
- (Country*)findAdjacentEnemyCountryMostInferiorTo: country;
/*! return id of adjacent country, which belongs to enemy and has most superior
 * number of armies compared to number of armieas of country.
 * If no adjacent enemy countries exist, return country itself
 */
- (Country*)findAdjacentEnemyCountryMostSuperiorTo: country;
/*! return id of my country which has most superior enemy of all my countries.
 * else return nil
 */
- (Country*)findMyCountryWithMostSuperiorEnemy;
/*! return id of my country which has most inferior enemy of all my countries.
 * else return nil
 */
- (Country*)findMyCountryWithMostInferiorEnemy;

// *****************attack utilities*********************

//! repeatedly attack from country with relatively weakest enemy
- (BOOL)attackFromLeastThreatenedCountryUntilLeft: (int)untilLeft;

//! repeatedly attack from country with largest enemy
//! (but do not neccessarily attack largest enemy)
- (BOOL)attackFromMostThreatenedCountryUntilLeft: (int)untilLeft;

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

- (void)waitForContinue;
- (IBAction)continueAction:sender;
- (IBAction)checkAction:sender;
- (void)clearArgForms;
- (void)setNotes:(NSString *)noteText;

// *** Helper functions ***
- (NSArray<Country*>*)enemyNeighborsToCountry:(Country*)country;

@end
