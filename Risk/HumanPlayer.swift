//
//  HumanPlayer.swift
//  Risk
//
//  Created by C.W. Betts on 10/28/19.
//  Copyright © 2019 C.W. Betts. All rights reserved.
//

import Cocoa
import RiskKit.RiskPlayer


/// The Human player is the standard interactive player that uses the
/// shared interfaces for a human to play.
open class HumanPlayer : RiskPlayer {
    private var placeArmyCount: RKArmyCount = 0
    private var attackingCountry: RKCountry?
    
    // MARK: - Subclass Responsibilities
    
    override open var isInteractive: Bool {
        return true
    }

    // MARK: User input
    
    open override func mouseDown(_ theEvent: NSEvent, in aCountry: RKCountry) {
        let flags = theEvent.modifierFlags
        let gameState = gameManager.gameState
        switch gameState {
        case .choosingCountries:
            if aCountry.playerNumber == playerNumber {
                gameManager.select(aCountry)
            }
            
            if gameManager.player(self, choseCountry: aCountry) {
                turnDone()
            } else {
                NSSound.beep()
            }
            
        case .placeInitialArmies, .placeArmies, .moveAttackingArmies, .placeFortifyingArmies:
            var count: Int32
            if flags.contains(.shift) {
                count = 5
            } else if flags.contains(.command) {
                count = placeArmyCount
            } else {
                count = 1
            }
            
            count = min(count, placeArmyCount)

            if placeArmyCount > 0 {
                if gameManager.player(self, placesArmies: count, in: aCountry) {
                    setAttacking(aCountry)
                    placeArmyCount -= count
                    if placeArmyCount == 0 {
                        turnDone()
                    }
                } else {
                    NSSound.beep()
                }
            }
            
        case .attack:
            // If the country is ours, set that as the attacking country (if >0 troops),
            // otherwise, attack the target country.
            if aCountry.playerNumber == playerNumber {
                setAttacking(aCountry)
            } else {
                assert(attackingCountry != nil, "attacking country not set.")
                
                let moveFlag = flags.contains(.shift)
                
                if attackingCountry!.isAdjacent(to: aCountry) {
                    // Attack target country
                    let attackResult = attack(from: attackingCountry!, to: aCountry, moveAllArmiesUponVictory: moveFlag)
                    gameManager.select(attackingCountry)
                    _=attackResult
                }
            }
            
        case .fortify:
            if aCountry.playerNumber == playerNumber {
                gameManager.fortifyArmies(from: aCountry)
            } else {
                NSSound.beep()
            }
            
        default:
            if aCountry.playerNumber == playerNumber {
                gameManager.select(aCountry)
            }
        }
    }

    // MARK: Card management
    
    open override func mustTurnInCards() {
        // Open the card panel to force the user to turn in cards.
        gameManager.turnInCards(self)
    }

    open override func didTurnInCards(_ extraArmyCount: RKArmyCount) {
        placeArmyCount += extraArmyCount
    }

    // MARK: Initial game phases
    
    open override func placeInitialArmies(_ count: RKArmyCount) {
        placeArmyCount = count
    }
    
    // MARK: Regular turn phases
    
    open override func placeArmies(_ count: RKArmyCount) {
        placeArmyCount = count
    }

    open override func attackPhase() {
        gameManager.select(attackingCountry)
        if let attackingCountry = attackingCountry {
            gameManager.setAttackingFromCountryName(attackingCountry.countryName)
        }
    }

    open override func moveAttackingArmies(_ count: RKArmyCount, between source: RKCountry, _ destination: RKCountry) {
        placeArmyCount = count
        if placeArmyCount == 0 {
            turnDone()
        }
    }

    open override func fortifyPhase(_ fortifyRule: RKFortifyRule) {
        
    }

    open override func placeFortifyingArmies(_ count: RKArmyCount, from source: RKCountry) {
        placeArmyCount = count
    }

    // MARK: - Inform computer players of important events that happed during other players turns.
    
    open override func playerNumber(_ number: RKPlayer, capturedCountry: RKCountry) {
        if (capturedCountry === attackingCountry) {
            attackingCountry = nil
        }
    }

    // MARK: - Custom methods
    
    /// Attack between countries based on the current attack method.
    open func attack(from attacker: RKCountry, to defender: RKCountry, moveAllArmiesUponVictory moveFlag: Bool) -> RKAttackResult {
        var attackResult = RKAttackResult()
        switch attackMethod {
        case .untilUnableToContinue:
            attackResult = gameManager.attackUntilUnableToContinue(from: attacker, to: defender, moveAllArmiesUponVictory: moveFlag)
            
        case .multipleTimes:
            attackResult = gameManager.attackMultipleTimes(attackMethodValue, from: attacker, to: defender, moveAllArmiesUponVictory: moveFlag)
            
        case .untilArmiesRemain:
            attackResult = gameManager.attack(from: attacker, to: defender, untilArmiesRemain: attackMethodValue, moveAllArmiesUponVictory: moveFlag)
            
        case .once:
            fallthrough
        @unknown default:
            attackResult = gameManager.attackOnce(from: attacker, to: defender, moveAllArmiesUponVictory: moveFlag)
        }

        if attackResult.conqueredCountry.boolValue == true {
            setAttacking(defender)
        }
        
        return attackResult
    }

    open func setAttacking(_ attacker: RKCountry?) {
        if let attacker = attacker {
            attackingCountry = attacker
            
            gameManager.setAttackingFromCountryName(attacker.countryName)
            gameManager.select(attackingCountry)
        } else {
            attackingCountry = nil
        }
    }
}
