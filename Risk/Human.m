//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: Human.m,v 1.4 1997/12/15 07:43:53 nygard Exp $");

#import "Human.h"

#import "RiskGameManager.h"
#import "Country.h"

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

- (instancetype)initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager
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

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry
{
    GameState gameState;
    int count;
    unsigned int flags;
    
    flags = theEvent.modifierFlags;
    gameState = [gameManager gameState];
    switch (gameState)
    {
        case GameStateChoosingCountries:
            if (aCountry.playerNumber == playerNumber)
                [gameManager selectCountry:aCountry];
            
            if ([gameManager player:self choseCountry:aCountry] == YES)
                [self turnDone];
            else
                NSBeep ();
            break;
            
        case GameStatePlaceInitialArmies:
        case GameStatePlaceArmies:
        case GameStateMoveAttackingArmies:
        case GameStatePlaceFortifyingArmies:
            if (flags & NSShiftKeyMask)
                count = 5;
            else if (flags & NSCommandKeyMask)
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
            
        case GameStateAttack:
            // If the country is ours, set that as the attacking country (if >0 troops),
            // otherwise, attack the target country.
            if (aCountry.playerNumber == playerNumber)
            {
                [self setAttackingCountry:aCountry];
            }
            else
            {
                AttackResult attackResult;
                BOOL moveFlag;
                
                NSAssert (attackingCountry != nil, @"attacking country not set.");
                
                moveFlag = (flags & NSShiftKeyMask) ? YES : NO;
                
                if ([attackingCountry isAdjacentToCountry:aCountry] == YES)
                {
                    // Attack target country
                    attackResult = [self attackFromCountry:attackingCountry toCountry:aCountry moveAllArmiesUponVictory:moveFlag];
                    [gameManager selectCountry:attackingCountry];
                }
            }
            break;
            
        case GameStateFortify:
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

- (void) moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination
{
    placeArmyCount = count;
    if (placeArmyCount == 0)
        [self turnDone];
}

//----------------------------------------------------------------------

- (void) fortifyPhase:(FortifyRule)fortifyRule
{
}

//----------------------------------------------------------------------

- (void) placeFortifyingArmies:(int)count fromCountry:(Country *)source
{
    placeArmyCount = count;
}

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

- (void) playerNumber:(Player)number capturedCountry:(Country *)capturedCountry
{
    if (capturedCountry == attackingCountry)
    {
        SNRelease (attackingCountry);
    }
}

//======================================================================
// Custom methods
//======================================================================

//----------------------------------------------------------------------
// Attack between countries based on the current attack method.
//----------------------------------------------------------------------

- (AttackResult) attackFromCountry:(Country *)attacker toCountry:(Country *)defender moveAllArmiesUponVictory:(BOOL)moveFlag
{
    AttackResult attackResult;
    
    switch (attackMethod)
    {
        case AttackMethodUntilUnableToContinue:
            attackResult = [gameManager attackUntilUnableToContinueFromCountry:attacker
                                                                     toCountry:defender
                                                      moveAllArmiesUponVictory:moveFlag];
            break;
            
        case AttackMethodMultipleTimes:
            attackResult = [gameManager attackMultipleTimes:attackMethodValue
                                                fromCountry:attacker
                                                  toCountry:defender
                                   moveAllArmiesUponVictory:moveFlag];
            break;
            
        case AttackMethodUntilArmiesRemain:
            attackResult = [gameManager attackFromCountry:attacker
                                                toCountry:defender
                                        untilArmiesRemain:attackMethodValue
                                 moveAllArmiesUponVictory:moveFlag];
            break;
            
        case AttackMethodOnce:
        default:
            attackResult = [gameManager attackOnceFromCountry:attacker
                                                    toCountry:defender
                                     moveAllArmiesUponVictory:moveFlag];
    }
    
    if (attackResult.conqueredCountry == YES)
        [self setAttackingCountry:defender];
    
    return attackResult;
}

//----------------------------------------------------------------------

- (void) setAttackingCountry:(Country *)attacker
{
    SNRelease (attackingCountry);
    if (attacker != nil)
    {
        attackingCountry = attacker;
        
        [gameManager setAttackingFromCountryName:attackingCountry.countryName];
        [gameManager selectCountry:attackingCountry];
    }
}

@end
