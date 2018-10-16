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

- (instancetype)initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager;

// *****************subclass responsibilities*********************

- (void)chooseCountry;
- (void)placeInitialArmies:(RKArmyCount)count;
- (void)placeArmies:(RKArmyCount)count;

- yourTurnWithArmies:(RKArmyCount)numArmies andCards:(int)numCards;
- (void)playerNumber:(RKPlayer)number attackedCountry:(RKCountry *)attackedCountry;
- (void)playerNumber:(RKPlayer)number capturedCountry:(RKCountry *)capturedCountry;

// *****************country utilities*********************

- (BOOL)occupyCountry:(RKCountry*)country;
/*! return id of adjacent country, which belongs to enemy and has most inferior
 * number of armies compared to number of armieas of country.
 * If no adjacent enemy countries exist, return country itself
 */
- (RKCountry*)findAdjacentEnemyCountryMostInferiorTo:(RKCountry*) country;
/*! return id of adjacent country, which belongs to enemy and has most superior
 * number of armies compared to number of armieas of country.
 * If no adjacent enemy countries exist, return country itself
 */
- (RKCountry*)findAdjacentEnemyCountryMostSuperiorTo:(RKCountry*) country;
/*! return id of my country which has most superior enemy of all my countries.
 * else return nil
 */
- (RKCountry*)findMyCountryWithMostSuperiorEnemy;
/*! return id of my country which has most inferior enemy of all my countries.
 * else return nil
 */
- (RKCountry*)findMyCountryWithMostInferiorEnemy;

// *****************attack utilities*********************

//! repeatedly attack from country with relatively weakest enemy
- (BOOL)attackFromLeastThreatenedCountryUntilLeft: (int)untilLeft;

//! repeatedly attack from country with largest enemy
//! (but do not neccessarily attack largest enemy)
- (BOOL)attackFromMostThreatenedCountryUntilLeft: (int)untilLeft;

- (BOOL)attackOnceFrom:(RKCountry*)fromCountry to:(RKCountry*)toCountry
					victory:(BOOL *)victory fromArmies:(int *)fromArmies 
					toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					weWin:(BOOL *)wewin;
- (BOOL)attackTimes:(int)times from:(RKCountry*)fromCountry to:(RKCountry*)toCountry
					victory:(BOOL *)victory fromArmies:(int *)fromArmies 
					toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					weWin:(BOOL *)wewin;
- (BOOL)attackUntilLeft:(int)untilLeft from:(RKCountry*)fromCountry to:(RKCountry*)toCountry
					victory:(BOOL *)victory fromArmies:(int *)fromArmies 
					toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					weWin:(BOOL *)wewin;
- (BOOL)attackUntilCantFrom:(RKCountry*)fromCountry to:(RKCountry*)toCountry
					victory:(BOOL *)victory fromArmies:(int *)fromArmies 
					toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					weWin:(BOOL *)wewin;

// *****************post-attack & fortify utilities*********************

- (BOOL)moveArmies:(int)numArmies from:(RKCountry*)fromCountry to:(RKCountry*)toCountry;

- (void)waitForContinue;
- (IBAction)continueAction:sender;
- (IBAction)checkAction:sender;
- (void)clearArgForms;
- (void)setNotes:(NSString *)noteText;

// *** Helper functions ***
- (NSArray<RKCountry*>*)enemyNeighborsToCountry:(RKCountry*)country;

@end
