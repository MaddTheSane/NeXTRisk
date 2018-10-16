//#import "ComputerPlayer.h"

#import <Cocoa/Cocoa.h>
#import <RiskKit/RiskKit.h>

@interface Haudruf: RiskPlayer
{
	IBOutlet NSWindow		*haudrufPanel;
	IBOutlet NSForm			*myPlayerNumForm;
	IBOutlet NSForm			*functionCalledForm;
	IBOutlet NSForm			*args1Form;
	IBOutlet NSForm			*args2Form;
	IBOutlet NSForm			*returnValueForm;
	IBOutlet NSScrollView	*notesScrollText;
	//IBOutlet id  continueButton;
	IBOutlet NSButton		*pauseContinueButton;
	
	int numCountriesPerContinent[6]; // Anzahl meiner Laender pro Kontinent
	NSString	*countriesInContinent[6][12]; // IDs meiner Laender in den Kontinenten
	BOOL gotContinent[6];
	int numGotContinents;
	int round;
	int turn;
	RiskContinent initialContinent;
}

- (instancetype)initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager;

// *****************subclass responsibilities*********************

- (void)chooseCountry;
- (void)placeInitialArmies:(RKArmyCount)numArmies;
- yourTurnWithArmies:(RKArmyCount)numArmies andCards:(int)numCards;
- (void)playerNumber:(RKPlayer)number attackedCountry:(RKCountry *)attackedCountry;
- (void)playerNumber:(RKPlayer)number capturedCountry:(RKCountry *)capturedCountry;

// *****************country utilities*********************

+ (NSString*) stringFromContinent:(RiskContinent)cont;
- (NSSet<RKCountry*>*)countriesInContinent:(RiskContinent)cont;
- (BOOL)occupyCountry:(RKCountry *)country;

// *****************card utilities*********************

- (void)playCards:(RKCardSet *)cardList;

// *****************place army utilities*********************

- (void)placeFortifyingArmies:(RKArmyCount)count fromCountry:(RKCountry *)source;

- (BOOL)placeArmies:(RKArmyCount)numArmies inCountry:(RKCountry *)country;

// *****************attack utilities*********************


- (BOOL)attackOnceFrom:(RKCountry *)fromCountry to:(RKCountry *)toCountry
               victory:(BOOL *)victory fromArmies:(int *)fromArmies
              toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                 weWin:(BOOL *)wewin;
- (BOOL)attackTimes:(int)times from:(RKCountry *)fromCountry to:(RKCountry *)toCountry
            victory:(BOOL *)victory fromArmies:(int *)fromArmies
           toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
              weWin:(BOOL *)wewin;
- (BOOL)attackUntilLeft:(int)untilLeft from:(RKCountry *)fromCountry to:(RKCountry *)toCountry
                victory:(BOOL *)victory fromArmies:(int *)fromArmies
               toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                  weWin:(BOOL *)wewin;
- (BOOL)attackUntilCantFrom:(RKCountry *)fromCountry to:(RKCountry *)toCountry
                    victory:(BOOL *)victory fromArmies:(int *)fromArmies
                   toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                      weWin:(BOOL *)wewin;

// *****************post-attack & fortify utilities*********************

- (void)moveAttackingArmies:(RKArmyCount)count between:(RKCountry *)source :(RKCountry *)destination;

- (void)waitForContinue;
- (IBAction)continueAction:(id)sender;
- (IBAction)checkAction:(id)sender;
- (void)clearArgForms;
- (void)setNotes:(NSString *)noteText;

- (BOOL)calcNumCountriesPerContinent;
- (BOOL)country:(RKCountry *)country isInContinent:(RiskContinent)continent;
- (RKCountry*)bestCountryFor:(RiskContinent)continent;
- (void)fortifyPosition;
- findBestVictimFor:(RKCountry*)country;
- klotzArmies:(RKArmyCount)armiesLeft;
- (int)conquerContinents:(RiskArmyCount)armiesLeft;
- (int)stabilizeContinents:(RiskArmyCount)armiesLeft;
- (RKArmyCount)defendContinent:(RiskContinent)continent armies:(RKArmyCount)armiesLeft;
- (RKArmyCount)turnInCards;
- (NSArray<RKCountry*>*)enemyNeighborsTo:(RKCountry*)country;
- (RKCountry *)getMaxArmyCountry;
- (RKCountry *)getCountryNamed:(NSString*)name;
- (RKCountry *)getMaxArmyWithEnemyCountry;
- (int) checkInitialContinent:(RiskContinent) numArmies;

@end
