//
// $Id: Human.h,v 1.3 1997/12/15 07:43:52 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Cocoa/Cocoa.h>

#import <RiskKit/RiskPlayer.h>

/// The Human player is the standard interactive player that uses the
/// shared interfaces for a human to play.
@interface Human : RiskPlayer
{
    RKArmyCount placeArmyCount;
    RKCountry *attackingCountry;
}

- (instancetype)initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager;

//======================================================================
// Subclass Responsibilities
//======================================================================

@property (getter=isInteractive, readonly) BOOL interactive;

//----------------------------------------------------------------------
// User input
//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry;

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

- (void) mustTurnInCards;
- (void) didTurnInCards:(RKArmyCount)extraArmyCount;

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

- (void) placeInitialArmies:(RKArmyCount)count;

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

- (void) placeArmies:(RKArmyCount)count;
- (void) attackPhase;
- (void) moveAttackingArmies:(RKArmyCount)count between:(RKCountry *)source :(RKCountry *)destination;
- (void) fortifyPhase:(RKFortifyRule)fortifyRule;
- (void) placeFortifyingArmies:(RKArmyCount)count fromCountry:(RKCountry *)source;

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

- (void) playerNumber:(RKPlayer)number capturedCountry:(RKCountry *)capturedCountry;

//======================================================================
// Custom methods
//======================================================================

- (RKAttackResult) attackFromCountry:(RKCountry *)attacker toCountry:(RKCountry *)defender moveAllArmiesUponVictory:(BOOL)moveFlag;
- (void) setAttackingCountry:(RKCountry *)attacker;

@end
