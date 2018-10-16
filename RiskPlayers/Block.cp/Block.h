// Block.h
// Part of Risk by Mike Ferris


#import "Coop.h" //"Chaotic.h" //"ComputerPlayer.h"

@interface Block:Coop    //Chaotic   //ComputerPlayer

- (instancetype)initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager;

// *****************subclass responsibilities*********************

- (void)chooseCountry;
- (void)placeInitialArmies:(RKArmyCount)count;
- yourTurnWithArmies:(int)numArmies andCards:(int)numCards;
- (void) playerNumber:(RKPlayer)number attackedCountry:(RKCountry *)attackedCountry;
- (void) playerNumber:(RKPlayer)number capturedCountry:(RKCountry *)capturedCountry;

- getCountryNamed:(NSString*)name;
- preferedCountriesEmpty: (BOOL)yes;
- randomFromList:list maxArmies:(int)anz;
- mostSuperiorEnemyTo:inCountry;
- myStrongestNeighborTo:en;
- (BOOL)doAttackFrom:fromc;
- (int)sumEnemyNeighborsTo:c;

@end
