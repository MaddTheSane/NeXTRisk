//
// $Id: Human.h,v 1.3 1997/12/15 07:43:52 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "RiskPlayer.h"

/// The Human player is the standard interactive player that uses the
/// shared interfaces for a human to play.
@interface Human : RiskPlayer
{
    RiskArmyCount placeArmyCount;
    Country *attackingCountry;
}

- (instancetype)initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager;

//======================================================================
// Subclass Responsibilities
//======================================================================

@property (getter=isInteractive, readonly) BOOL interactive;

//----------------------------------------------------------------------
// User input
//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry;

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

- (void) mustTurnInCards;
- (void) didTurnInCards:(RiskArmyCount)extraArmyCount;

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

- (void) placeInitialArmies:(RiskArmyCount)count;

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

- (void) placeArmies:(RiskArmyCount)count;
- (void) attackPhase;
- (void) moveAttackingArmies:(RiskArmyCount)count between:(Country *)source :(Country *)destination;
- (void) fortifyPhase:(FortifyRule)fortifyRule;
- (void) placeFortifyingArmies:(RiskArmyCount)count fromCountry:(Country *)source;

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

- (void) playerNumber:(Player)number capturedCountry:(Country *)capturedCountry;

//======================================================================
// Custom methods
//======================================================================

- (AttackResult) attackFromCountry:(Country *)attacker toCountry:(Country *)defender moveAllArmiesUponVictory:(BOOL)moveFlag;
- (void) setAttackingCountry:(Country *)attacker;

@end
