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
	IBOutlet NSScrollView * notesScrollText;
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

- (void)chooseCountry;
- (void)placeInitialArmies:(int)numArmies;
- yourTurnWithArmies:(int)numArmies andCards:(int)numCards;
- (void)playerNumber:(Player)number attackedCountry:(Country *)attackedCountry;
- (void)playerNumber:(Player)number capturedCountry:(Country *)capturedCountry;

// *****************country utilities*********************

- (BOOL)occupyCountry:(Country *)country;

// *****************card utilities*********************

- (int)playCards:(CardSet *)cardList;

// *****************place army utilities*********************

- (void)placeFortifyingArmies:(int)count fromCountry:(Country *)source;

- (BOOL)placeArmies:(int)numArmies inCountry:(Country *)country;

// *****************attack utilities*********************


- (BOOL)attackOnceFrom:(Country *)fromCountry to:(Country *)toCountry
               victory:(BOOL *)victory fromArmies:(int *)fromArmies
              toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                 weWin:(BOOL *)wewin;
- (BOOL)attackTimes:(int)times from:(Country *)fromCountry to:(Country *)toCountry
            victory:(BOOL *)victory fromArmies:(int *)fromArmies
           toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
              weWin:(BOOL *)wewin;
- (BOOL)attackUntilLeft:(int)untilLeft from:(Country *)fromCountry to:(Country *)toCountry
                victory:(BOOL *)victory fromArmies:(int *)fromArmies
               toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                  weWin:(BOOL *)wewin;
- (BOOL)attackUntilCantFrom:(Country *)fromCountry to:(Country *)toCountry 
                    victory:(BOOL *)victory fromArmies:(int *)fromArmies
                   toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                      weWin:(BOOL *)wewin;

// *****************post-attack & fortify utilities*********************

- (void)moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination;

- (void)waitForContinue;
- (IBAction)continueAction:(id)sender;
- (IBAction)checkAction:(id)sender;
- (void)clearArgForms;
- (void)setNotes:(const char *)noteText;

- (BOOL)calcNumCountriesPerContinent;
- (BOOL)country:(Country *)country isInContinent:(RiskContinent)continent;
- (Country*)bestCountryFor:(RiskContinent)continent;
- (void)fortifyPosition;
- findBestVictimFor:(Country*)country;
- klotzArmies:(int)armiesLeft;
- (int)conquerContinents:(int)armiesLeft;
- (int)stabilizeContinents:(int)armiesLeft;
- (int)defendContinent:(int)continent armies:(int)armiesLeft;
- (int)turnInCards;
- (NSArray<Country*>*)enemyNeighborsTo:(Country*)country;
- (Country *)getMaxArmyCountry;
- (Country *)getCountryNamed:(NSString*)name;
- (Country *)getMaxArmyWithEnemyCountry;
- (int) checkInitialContinent:(RiskContinent) numArmies;

@end
