// Block.h
// Part of Risk by Mike Ferris


#import "Coop.h" //"Chaotic.h" //"ComputerPlayer.h"

@interface Block:Coop    //Chaotic   //ComputerPlayer
{
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

- getCountryNamed:(char*)name;
- preferedCountriesEmpty: (BOOL)yes;
- randomFromList:list maxArmies:(int)anz;
- mostSuperiorEnemyTo:inCountry;
- myStrongestNeighborTo:en;
- (BOOL)doAttackFrom:fromc;
- (int)sumEnemyNeighborsTo:c;

@end
