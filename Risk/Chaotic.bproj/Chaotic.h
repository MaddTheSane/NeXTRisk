//
// $Id: Chaotic.h,v 1.2 1997/12/13 19:37:21 nygard Exp $
// Part of Risk by Mike Ferris
//

#import <Foundation/Foundation.h>
#import <RiskKit/RiskPlayer.h>

@interface Chaotic : RiskPlayer
{
    NSMutableSet *unoccupiedContinents;
    NSMutableSet *attackingCountries;
}

- (instancetype) initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager;

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
- (void) moveAttackingArmies:(int)count between:(RKCountry *)source :(RKCountry *)destination;
- (void) fortifyPhase:(RKFortifyRule)fortifyRule;
- (void) placeFortifyingArmies:(int)count fromCountry:(RKCountry *)source;

- (void) willEndTurn;

//======================================================================
// Custom methods
//======================================================================

- (BOOL) doAttackFromCountry:(RKCountry *)attacker;

@end
