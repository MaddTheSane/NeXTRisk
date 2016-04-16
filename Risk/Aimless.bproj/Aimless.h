//
// $Id: Aimless.h,v 1.2 1997/12/13 19:37:18 nygard Exp $
//

//
//  This file is a part of Risk by Mike Ferris.
//  Copyright (C) 1997  Steve Nygard
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
//  You may contact the author by:
//     e-mail:  nygard@telusplanet.net
//

#import <RiskKit/RiskPlayer.h>
#import <AppKit/AppKit.h>

typedef enum _CountryChoiceType
{
    ChooseRandomCountry,
    ChooseRandomContinents,
    ChooseSmallestContinent,
    ChooseLargestContinent,
    ChooseLeastBorderedContinent,
    ChooseMostBorderedContinent,
    ChooseAdjacentToCurrentCountries
} CountryChoiceType;

@class SNHeap<ObjectType>, Continent;

@interface Aimless : RiskPlayer
{
    NSMutableSet *unoccupiedContinents;

    int attackedCount[7];
    int lostCountryCount[7];
    int brokenContinentCount[7];

    SNHeap<Country*> *initialCountryHeap;
    SNHeap<Country*> *attackingCountryHeap;

    // Choosing initial countries:
    CountryChoiceType primaryChoice;

    // For smallest/largest/leastBordered/mostBordered continent
    SNHeap<Continent*> *continentChoiceHeap;
    // For random continents:
    NSMutableArray *continentChoiceArray;

    // whereToPlace;
    // howToPlace;
}

- (instancetype)initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager;

- (void) setPlayerToolMenu:(NSMenu *)theMenu;
- (IBAction) testMessage:(id)sender;

//======================================================================
// Subclass Responsibilities
//======================================================================

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

- (void) mayTurnInCards;
- (void) mustTurnInCards;

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

- (void) chooseCountry;
- (void) willEndChoosingCountries;

- (void) willBeginPlacingInitialArmies;
- (void) placeInitialArmies:(int)count;
- (void) willEndPlacingInitialArmies;

- (void) youLostGame;
- (void) youWonGame;

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

- (void) willBeginTurn;

- (void) placeArmies:(int)count;
- (void) attackPhase;
- (void) moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination;
- (void) fortifyPhase:(FortifyRule)fortifyRule;
- (void) placeFortifyingArmies:(int)count fromCountry:(Country *)source;

- (void) willEndTurn;

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

- (void) playerNumber:(Player)number attackedCountry:(Country *)attackedCountry;
- (void) playerNumber:(Player)number capturedCountry:(Country *)capturedCountry;

//======================================================================
// Custom methods
//======================================================================

- (BOOL) doAttackFromCountry:(Country *)attacker;

- (NSSet<Country*> *) unoccupiedCountriesInContinentNamed:(NSString *)continentName;

- (Continent *) continentWeAreClosestToControlling;

- (int) perimeterCountryCount;
- (int) perimeterCountryCountExcludingCountry:(Country *)excludedCountry;
- (NSSet<Country*> *) enemyCountriesAlongPerimeter;

- (void) analyzePerimeter;
- (Country *) bestCountryToMinimizePerimeter:(NSSet *)potentialCountries;
- (Country *) minimizePerimeter:(int)current ofCountries:(NSSet *)potentialCountries;

- (Country *) bestCountryToControlContinents:(NSSet *)potentialCountries;

- (void) _logCurrentWrathValues;

- (NSSet<Country*> *) mostConnectedCountries;

#if 0
//======================================================================
// Some unimplemented methods.
//======================================================================

- (Country *) randomUnoccupiedCountry;
- (Country *) unoccupiedCountryFromRandomContinent;

- (Continent *) randomContinent;
- (SNHeap *) continentsOrderedByIncreasingNumberOfCountries;
- (SNHeap *) continentsOrderedByDecreasingNumberOfCountries;
- (SNHeap *) continentsOrderedByIncreasingNumberOfPerimeterCountries;
- (SNHeap *) continentsOrderedByDecreasingNumberOfPerimeterCountries;
#endif
@end
