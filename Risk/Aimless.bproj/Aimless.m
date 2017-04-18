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

#import <RiskKit/Risk.h>

RCSID ("$Id: Aimless.m,v 1.4 1997/12/15 21:09:47 nygard Exp $");

#import "Aimless.h"

#import "Country.h"
#import "RiskGameManager.h"
#import "RiskWorld.h"
#import "SNRandom.h"
#import "Continent.h"
#import "GameConfiguration.h"
#import "SNHeap.h"
#import "DNode.h"
#import "PathFinder.h"

#define WRATH_ATTACKED 1
#define WRATH_LOST_COUNTRY 5
#define WRATH_BROKEN_CONTINENT 7


//
// The Strategy:
//
//   This is a start at a more advanced computer player.
//
// 1. Intelligent fortification - For many to many connected, evenly
//    distribute countries along front.  For many to many neighbors,
//    move armies up to the front in the shortest path possible.
//
//    Still doesn't work well for fortifying from a single country.
//
// 2. Initial army placement - Place all our armies in the countries of the continent
//    that has the fewest number of countries left for us to take control.
//
// 3. Army placement - Place armies on the weakest country on the front.
//
// 4. Attack - try to reduce the number of our countries on the front.  This will in
//    turn lead to a stronger (more armies/country) front.
// 
//    If we can't reduce the front, try to take over continents.
// 
//    Otherwise, just attack weakest.
//

//
// I was planning on parameterizing many different behaviors so that I could
// experiment to find the best combinations.  I didn't do this, but here are
// the ideas I had.
//
// A: choose countries
//    These can be either first or second.  Randomly is final choice.
//    - randomly
//    - randomly in continent without one of our countries
//    - within random continent
//    - continent with most/least number of countries
//    - continent with most/least number of perimeter countries
//    - next to one of our already chosen countries
//    - 
//
// B: place initial armies
//    1. which country to choose:
//       - all our countries
//       - our exterior countries
//       - one country
//       - countries of one continent (with most of our countries, closest to control, ...)
//       - set of most/least connected countries
//       -
//    2. how to place the armies in the above countries:
//       - place evenly in our country with minimum number of troops
//       - all in one country
//       - randomly among all countries
//       - next to most/least number of enemy countries
//       - next to most/least number of enemy troops
//       - next to most/least difference of troops
//       - 
// C: place armies
//    - same as above
// D: attack
//    - what:
//       - weakest
//       - minimize perimeter
//       - breaks up enemy continent
//    - how:
//       - until random number of troops left
//       - until N troops left
// E: fortifying
//    - n/a - already have good fortifying
//

//----------------------------------------------------------------------
// Heap comparator functions.
//----------------------------------------------------------------------

static NSComparisonResult minimumTroops (id object1, id object2, void *context)
{
    Country *country1, *country2;
    int troopCount1, troopCount2;
    NSComparisonResult result;
    
    NSCParameterAssert (object1 != nil);
    NSCParameterAssert (object2 != nil);
    
    country1 = (Country *) object1;
    country2 = (Country *) object2;
    
    troopCount1 = country1.troopCount;
    troopCount2 = country2.troopCount;
    
    if (troopCount1 < troopCount2)
    {
        result = NSOrderedAscending;
    }
    else if (troopCount1 == troopCount2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }
    
    return result;
}

//----------------------------------------------------------------------

#if 0
static NSComparisonResult maximumVulnerability (id object1, id object2, void *context)
{
    Country *country1, *country2;
    int vulnerability1, vulnerability2;
    NSComparisonResult result;
    
    NSCParameterAssert (object1 != nil);
    NSCParameterAssert (object2 != nil);
    
    country1 = (Country *) object1;
    country2 = (Country *) object2;
    
    vulnerability1 = country1.troopCount - country1.enemyNeighborTroopCount;
    vulnerability2 = country2.troopCount - country2.enemyNeighborTroopCount;
    
    if (vulnerability1 < vulnerability2)
    {
        result = NSOrderedAscending;
    }
    else if (vulnerability1 == vulnerability2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }
    
    return result;
}
#endif

//----------------------------------------------------------------------

static NSComparisonResult maximumMovableTroops (id object1, id object2, void *context)
{
    Country *country1, *country2;
    int troopCount1, troopCount2;
    NSComparisonResult result;
    
    NSCParameterAssert (object1 != nil);
    NSCParameterAssert (object2 != nil);
    
    country1 = (Country *) object1;
    country2 = (Country *) object2;
    
    troopCount1 = country1.movableTroopCount;
    troopCount2 = country2.movableTroopCount;
    
    if (troopCount1 > troopCount2)
    {
        result = NSOrderedAscending;
    }
    else if (troopCount1 == troopCount2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }
    
    return result;
}

//----------------------------------------------------------------------

static NSComparisonResult leastEnemyNeighbors (id object1, id object2, void *context)
{
    Country *country1, *country2;
    NSInteger count1, count2;
    NSComparisonResult result;
    
    NSCParameterAssert (object1 != nil);
    NSCParameterAssert (object2 != nil);
    
    country1 = (Country *) object1;
    country2 = (Country *) object2;
    
    count1 = [country1 enemyNeighborCountries].count;
    count2 = [country2 enemyNeighborCountries].count;
    
    if (count1 > count2)
    {
        result = NSOrderedAscending;
    }
    else if (count1 == count2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }
    
    return result;
}

//----------------------------------------------------------------------

static NSComparisonResult minimumContinentSize (id object1, id object2, void *context)
{
    NSComparisonResult result;
    Continent *continent1, *continent2;
    NSInteger size1, size2;
    
    continent1 = (Continent *) object1;
    continent2 = (Continent *) object2;
    
    size1 = continent1.countries.count;
    size2 = continent2.countries.count;
    
    if (size1 < size2)
    {
        result = NSOrderedAscending;
    }
    else if (size1 == size2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }
    
    return result;
}

//----------------------------------------------------------------------

static NSComparisonResult maximumContinentSize (id object1, id object2, void *context)
{
    NSComparisonResult result;
    Continent *continent1, *continent2;
    NSInteger size1, size2;
    
    continent1 = (Continent *) object1;
    continent2 = (Continent *) object2;
    
    size1 = continent1.countries.count;
    size2 = continent2.countries.count;
    
    if (size1 > size2)
    {
        result = NSOrderedAscending;
    }
    else if (size1 == size2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }
    
    return result;
}

//----------------------------------------------------------------------

static NSComparisonResult minimumContinentBorder (id object1, id object2, void *context)
{
    NSComparisonResult result;
    Continent *continent1, *continent2;
    NSInteger size1, size2;
    
    continent1 = (Continent *) object1;
    continent2 = (Continent *) object2;
    
    size1 = [continent1 countriesAlongBorder].count;
    size2 = [continent2 countriesAlongBorder].count;
    
    if (size1 < size2)
    {
        result = NSOrderedAscending;
    }
    else if (size1 == size2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }
    
    return result;
}

//----------------------------------------------------------------------

static NSComparisonResult maximumContinentBorder (id object1, id object2, void *context)
{
    NSComparisonResult result;
    Continent *continent1, *continent2;
    NSInteger size1, size2;
    
    continent1 = (Continent *) object1;
    continent2 = (Continent *) object2;
    
    size1 = [continent1 countriesAlongBorder].count;
    size2 = [continent2 countriesAlongBorder].count;
    
    if (size1 > size2)
    {
        result = NSOrderedAscending;
    }
    else if (size1 == size2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }
    
    return result;
}

//----------------------------------------------------------------------

#define Aimless_VERSION 1

//----------------------------------------------------------------------

@implementation Aimless

+ (void) load
{
    //NSLog (@"Aimless.");
}

//----------------------------------------------------------------------

+ (void) initialize
{
    if (self == [Aimless class])
    {
        [self setVersion:Aimless_VERSION];
    }
}

//----------------------------------------------------------------------

- (instancetype) initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager
{
    RiskWorld *world;
    NSDictionary *continents;
    int l;
    
    if (self = [super initWithPlayerName:aName number:number gameManager:aManager]) {
        // Contains the names of continents.
        unoccupiedContinents = [[NSMutableSet alloc] init];
        
        world = gameManager.world;
        continents = world.continents;
        
        [unoccupiedContinents addObjectsFromArray:continents.allKeys];
        
        for (l = 0; l < 7; l++)
        {
            attackedCount[l] = 0;
            lostCountryCount[l] = 0;
            brokenContinentCount[l] = 0;
        }
        
        initialCountryHeap = nil;
        attackingCountryHeap = nil;
        
        primaryChoice = ChooseAdjacentToCurrentCountries;
    }
    
    return self;
}

//----------------------------------------------------------------------
// This is a very simple example of adding a player menu item.
//----------------------------------------------------------------------

- (void) setPlayerToolMenu:(NSMenu *)theMenu
{
    NSMenuItem *item;
    super.playerToolMenu = theMenu;
    
    if (playerToolMenu != nil)
    {
        item = [playerToolMenu addItemWithTitle:@"Test"
                                         action:@selector (testMessage:)
                                  keyEquivalent:@""];
        item.target = self;
    }
}

//----------------------------------------------------------------------

- (IBAction) testMessage:(id)sender
{
    [self logMessage:@"This is a test message."];
}

//======================================================================
// Subclass Responsibilities
//======================================================================

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

- (void) mayTurnInCards
{
    CardSetRedemption redemption;
    CardSet *cardSet;
    
    redemption = [gameManager gameConfiguration].cardSetRedemption;
    
    if (redemption == CardSetRedemptionRemainConstant || [self ourCountries].count < 4)
    {
        // Constant: Might as well turn in cards immediately. (Unless we want to wait to get bonus armies for our countries.)
        // Too few countries: probably want as many armies as soon as possible.
        while ((cardSet = [self bestSet]))
        {
            [gameManager turnInCardSet:cardSet forPlayerNumber:playerNumber];
            [self logMessage:@"Voluntarily turned in cards."];
        }
    }
    else
    {
        // Wait until forced to turn in cards.
    }
}

//----------------------------------------------------------------------

- (void) mustTurnInCards
{
    // While the game manager will automatically turn in our best sets for
    // us if we don't choose the cards ourselves, we'll do it ourselves
    // just to be nice.
    
    [gameManager automaticallyTurnInCardsForPlayerNumber:playerNumber];
    [self logMessage:@"Had to turn in cards."];
}

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

// A chaotic player seeks to wreak havoc (in a very limited way) on the
// rest of the players.  Toward this end he tries to choose at least one
// country in each continent.  After that he chooses random countries.

// 1. Decide on which continent will be best (based on # of countries, # of countries on perimeter, value on continent,
//    and how many countries are already occupied.
// 2. Pick a country from that continent.
// 3. While there are free countries in the continent, pick them.
// 4. Otherwise, calculate shortest path from any country in the continent, and choose the closest unoccupied country.

- (void) chooseCountry
{
    Continent *continent;
    Country *country;
    RiskWorld *world;
    SNRandom *anRng;
    
    anRng = self.rng;
    world = gameManager.world;
    
    country = nil;
    switch (primaryChoice)
    {
        case ChooseRandomContinents:
            if (continentChoiceArray == nil)
            {
                NSMutableArray *remainingContinents;
                NSInteger count, index;
                
                continentChoiceArray = [[NSMutableArray alloc] init];
                remainingContinents = [NSMutableArray arrayWithArray:world.continents.allValues];
                count = remainingContinents.count;
                
                while (count > 0)
                {
                    index = [anRng randomNumberModulo:count];
                    continent = remainingContinents[index];
                    [continentChoiceArray addObject:continent];
                    [remainingContinents removeObject:continent];
                    count--;
                }
            }
            
            country = nil;
            while ((continent = continentChoiceArray[0]))
            {
                NSSet *source;
                NSInteger count;
                
                source = [self countriesWithAllOptions:CountryFlagsPlayerNone from:continent.countries];
                count = source.count;
                if (count > 0)
                {
                    [self logMessage:@"Choosing randomly from random continent: %@", continent.continentName];
                    country = source.allObjects[[anRng randomNumberModulo:count]];
                    break;
                }
                else
                {
                    [continentChoiceArray removeObjectAtIndex:0];
                }
            }
            
            break;
            
        case ChooseSmallestContinent:
        case ChooseLargestContinent:
        case ChooseLeastBorderedContinent:
        case ChooseMostBorderedContinent:
            if (continentChoiceHeap == nil)
            {
                NSComparisonResult (*func)(id, id, void *);
                
                switch (primaryChoice)
                {
                    case ChooseLargestContinent:
                        func = maximumContinentSize;
                        break;
                        
                    case ChooseLeastBorderedContinent:
                        func = minimumContinentBorder;
                        break;
                        
                    case ChooseMostBorderedContinent:
                        func = maximumContinentBorder;
                        break;
                        
                    case ChooseSmallestContinent:
                    default:
                        func = minimumContinentSize;
                        break;
                }
                
                continentChoiceHeap = [[SNHeap alloc] initUsingFunction:func context:NULL];
                [continentChoiceHeap insertObjectsFromEnumerator:[world.continents objectEnumerator]];
            }
            
            country = nil;
            while ((continent = [continentChoiceHeap firstObject]))
            {
                NSSet *source;
                NSInteger count;
                
                source = [self countriesWithAllOptions:CountryFlagsPlayerNone from:continent.countries];
                count = source.count;
                if (count > 0)
                {
                    NSString *how;
                    
                    switch (primaryChoice)
                    {
                        case ChooseLargestContinent:
                            how = @"largest";
                            break;
                            
                        case ChooseLeastBorderedContinent:
                            how = @"least bordered";
                            break;
                            
                        case ChooseMostBorderedContinent:
                            how = @"most bordered";
                            break;
                            
                        case ChooseSmallestContinent:
                        default:
                            how = @"smallest";
                            break;
                    }
                    
                    [self logMessage:@"Choosing randomly from %@ continent: %@", how, continent.continentName];
                    country = source.allObjects[[anRng randomNumberModulo:count]];
                    break;
                }
                else
                {
                    [continentChoiceHeap extractObject];
                }
            }
            break;
            
        case ChooseAdjacentToCurrentCountries:
        {
            NSEnumerator *countryEnumerator;
            NSMutableSet *source;
            NSSet *unoccupied;
            NSInteger count;
            
            source = [NSMutableSet set];
            countryEnumerator = [[self ourCountries] objectEnumerator];
            while (country = [countryEnumerator nextObject])
            {
                [source unionSet:country.neighborCountries];
            }
            
            country = nil;
            unoccupied = [self countriesWithAllOptions:CountryFlagsPlayerNone from:source];
            count = unoccupied.count;
            if (count > 0)
            {
                country = unoccupied.allObjects[[anRng randomNumberModulo:count]];
                [self logMessage:@"Choosing country %@ next to our chosen countries...", country.countryName];
            }
        }
            break;
            
        case ChooseRandomCountry:
        default:
            country = nil;
            break;
    }
    
    if (country == nil)
    {
        NSArray *unoccupied;
        unoccupied = [gameManager unoccupiedCountries];
        country = unoccupied[[anRng randomNumberModulo:unoccupied.count]];
    }
    
    [gameManager player:self choseCountry:country];
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) _chooseCountry
{
    NSMutableArray *array;
    NSArray *unoccupiedCountries;
    NSEnumerator *countryEnumerator;
    Country *country;
    
    // 1. Make a list of unoccupied countries in continents that we don't have a presence.
    // 2. randomly choose one of these, updating its continent flag
    // 3. otherwise, randomly pick country
    
    unoccupiedCountries = [gameManager unoccupiedCountries];
    
    NSAssert ([unoccupiedCountries count] > 0, @"No unoccupied countries.");
    
    array = [NSMutableArray array];
    countryEnumerator = [unoccupiedCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if ([unoccupiedContinents containsObject:country.continentName] == YES)
            [array addObject:country];
    }
    
    if (array.count > 0)
    {
        country = array[[self.rng randomNumberModulo:array.count]];
        [unoccupiedContinents removeObject:country.continentName];
    }
    else
    {
        country = unoccupiedCountries[[self.rng randomNumberModulo:unoccupiedCountries.count]];
    }
    
    [gameManager player:self choseCountry:country];
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) willEndChoosingCountries
{
    SNRelease (continentChoiceHeap);
    SNRelease (continentChoiceArray);
}

//----------------------------------------------------------------------

- (void) willBeginPlacingInitialArmies
{
    NSEnumerator *countryEnumerator;
    Continent *best;
    Country *country;
    
    best = [self continentWeAreClosestToControlling];
    [self logMessage:@"The best continent appears to be %@", best.continentName];
    
    initialCountryHeap = [[SNHeap alloc] initUsingFunction:minimumTroops context:NULL];
    
    countryEnumerator = [best.countries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country.playerNumber == playerNumber && country.hasEnemyNeighbors == YES)
            [initialCountryHeap insertObject:country];
    }
}

//----------------------------------------------------------------------

// Initial armies are placed randomly.

// Place armies evenly in our countries that are in the continent that we are nearest (in terms of number of
// remaining countries) to controlling.

// 6. Create heap of our countries in that continent
// 7. Distriubute armies between those countries.

// Note: If we control all of a continent, no armies will be placed in it!  How about placing
// all the armies in the countries connected to the continent...

- (void) placeInitialArmies:(int)count
{
    Country *country;
    int l;
    BOOL okay;
    
    NSAssert (initialCountryHeap != nil, @"Initial country heap was not set up.");
    NSAssert ([initialCountryHeap count] > 0, @"No countries in initial countyr heap.");
    
    for (l = 0; l < count; l++)
    {
        country = [initialCountryHeap extractObject];
        okay = [gameManager player:self placesArmies:1 inCountry:country];
        NSAssert1 (okay == YES, @"Could not place army in country: %@", country);
        [initialCountryHeap insertObject:country];
    }
    
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) willEndPlacingInitialArmies
{
    SNRelease (initialCountryHeap);
}

//----------------------------------------------------------------------

- (void) youLostGame
{
    [self logMessage:@"We lost."];
}

//----------------------------------------------------------------------

- (void) youWonGame
{
    [self logMessage:@"We won!"];
}

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

- (void) willBeginTurn
{
    [self logMessage:@"--- Begin"];
}

//----------------------------------------------------------------------
// 1. Place armies in the country with the least number of armies and
//    that also has enemy neighbors.
// 2. Place 1/3 of armies next to country that will most reduce our
//    perimeter if we control it.
//----------------------------------------------------------------------

- (void) placeArmies:(int)count
{
    BOOL okay;
    //int l;
    Country *country, *bestTarget, *best;
    SNHeap *placeCountries;
    int special, bestTroops, tmp;
    Country *first, *second;
    int difference;
    NSEnumerator *enumerator;
    
    //[self _logCurrentWrathValues];
    
#if 1
    placeCountries = [SNHeap heapUsingFunction:minimumTroops context:NULL];
    enumerator = [[self countriesWithAllOptions:CountryFlagsWithEnemyNeighbors from:[self ourCountries]] objectEnumerator];
    [placeCountries insertObjectsFromEnumerator:enumerator];
#else
    placeCountries = [SNHeap heapUsingFunction:minimumTroops context:NULL];
    [placeCountries insertObjectsFromEnumerator:[[self mostConnectedCountries] objectEnumerator]];
#endif
    
    // Most vulnerable doesn't take advantage of attacking weakest neighbors
    //placeCountries = [SNHeap heapUsingFunction:maximumVulnerability context:NULL];
    //enumerator = [[self countriesWithAllOptions:CountryFlagsWithEnemyNeighbors from:[self ourCountries]] objectEnumerator];
    //[placeCountries insertObjectsFromEnumerator:enumerator];
    
    special = 0;
    bestTarget = [self bestCountryToMinimizePerimeter:[self enemyCountriesAlongPerimeter]];
    if (bestTarget != nil)
    {
        special = count / 3;
        count -= special;
        [self logMessage:@"Reserving %d armies to place next to %@.", special, bestTarget.countryName];
    }
    
#if 1
    while (count > 0)
    {
        first = [placeCountries extractObject];
        second = [placeCountries extractObject];
        
        if (second == nil)
        {
            okay = [gameManager player:self placesArmies:count inCountry:first];
            NSAssert1 (okay == YES, @"Could not place army in country: %@", first);
            count = 0;
        }
        else
        {
            difference = second.troopCount - first.troopCount;
            if (difference < 2)
            {
                okay = [gameManager player:self placesArmies:1 inCountry:first];
                NSAssert1 (okay == YES, @"Could not place army in country: %@", first);
                count--;
            }
            else
            {
                difference = MIN (difference, count);
                okay = [gameManager player:self placesArmies:difference inCountry:first];
                NSAssert1 (okay == YES, @"Could not place army in country: %@", first);
                count -= difference;
            }
        }
        
        [placeCountries insertObject:first];
        if (second != nil)
            [placeCountries insertObject:second];
    }
#else
    for (l = 0; l < count; l++)
    {
        country = [placeCountries extractObject];
        
        okay = [gameManager player:self placesArmies:1 inCountry:country];
        NSAssert1 (okay == YES, @"Could not place army in country: %@", country);
        
        // And put it back again.
        [placeCountries insertObject:country];
    }
#endif
#if 0
    if (bestTarget != nil)
        NSLog (@"Should lose armies...");
#endif
    if (bestTarget != nil)
    {
        NSEnumerator *countryEnumerator;
        
        best = bestTarget.neighborCountries.anyObject;
        bestTroops = 0;
        
        // Place 'em in one of our neighboring countries (the one with the most armies.)... nyi
        countryEnumerator = [bestTarget.neighborCountries objectEnumerator];
        while (country = [countryEnumerator nextObject])
        {
            if (country.playerNumber == playerNumber)
            {
                tmp = country.troopCount;
                if (tmp >= bestTroops)
                {
                    bestTroops = tmp;
                    best = country;
                }
            }
        }
        
        [self logMessage:@"Placing extra %d armies in %@", special, best.countryName];
        okay = [gameManager player:self placesArmies:special inCountry:best];
        NSAssert1 (okay == YES, @"Could not place army in country: %@", best);
    }
    
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) attackPhase
{
    NSArray *attackers;
    //NSEnumerator *countryEnumerator;
    BOOL won;
    Country *country;
    //SNHeap *attackingCountryHeap;
    
    //[self analyzePerimeter];
    
    if (attackingCountryHeap == nil)
    {
        attackers = [self countriesWithAllOptions:CountryFlagsWithEnemyNeighbors|CountryFlagsWithTroops
                                             from:[self ourCountries]].allObjects;
        
        // I'm not sure this heap function is working.  I think it means that if we take over a new
        // country, we have to redo it.  Possible take out all it's neighbors and re-insert them.
        attackingCountryHeap = [[SNHeap alloc] initUsingFunction:leastEnemyNeighbors context:NULL];
        [attackingCountryHeap insertObjectsFromEnumerator:[attackers objectEnumerator]];
    }
    
    //won = [self doAttackFromCountry:[attackers objectAtIndex:[[self rng] randomNumberModulo:[attackers count]]]];
    
    won = NO;
    //countryEnumerator = [attackers objectEnumerator];
    //while (won == NO && (country = [countryEnumerator nextObject]) != nil)
    while (won == NO && (country = [attackingCountryHeap extractObject]) != nil)
    {
        if (country.hasEnemyNeighbors == NO)
        {
            [self logMessage:@"%@ no longer has any enemy neighbors.", country.countryName];
        }
        else
            won = [self doAttackFromCountry:country];
    };
    
    // Possibly make it more aggressive -- attack again from all countries that have, say, >20 armies left.
    
    if (won == NO)
        [self turnDone];
    // Otherwise, automatically entered into different state
}

//----------------------------------------------------------------------

- (void) moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination
{
    int tmp, forced;
    
    // Move half the armies to destination
    
    [self logMessage:@"move %d armies between %@ and %@.", count, source.countryName, destination.countryName];
    
    //if ([[source enemyNeighborCountries] count] > 0)
    if (destination.hasEnemyNeighbors == NO)
    {
        // Leave as many as we can in the source.
        [gameManager player:self placesArmies:count inCountry:source];
        [self logMessage:@"Destination %@ has no enemy neighbors, leaving them all in %@.",
         destination.countryName, source.countryName];
        
        // Perhaps, move them to the country closest to the front // nyi
    }
    else if (source.hasEnemyNeighbors == YES)
    {
        [self logMessage:@"%@ has enemy neighbors, only move half the armies.", source.countryName];
        //NSLog (@"====================================================================== case 1");
        // For odd count, leave extra army in the source country.
        forced = destination.troopCount;
        tmp = ((count + forced) / 2) - forced;
        //tmp = (count / 2);
        [gameManager player:self placesArmies:tmp inCountry:destination];
        [gameManager player:self placesArmies:count - tmp inCountry:source];
        
        //NSLog (@"Placing %d armies in %@.", tmp, destination);
        //NSLog (@"Placing %d armies in %@.", count - tmp, source);
    }
    else
    {
        [self logMessage:@"%@ has no enemies, moving all armies to %@.", source.countryName, destination.countryName];
        //NSLog (@"====================================================================== case 2");
        // Move all the armies if there are no enemies by the source country.
        [gameManager player:self placesArmies:count inCountry:destination];
    }
    
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) fortifyPhase:(FortifyRule)fortifyRule
{
    NSEnumerator *countryEnumerator;
    Country *country, *source;
    SNHeap *primaryCountries, *secondaryCountries;
    
    primaryCountries = [SNHeap heapUsingFunction:maximumMovableTroops context:NULL];
    secondaryCountries = [SNHeap heapUsingFunction:maximumMovableTroops context:NULL];
    
    source = nil;
    countryEnumerator = [[self ourCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country.hasMobileTroops == YES)
        {
            if (country.hasEnemyNeighbors == YES)
            {
                [secondaryCountries insertObject:country];
            }
            else
            {
                [primaryCountries insertObject:country];
            }
        }
    }
    
    if (primaryCountries.count == 0 && secondaryCountries.count == 0)
    {
        [self turnDone];
    }
    else
    {
        switch (fortifyRule)
        {
            case FortifyRuleManyToManyNeighbors:
            case FortifyRuleManyToManyConnected:
            case FortifyRuleOneToOneNeighbor:
            case FortifyRuleOneToManyNeighbors:
            default:
                //source = [sourceCountries extractObject]; // Do them starting with the most movable troops.
                source = [primaryCountries extractObject];
                if (source == nil)
                    source = [secondaryCountries extractObject];
                NSAssert (source != nil, @"Primary/secondary count check failed.");
                break;
        }
        
        //NSLog (@"======================================== Fortify from: %@", source);
        [gameManager fortifyArmiesFrom:source];
    }
}

//----------------------------------------------------------------------

// Try to find a friendly neighbor who has unfriendly neighbors
// Otherwise, pick random country.

- (void) placeFortifyingArmies:(int)count fromCountry:(Country *)source
{
    NSSet *potentialTargetCountries;
    NSEnumerator *countryEnumerator;
    Country *country, *destination;
    SNHeap<Country*> *countryHeap;
    FortifyRule fortifyRule;
    int l;
    BOOL thisCase = NO;
    
    //NSLog (@"source: %@", [source countryName]);
    
    if (source.hasEnemyNeighbors == NO && source.hasFriendlyNeighborsWithEnemyNeighbors == NO)
    {
        NSSet *connectedCountries;
        
        //NSLog (@"%@ has no hostile neighbors.", [source countryName]);
        
        connectedCountries = [source ourConnectedCountries];
        
        NSAssert ([connectedCountries count] > 0, @"Connected countries does not appear to include itself.");
        
        if (connectedCountries.count == 1) // It includes itself.
        {
            //NSLog (@"========================================");
            //NSLog (@"The connected countries are: %@", connectedCountries);
            
            // Just leave them alone.  Perhaps try to filter out in above method.
            [gameManager player:self placesArmies:count inCountry:source];
        }
        else
        {
            PathFinder *pathFinder;
            
            // Move 1 step toward nearest (connected) country with hostile neighbors.
            
            //NSLog (@"Moving one step toward one or our countries with hostile neighbors.");
            
            pathFinder = [PathFinder shortestPathInRiskWorld:gameManager.world
                                                 fromCountry:source
                                                forCountries:PFCountryForPlayer
                                                     context:(void *)playerNumber
                                            distanceFunction:PFConstantDistance];
            
            destination = [pathFinder firstStepToAcceptableCountry:PFCountryForPlayerHasEnemyNeighbors
                                                           context:(void *)playerNumber];
            
            //NSLog (@"%@ -> %@", [source countryName], [destination countryName]);
            
            [gameManager player:self placesArmies:count inCountry:destination];
        }
    }
    else
    {
        if (source.hasEnemyNeighbors == NO && source.hasFriendlyNeighborsWithEnemyNeighbors == YES)
        {
            //NSLog (@"New special case.");
            thisCase = YES;
        }
        
        //NSLog (@"Hostile neighbors: %@", [source enemyNeighborCountries]);
        
        fortifyRule = [gameManager gameConfiguration].fortifyRule;
        countryHeap = [SNHeap heapUsingFunction:minimumTroops context:NULL];
        
        destination = nil;
        
        if (fortifyRule == FortifyRuleManyToManyConnected)
        {
            potentialTargetCountries = [source ourConnectedCountries];
        }
        else
        {
            potentialTargetCountries = [source ourNeighborCountries];
        }
        countryEnumerator = [potentialTargetCountries objectEnumerator];
        
        while (country = [countryEnumerator nextObject])
        {
            // Our neighbors with enemies
            if (country.hasEnemyNeighbors == YES)
            {
                [countryHeap insertObject:country];
#if 0
                if (thisCase == YES)
                    NSLog (@"%@ has enemies.", [country countryName]);
#endif
            }
        }
        
        // In this case, the source has hostile neighbors.
        if (source.hasEnemyNeighbors == YES)
            [countryHeap insertObject:source];
        
        NSAssert ([countryHeap count] != 0, @"This shouldn't happen.");
        
        switch (fortifyRule)
        {
            case FortifyRuleOneToManyNeighbors:
            case FortifyRuleManyToManyNeighbors:
                // No neighbors with enemies: Move armies toward nearest country with enemy neighbors
                // Neighbors with enemies: move armies to weakest neighbor with enemies
                
            case FortifyRuleManyToManyConnected:
                for (l = 0; l < count; l++)
                {
                    destination = [countryHeap extractObject];
                    [gameManager player:self placesArmies:1 inCountry:destination];
                    [countryHeap insertObject:destination];
                }
                break;
                
            case FortifyRuleOneToOneNeighbor:
            default:
                // Distribute troops evenly between source and destination
                
                destination = [countryHeap extractObject];
                if (source.hasEnemyNeighbors == YES)
                {
                    [countryHeap removeAllObjects];
                    [countryHeap insertObject:source];
                    [countryHeap insertObject:destination];
                    
                    for (l = 0; l < count; l++)
                    {
                        destination = [countryHeap extractObject];
                        [gameManager player:self placesArmies:1 inCountry:destination];
                        [countryHeap insertObject:destination];
                    }
                }
                else
                {
                    [gameManager player:self placesArmies:count inCountry:destination];
                }
                break;
        }
    }
    
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) willEndTurn
{
    // I think it's still best (simplest) to just rebuild the data structure.
    SNRelease (attackingCountryHeap);
    
    [self logMessage:@"--- End\n"];
}

//======================================================================
// Inform computer players of important events that happed during other
// players turns.
//======================================================================

- (void) playerNumber:(Player)number attackedCountry:(Country *)attackedCountry
{
    NSAssert (number < 7, @"Player number out of range.");
    
    attackedCount[number]++;
}

//----------------------------------------------------------------------

- (void) playerNumber:(Player)number capturedCountry:(Country *)capturedCountry
{
    NSEnumerator *countryEnumerator;
    Country *country;
    Continent *continent;
    BOOL flag;
    
    flag = YES;
    
    NSAssert (number < 7, @"Player number out of range.");
    
    lostCountryCount[number]++;
    
    // And then check if we had the rest of the continent.
    continent = [gameManager.world continentNamed:capturedCountry.continentName];
    countryEnumerator = [continent.countries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country != capturedCountry && country.playerNumber != playerNumber)
        {
            flag = NO;
            break;
        }
    }
    
    if (flag == YES)
    {
        brokenContinentCount[number]++;
    }
    
    [self logMessage:@"%@ was captured by player number %ld.", capturedCountry.countryName, (long)number];
}

//======================================================================
// Custom methods
//======================================================================

- (BOOL) doAttackFromCountry:(Country *)attacker
{
    NSSet *enemies;
    Country *weakest;
    int weakestTroopCount, troopCount;
    NSEnumerator *countryEnumerator;
    Country *country;
    AttackResult attackResult;
    
    attackResult.conqueredCountry = NO;
    
    [self logMessage:@"Attacking from %@.", attacker.countryName];
    
    weakest = [self bestCountryToMinimizePerimeter:[attacker enemyNeighborCountries]];
    if (weakest != nil)
    {
        [self logMessage:@"Minimize perimeter with: %@", weakest.countryName];
    }
#if 0
    if (weakest == nil)
    {
        weakest = [self bestCountryToControlContinents:[attacker enemyNeighborCountries]];
        if (weakest != nil)
            NSLog (@"Control continent with: %@", [weakest countryName]);
    }
#endif
    if (weakest == nil)
    {
        //weakest = nil;
        weakestTroopCount = 999999;
        enemies = [attacker enemyNeighborCountries];
        countryEnumerator = [enemies objectEnumerator];
        
        while (country = [countryEnumerator nextObject])
        {
            troopCount = country.troopCount;
            if (troopCount < weakestTroopCount)
            {
                weakestTroopCount = troopCount;
                weakest = country;
            }
        }
        
        if (weakest != nil)
            [self logMessage:@"Chose %@ as weakest neighbor.", weakest.countryName];
    }
    
    if (weakest != nil)
    {
        if (attacker.troopCount > 5)
        {
            attackResult = [gameManager attackFromCountry:attacker
                                                toCountry:weakest
                                        untilArmiesRemain:2
                                 moveAllArmiesUponVictory:NO];
        }
        else
        {
            attackResult = [gameManager attackFromCountry:attacker
                                                toCountry:weakest
                                        untilArmiesRemain:(int)[self.rng randomNumberBetween:2:attacker.troopCount]
                                 moveAllArmiesUponVictory:NO];
        }
#if 0
        //NSLog (@"Won attack from %@ to %@? %@", attacker, weakest, won == YES ? @"Yes" : @"No");
#endif
    }
    
    return attackResult.conqueredCountry;
}

//----------------------------------------------------------------------

// unoccupied means army is nil (not troopCounty == 0)
- (NSSet *) unoccupiedCountriesInContinentNamed:(NSString *)continentName
{
    NSMutableSet *set;
    NSEnumerator *countryEnumerator;
    Country *country;
    RiskWorld *world;
    
    world = gameManager.world;
    
    set = [NSMutableSet set];
    countryEnumerator = [[world continentNamed:continentName].countries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country.playerNumber == 0)
            [set addObject:country];
    }
    
    return set;
}

//----------------------------------------------------------------------

// 1. go through each continent
// 2. note number of countries in each continent
// 3. note number of our countries in each continent
// 4. record total - ours
// 5. choose continent with lowest value (total - ours) // Secondary may be number of perimeter countries for continent...
// We need to be sure that we *do* have countries in that continent!

- (Continent *) continentWeAreClosestToControlling
{
    RiskWorld *world;
    //NSSet *continents, *countries;
    NSArray *continents;
    NSEnumerator *continentEnumerator, *countryEnumerator;
    Continent *continent, *best;
    Country *country;
    NSInteger total, ours, minimum;
    
    minimum = 1000000;
    best = nil;
    
    world = gameManager.world;
    continents = world.continents.allValues;
    continentEnumerator = [continents objectEnumerator];
    while (continent = [continentEnumerator nextObject])
    {
        total = continent.countries.count;
        ours = 0;
        countryEnumerator = [continent.countries objectEnumerator];
        while (country = [countryEnumerator nextObject])
        {
            if (country.playerNumber == playerNumber)
                ours++;
        }
        
        if (ours > 0 && total - ours < minimum && ours != total)
        {
            minimum = total - ours;
            best = continent;
        }
    }
    
    //NSLog (@"Our best continent (%d left) would be: %@", minimum, [best continentName]);
    NSAssert (best != nil, @"Couldn't determine best continent.");
    
    return best;
}

//----------------------------------------------------------------------

- (int) perimeterCountryCount
{
    NSEnumerator *countryEnumerator;
    Country *country;
    int count;
    
    count = 0;
    countryEnumerator = [[self ourCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country.hasEnemyNeighbors == YES)
            count++;
    }
    
    return count;
}

//----------------------------------------------------------------------

- (int) perimeterCountryCountExcludingCountry:(Country *)excludedCountry
{
    NSEnumerator *countryEnumerator;
    Country *country;
    int count;
    
    count = 0;
    countryEnumerator = [[self ourCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if ([country hasEnemyNeighborsExcludingCountry:excludedCountry] == YES)
            count++;
    }
    
    return count;
}

//----------------------------------------------------------------------

- (NSSet *) enemyCountriesAlongPerimeter
{
    NSEnumerator *countryEnumerator;
    Country *country;
    NSMutableSet *enemies;
    
    enemies = [NSMutableSet set];
    countryEnumerator = [[self ourCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        [enemies unionSet:[country enemyNeighborCountries]];
    }
    
    return enemies;
}

//----------------------------------------------------------------------

- (void) analyzePerimeter
{
    int currentPerimeterCount;
    Country *best;
    
    best = nil;
    currentPerimeterCount = [self perimeterCountryCount];
    
    best = [self minimizePerimeter:currentPerimeterCount ofCountries:[self enemyCountriesAlongPerimeter]];
    
    //NSLog (@"best is %@", best);
    //NSLog (@"Perimeter: %d, best: %d by taking %@", currentPerimeterCount, bestCount, [best countryName]);
}

//----------------------------------------------------------------------

- (Country *) bestCountryToMinimizePerimeter:(NSSet *)potentialCountries
{
    int currentPerimeterCount;
    Country *best;
    
    currentPerimeterCount = [self perimeterCountryCount];
    best = [self minimizePerimeter:currentPerimeterCount ofCountries:potentialCountries];
    
    return best;
}

//----------------------------------------------------------------------

- (Country *) minimizePerimeter:(int)current ofCountries:(NSSet *)potentialCountries
{
    NSEnumerator *countryEnumerator;
    int bestCount, tmp;
    Country *country, *best;
    
    bestCount = current;
    best = nil;
    
    countryEnumerator = [potentialCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        tmp = [self perimeterCountryCountExcludingCountry:country];
        if (tmp < bestCount)
        {
            bestCount = tmp;
            best = country;
        }
    }
    
    return best;
}

//----------------------------------------------------------------------

- (Country *) bestCountryToControlContinents:(NSSet *)potentialCountries
{
    RiskWorld *world;
    NSArray *continents;
    NSEnumerator *continentEnumerator, *countryEnumerator;
    Continent *continent;
    Country *country, *bestCountry;
    NSInteger total, ours, minimum, current;
    NSMutableDictionary *continentValues;
    
    continentValues = [NSMutableDictionary dictionary];
    
    world = gameManager.world;
    continents = world.continents.allValues;
    continentEnumerator = [continents objectEnumerator];
    while (continent = [continentEnumerator nextObject])
    {
        total = continent.countries.count;
        ours = 0;
        countryEnumerator = [continent.countries objectEnumerator];
        while (country = [countryEnumerator nextObject])
        {
            if (country.playerNumber == playerNumber)
                ours++;
        }
        
        continentValues[continent.continentName] = @(total - ours);
    }
    
    // Now determine best country, based on calculated continent values
    
    bestCountry = nil;
    minimum = 100000;
    
    countryEnumerator = [potentialCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        continent = [world continentNamed:country.continentName];
        current = [continentValues[continent.continentName] intValue];
        if (current < minimum)
        {
            minimum = current;
            bestCountry = country;
        }
    }
    
    //NSLog (@"Our best continent (%d left) would be: %@ with %@", minimum, [bestCountry continentName], [bestCountry countryName]);
    NSAssert (bestCountry != nil, @"Couldn't determine best country.");
    
    return bestCountry;
}

//----------------------------------------------------------------------

- (void) _logCurrentWrathValues
{
    int l;
    int total;
    
    for (l = 1; l < 7; l++)
    {
        total = attackedCount[l] * WRATH_ATTACKED +
        lostCountryCount[l] * WRATH_LOST_COUNTRY + brokenContinentCount[l] * WRATH_BROKEN_CONTINENT;
        NSLog (@"%d: attacked: %d, lost: %d, broken: %d, total: %d",
               l, attackedCount[l], lostCountryCount[l], brokenContinentCount[l], total);
    }
}

//----------------------------------------------------------------------

- (NSSet *) mostConnectedCountries
{
    NSMutableSet *remainingCountries;
    NSInteger count, tmp;
    Country *maximum, *country;
    NSSet *connected;
    NSMutableSet *exteriorCountries;
    NSEnumerator *countryEnumerator;
    
    count = 0;
    maximum = nil;
    
    //remainingCountries = [NSMutableSet setWithSet:[self ourCountries]];
    remainingCountries = [NSMutableSet
                          setWithSet:
                          [self
                           countriesWithAllOptions:CountryFlagsWithEnemyNeighbors
                           from:[self ourCountries]]];
    while ((country = [remainingCountries anyObject]))
    {
        connected = [country ourConnectedCountries];
        tmp = connected.count;
        if (tmp > count)
        {
            count = tmp;
            maximum = country;
        }
        
        [remainingCountries minusSet:connected];
    }
    
    exteriorCountries = [NSMutableSet set];
    
    countryEnumerator = [[maximum ourConnectedCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country.hasEnemyNeighbors == YES)
            [exteriorCountries addObject:country];
    }
    
    return exteriorCountries;
}

@end
