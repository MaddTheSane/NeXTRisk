//
// $Id: Chaotic.h,v 1.2 1997/12/13 19:37:21 nygard Exp $
// Part of Risk by Mike Ferris
//

#import "RiskPlayer.h"

@interface Chaotic : RiskPlayer
{
    NSMutableSet *unoccupiedContinents;
    NSMutableSet *attackingCountries;
}

+ (void) load;
+ (void) initialize;

- initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager;
- (void) dealloc;

//======================================================================
// Subclass Responsibilities
//======================================================================

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

- (void) mustTurnInCards;

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

- (void) chooseCountry;
- (void) placeInitialArmies:(int)count;

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

- (void) placeArmies:(int)count;
- (void) attackPhase;
- (void) moveAttackingArmies:(int)count between:(Country *)source:(Country *)destination;
- (void) fortifyPhase:(FortifyRule)fortifyRule;
- (void) placeFortifyingArmies:(int)count fromCountry:(Country *)source;

- (void) willEndTurn;

//======================================================================
// Custom methods
//======================================================================

- (BOOL) doAttackFromCountry:(Country *)attacker;

@end
