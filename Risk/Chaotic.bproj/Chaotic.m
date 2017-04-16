//
// Part of Risk by Mike Ferris
//

#import <RiskKit/Risk.h>

RCSID ("$Id: Chaotic.m,v 1.4 1997/12/15 21:09:48 nygard Exp $");

#import "Chaotic.h"

#import <RiskKit/Country.h>
#import <RiskKit/RiskGameManager.h>
#import <RiskKit/RiskWorld.h>
#import <RiskKit/SNRandom.h>

//======================================================================
// The Chaotic player provides a relatively simple but complete
// implementation of a computer player.
//======================================================================

#define Chaotic_VERSION 1

@implementation Chaotic

+ (void) load
{
    //NSLog (@"Chaotic.");
}

//----------------------------------------------------------------------

+ (void) initialize
{
    if (self == [Chaotic class])
    {
        [self setVersion:Chaotic_VERSION];
    }
}

//----------------------------------------------------------------------

- (instancetype) initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager
{
    RiskWorld *world;
    NSDictionary<NSString*,Continent *> *continents;
    
    if (self = [super initWithPlayerName:aName number:number gameManager:aManager]) {
        // Contains the names of continents.
        unoccupiedContinents = [[NSMutableSet alloc] init];
        
        world = gameManager.world;
        continents = world.continents;
        
        [unoccupiedContinents addObjectsFromArray:continents.allKeys];
        attackingCountries = nil;
    }
    
    return self;
}

//======================================================================
// Subclass Responsibilities
//======================================================================

//----------------------------------------------------------------------
// Card management
//----------------------------------------------------------------------

- (void) mustTurnInCards
{
    // While the game manager will automatically turn in our best sets for
    // us if we don't choose the cards ourselves, we'll do it ourselves
    // just to be nice.
    
    [gameManager automaticallyTurnInCardsForPlayerNumber:playerNumber];
}

//----------------------------------------------------------------------
// Initial game phases
//----------------------------------------------------------------------

// A chaotic player seeks to wreak havoc (in a very limited way) on the
// rest of the players.  Toward this end he tries to choose at least one
// country in each continent.  After that he chooses random countries.

- (void) chooseCountry
{
    NSMutableArray *array;
    NSArray *unoccupiedCountries;
    NSEnumerator *countryEnumerator;
    Country *country;
    
    // 1. Make a list of unoccupied countries in continents that we don't have a presence.
    // 2. Randomly choose one of these, updating its continent flag
    // 3. Otherwise, randomly pick country
    
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

// place all armies in random countries with -placeArmies:.
- (void) placeInitialArmies:(int)count
{
    [self placeArmies:count];
}

//----------------------------------------------------------------------
// Regular turn phases
//----------------------------------------------------------------------

- (void) placeArmies:(int)count
{
    NSArray *ourCountries;
    NSInteger countryCount;
    BOOL okay;
    NSInteger l;
    Country *country;
    
    //myCountries = [[self myCountriesWithHostileNeighborsAndCapableOfAttack:NO] allObjects];
    ourCountries = [self countriesWithAllOptions:CountryFlagsWithEnemyNeighbors from:[self ourCountries]].allObjects;
    countryCount = ourCountries.count;
    
    NSAssert (countryCount > 0, @"We have no countries!");
    
    for (l = 0; l < count; l++)
    {
        country = ourCountries[[self.rng randomNumberModulo:countryCount]];
        
        okay = [gameManager player:self placesArmies:1 inCountry:country];
        NSAssert1 (okay == YES, @"Could not place army in country: %@", country);
    }
    
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) attackPhase
{
    NSEnumerator *countryEnumerator;
    BOOL mustEndTurn;
    Country *country;
    
    if (attackingCountries == nil)
    {
        attackingCountries = [[self countriesWithAllOptions:CountryFlagsWithEnemyNeighbors|CountryFlagsWithTroops
                                                       from:[self ourCountries]] mutableCopy];
    }
    
    mustEndTurn = NO;
    countryEnumerator = [attackingCountries objectEnumerator];
    while (mustEndTurn == NO && (country = [countryEnumerator nextObject]) != nil)
    {
        mustEndTurn = [self doAttackFromCountry:country];
    };
    
    if (mustEndTurn == NO)
    {
        [self turnDone];
    }
    // Otherwise, automatically entered into different state
}

//----------------------------------------------------------------------

// Move forward half of the remaining armies.
- (void) moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination
{
    int tmp;
    
    // Move half the armies to destination
    // For odd count, leave extra army in the source country.
    tmp = count / 2;
    [gameManager player:self placesArmies:tmp inCountry:destination];
    [gameManager player:self placesArmies:count - tmp inCountry:source];
    
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) fortifyPhase:(FortifyRule)fortifyRule
{
    NSSet *sourceCountries;
    Country *source = nil;
    NSInteger count;
    NSArray *sourceArray;
    
    sourceCountries = [self countriesWithAllOptions:CountryFlagsWithMovableTroops|CountryFlagsWithoutEnemyNeighbors from:[self ourCountries]];
    count = sourceCountries.count;
    
    if (count == 0)
    {
        [self turnDone];
    }
    else
    {
        switch (fortifyRule)
        {
            case FortifyRuleManyToManyNeighbors:
            case FortifyRuleManyToManyConnected:
                source = [sourceCountries anyObject]; // All of them will be done in turn.
                break;
                
            case FortifyRuleOneToOneNeighbor:
            case FortifyRuleOneToManyNeighbors:
            default:
                sourceArray = sourceCountries.allObjects;
                source = sourceArray[[self.rng randomNumberModulo:count]];
                break;
        }
        
        [gameManager fortifyArmiesFrom:source];
    }
}

//----------------------------------------------------------------------

// Try to find a friendly neighbor who has unfriendly neighbors
// Otherwise, pick random country.

- (void) placeFortifyingArmies:(int)count fromCountry:(Country *)source
{
    NSSet *ourNeighborCountries;
    NSEnumerator *countryEnumerator;
    Country *country, *destination;
    NSInteger neighborCount;
    
    destination = nil;
    
    ourNeighborCountries = [source ourNeighborCountries];
    countryEnumerator = [ourNeighborCountries objectEnumerator];
    
    while (country = [countryEnumerator nextObject])
    {
        if (country.hasEnemyNeighbors == YES)
        {
            destination = country;
            break;
        }
    }
    
    if (destination == nil)
    {
        // Pick random country
        neighborCount = ourNeighborCountries.count;
        destination = ourNeighborCountries.allObjects[[self.rng randomNumberModulo:neighborCount]];
    }
    
    [gameManager player:self placesArmies:count inCountry:destination];
    [self turnDone];
}

//----------------------------------------------------------------------

- (void) willEndTurn
{
    SNRelease (attackingCountries);
}

//======================================================================
// Custom methods
//======================================================================

// attack the weakest neighbor (bully tactics).
- (BOOL) doAttackFromCountry:(Country *)attacker
{
    NSSet<Country*> *enemies;
    Country *weakest;
    int weakestTroopCount;
    AttackResult attackResult;
    
    attackResult.conqueredCountry = NO;
    weakest = nil;
    weakestTroopCount = 999999;
    enemies = [attacker enemyNeighborCountries];
    for (Country *country in enemies)
    {
        int troopCount = country.troopCount;
        if (troopCount < weakestTroopCount)
        {
            weakestTroopCount = troopCount;
            weakest = country;
        }
    }
    
    if (weakest != nil)
    {
        attackResult = [gameManager attackFromCountry:attacker
                                            toCountry:weakest
                                    untilArmiesRemain:(int)[self.rng randomNumberBetween:1:attacker.troopCount]
                             moveAllArmiesUponVictory:NO];
        
        //NSLog (@"Won attack from %@ to %@? %@", attacker, weakest, won == YES ? @"Yes" : @"No");
    }
    
    return attackResult.conqueredCountry;
}

@end
