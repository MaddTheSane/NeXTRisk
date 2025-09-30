//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: Human.m,v 1.4 1997/12/15 07:43:53 nygard Exp $");

#import "Human.h"

#import <RiskKit/RiskGameManager.h>
#import <RiskKit/RKCountry.h>

#define Human_VERSION 1

@implementation Human

+ (void) initialize
{
    if (self == [Human class])
    {
        [self setVersion:Human_VERSION];
    }
}

//----------------------------------------------------------------------

- (instancetype)initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager
{
    if (self = [super initWithPlayerName:aName number:number gameManager:aManager]){
        placeArmyCount = 0;
        attackingCountry = nil;
    }
    
    return self;
}

//======================================================================
// Subclass Responsibilities
//======================================================================

- (BOOL) isInteractive
{
    return YES;
}

//----------------------------------------------------------------------
// User input
//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry
{
    RKGameState gameState;
    int count;
    NSEventModifierFlags flags;
    
    flags = theEvent.modifierFlags;
    gameState = [gameManager gameState];
    switch (gameState)
    {
        case RKGameStateChoosingCountries:
            if (aCountry.playerNumber == playerNumber)
                [gameManager selectCountry:aCountry];
            
            if ([gameManager player:self choseCountry:aCountry] == YES)
                [self turnDone];
            else
                NSBeep ();
            break;
            
        case RKGameStatePlaceInitialArmies:
        case RKGameStatePlaceArmies:
        case RKGameStateMoveAttackingArmies:
        case RKGameStatePlaceFortifyingArmies:
            if (flags & NSEventModifierFlagShift)
                count = 5;
            else if (flags & NSEventModifierFlagCommand)
                count = placeArmyCount;
            else
                count = 1;
            
            if (count > placeArmyCount)
                count = placeArmyCount;
            
            if (placeArmyCount > 0)
            {
                if ([gameManager player:self placesArmies:count inCountry:aCountry] == YES)
                {
                    [self setAttackingCountry:aCountry];
                    
                    placeArmyCount -= count;
                    if (placeArmyCount == 0)
                        [self turnDone];
                }
                else
                {
                    NSBeep ();
                }
            }
            
            break;
            
        case RKGameStateAttack:
            // If the country is ours, set that as the attacking country (if >0 troops),
            // otherwise, attack the target country.
            if (aCountry.playerNumber == playerNumber)
            {
                [self setAttackingCountry:aCountry];
            }
            else
            {
                RKAttackResult attackResult;
                BOOL moveFlag;
                
                NSAssert (attackingCountry != nil, @"attacking country not set.");
                
                moveFlag = (flags & NSEventModifierFlagShift) ? YES : NO;
                
                if ([attackingCountry isAdjacentToCountry:aCountry] == YES)
                {
                    // Attack target country
                    attackResult = [self attackFromCountry:attackingCountry toCountry:aCountry moveAllArmiesUponVictory:moveFlag];
                    [gameManager selectCountry:attackingCountry];
                }
            }
            break;
            
        case RKGameStateFortify:
            if (aCountry.playerNumber == playerNumber)
            {
                [gameManager fortifyArmiesFrom:aCountry];
            }
            else
            {
                NSBeep ();
            }
            break;
            
        default:
            if (aCountry.playerNumber == playerNumber)
                [gameManager selectCountry:aCountry];
    }
}

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

- (void) mustTurnInCards
{
    // Open the card panel to force the user to turn in cards.
    [gameManager turnInCards:self];
}

//----------------------------------------------------------------------

- (void) didTurnInCards:(int)extraArmyCount
{
    placeArmyCount += extraArmyCount;
}

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

- (void) placeInitialArmies:(int)count
{
    placeArmyCount = count;
}

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

- (void) placeArmies:(int)count
{
    placeArmyCount = count;
}

//----------------------------------------------------------------------

- (void) attackPhase
{
    [gameManager selectCountry:attackingCountry];
    if (attackingCountry != nil)
    {
        [gameManager setAttackingFromCountryName:attackingCountry.countryName];
    }
}

//----------------------------------------------------------------------

- (void) moveAttackingArmies:(int)count between:(RKCountry *)source :(RKCountry *)destination
{
    placeArmyCount = count;
    if (placeArmyCount == 0) {
        [self turnDone];
    }
}

//----------------------------------------------------------------------

- (void) fortifyPhase:(RKFortifyRule)fortifyRule
{
}

//----------------------------------------------------------------------

- (void) placeFortifyingArmies:(int)count fromCountry:(RKCountry *)source
{
    placeArmyCount = count;
}

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

- (void) playerNumber:(RKPlayer)number capturedCountry:(RKCountry *)capturedCountry
{
    if (capturedCountry == attackingCountry) {
        SNRelease (attackingCountry);
    }
}

//======================================================================
// Custom methods
//======================================================================

//----------------------------------------------------------------------
// Attack between countries based on the current attack method.
//----------------------------------------------------------------------

- (RKAttackResult) attackFromCountry:(RKCountry *)attacker toCountry:(RKCountry *)defender moveAllArmiesUponVictory:(BOOL)moveFlag
{
    RKAttackResult attackResult;
    
    switch (attackMethod) {
        case RKAttackMethodUntilUnableToContinue:
            attackResult = [gameManager attackUntilUnableToContinueFromCountry:attacker
                                                                     toCountry:defender
                                                      moveAllArmiesUponVictory:moveFlag];
            break;
            
        case RKAttackMethodMultipleTimes:
            attackResult = [gameManager attackMultipleTimes:attackMethodValue
                                                fromCountry:attacker
                                                  toCountry:defender
                                   moveAllArmiesUponVictory:moveFlag];
            break;
            
        case RKAttackMethodUntilArmiesRemain:
            attackResult = [gameManager attackFromCountry:attacker
                                                toCountry:defender
                                        untilArmiesRemain:attackMethodValue
                                 moveAllArmiesUponVictory:moveFlag];
            break;
            
        case RKAttackMethodOnce:
        default:
            attackResult = [gameManager attackOnceFromCountry:attacker
                                                    toCountry:defender
                                     moveAllArmiesUponVictory:moveFlag];
    }
    
    if (attackResult.conqueredCountry == YES) {
        [self setAttackingCountry:defender];
    }
    
    return attackResult;
}

//----------------------------------------------------------------------

- (void) setAttackingCountry:(RKCountry *)attacker
{
    SNRelease (attackingCountry);
    if (attacker != nil) {
        attackingCountry = attacker;
        
        [gameManager setAttackingFromCountryName:attackingCountry.countryName];
        [gameManager selectCountry:attackingCountry];
    }
}

@end
