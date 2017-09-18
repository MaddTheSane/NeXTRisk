// Block.h
// Part of Risk by Mike Ferris


#import "Coop.h" //"Chaotic.h" //"ComputerPlayer.h"

@interface Block:Coop    //Chaotic   //ComputerPlayer

- (instancetype)initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager;

// *****************subclass responsibilities*********************

- yourChooseCountry;
- placeInitialArmies:(int)numArmies;
- yourTurnWithArmies:(int)numArmies andCards:(int)numCards;
- (void) playerNumber:(Player)number attackedCountry:(Country *)attackedCountry;
- (void) playerNumber:(Player)number capturedCountry:(Country *)capturedCountry;

- getCountryNamed:(char*)name;
- preferedCountriesEmpty: (BOOL)yes;
- randomFromList:list maxArmies:(int)anz;
- mostSuperiorEnemyTo:inCountry;
- myStrongestNeighborTo:en;
- (BOOL)doAttackFrom:fromc;
- (int)sumEnemyNeighborsTo:c;

@end
