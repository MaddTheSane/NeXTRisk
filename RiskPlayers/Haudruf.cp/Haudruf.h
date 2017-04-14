//#import "ComputerPlayer.h"

#import <Cocoa/Cocoa.h>
#import <RiskKit/RiskKit.h>

@interface Haudruf: RiskPlayer
{
	IBOutlet NSWindow  *haudrufPanel;
	IBOutlet NSForm  *myPlayerNumForm;
	IBOutlet NSForm  *functionCalledForm;
	IBOutlet id	args1Form;
	IBOutlet id  args2Form;
	IBOutlet id  returnValueForm;
	IBOutlet id  notesScrollText;
	//IBOutlet id  continueButton;
	IBOutlet NSButton	*pauseContinueButton;
	
	int numCountriesPerContinent[6]; // Anzahl meiner Laender pro Kontinent
	int	countriesInContinent[6][12]; // IDs meiner Laender in den Kontinenten
	BOOL gotContinent[6];
	int numGotContinents;
	int round;
	int turn;
	RiskContinent initialContinent;
}

+ (void)initialize;

- (instancetype)initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager;

// *****************subclass responsibilities*********************

- yourChooseCountry;
- yourInitialPlaceArmies:(int)numArmies;
- yourTurnWithArmies:(int)numArmies andCards:(int)numCards;
- (void)playerNumber:(Player)number attackedCountry:(Country *)attackedCountry;
- (void)playerNumber:(Player)number capturedCountry:(Country *)capturedCountry;

// *****************country utilities*********************

- (BOOL)occupyCountry:(Country *)country;

// *****************card utilities*********************

- (int)playCards:cardList;

// *****************place army utilities*********************

- (void)placeFortifyingArmies:(int)count fromCountry:(Country *)source;

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

- (void)moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination;

- (void)waitForContinue;
- (IBAction)continueAction:sender;
- (IBAction)checkAction:sender;
- clearArgForms;
- setNotes:(const char *)noteText;

- (BOOL)calcNumCountriesPerContinent;
- (BOOL)countryInContinent:country :(int)continent;
- bestCountryFor:(int)continent;
- fortifyPosition;
- findBestVictimFor:country;
- klotzArmies:(int)armiesLeft;
- (int)conquerContinents:(int)armiesLeft;
- (int)stabilizeContinents:(int)armiesLeft;
- (int)defendContinent:(int)continent armies:(int)armiesLeft;
- (int)turnInCards;
- enemyNeighborsTo:country;
- getMaxArmyCountry;
- getCountryNamed:(char*)name;
- getMaxArmyWithEnemyCountry;
- (int) checkInitialContinent:(int) numArmies;

@end
