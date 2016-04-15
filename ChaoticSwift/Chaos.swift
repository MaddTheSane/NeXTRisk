//
//  Chaos.swift
//  Risk
//
//  Created by C.W. Betts on 4/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Cocoa
import RiskKit

public class Chaos: RiskPlayer {
	private var unoccupiedContinents = Set<String>()
	private var attackingCountries = Set<Country>()

	override public init!(playerName aName: String!, number: Player, gameManager aManager: RiskGameManager!) {
		super.init(playerName: aName, number: number, gameManager: aManager)
		
		let world = gameManager.world
		let continents = world.continents
		
		unoccupiedContinents.intersectInPlace(continents.keys)
	}

/*
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

- initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager
{
    RiskWorld *world;
    NSDictionary *continents;

    [super initWithPlayerName:aName number:number gameManager:aManager];

    // Contains the names of continents.
    unoccupiedContinents = [[NSMutableSet set] retain];

    world = [gameManager world];
    continents = [world continents];

    [unoccupiedContinents addObjectsFromArray:[continents allKeys]];
    attackingCountries = nil;

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (unoccupiedContinents);
    SNRelease (attackingCountries);

    [super dealloc];
}

//======================================================================
// Subclass Responsibilities
//======================================================================
*/
//----------------------------------------------------------------------
//MARK:- Card management
//----------------------------------------------------------------------
	/// While the game manager will automatically turn in our best sets for
	/// us if we don't choose the cards ourselves, we'll do it ourselves
	/// just to be nice.
	public override func mustTurnInCards() {
		gameManager.automaticallyTurnInCardsForPlayerNumber(playerNumber)
	}
	/*
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
        if ([unoccupiedContinents containsObject:[country continentName]] == YES)
            [array addObject:country];
    }

    if ([array count] > 0)
    {
        country = [array objectAtIndex:[[self rng] randomNumberModulo:[array count]]];
        [unoccupiedContinents removeObject:[country continentName]];
    }
    else
    {
        country = [unoccupiedCountries objectAtIndex:[[self rng] randomNumberModulo:[unoccupiedCountries count]]];
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
    ourCountries = [[self countriesWithAllOptions:CountryFlagsWithEnemyNeighbors from:[self ourCountries]] allObjects];
    countryCount = [ourCountries count];

    NSAssert (countryCount > 0, @"We have no countries!");

    for (l = 0; l < count; l++)
    {
        country = [ourCountries objectAtIndex:[[self rng] randomNumberModulo:countryCount]];

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
        attackingCountries = [[NSMutableSet setWithSet:[self countriesWithAllOptions:CountryFlagsWithEnemyNeighbors|CountryFlagsWithTroops
                                                             from:[self ourCountries]]] retain];
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
    count = [sourceCountries count];

    if (count == 0)
    {
        [self turnDone];
    }
    else
    {
        switch (fortifyRule)
        {
          case ManyToManyNeighbors:
          case ManyToManyConnected:
              source = [sourceCountries anyObject]; // All of them will be done in turn.
              break;
              
          case OneToOneNeighbor:
          case OneToManyNeighbors:
          default:
              sourceArray = [sourceCountries allObjects];
              source = [sourceArray objectAtIndex:[[self rng] randomNumberModulo:count]];
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
        if ([country hasEnemyNeighbors] == YES)
        {
            destination = country;
            break;
        }
    }

    if (destination == nil)
    {
        // Pick random country
        neighborCount = [ourNeighborCountries count];
        destination = [[ourNeighborCountries allObjects] objectAtIndex:[[self rng] randomNumberModulo:neighborCount]];
    }

    [gameManager player:self placesArmies:count inCountry:destination];
    [self turnDone];
}

//----------------------------------------------------------------------
*/
	public override func willEndTurn() {
		attackingCountries.removeAll()
	}
//======================================================================
//MARK: - Custom methods
//======================================================================

/// attack the weakest neighbor (bully tactics).
	func doAttackFromCountry(attacker: Country) -> Bool {
		let enemies = attacker.enemyNeighborCountries()!
		var weakest: Country!
		var attackResult = AttackResult()
		attackResult.conqueredCountry = false
		var weakestTroopCount = Int32(999999)
		
		for country in enemies {
			let troopCount = country.troopCount
			if troopCount < weakestTroopCount {
				weakest = country
				weakestTroopCount = troopCount
			}
		}
		
		if let weakest = weakest {
			attackResult = gameManager.attackFromCountry(attacker, toCountry: weakest, untilArmiesRemain: Int32(rng.randomNumberBetween(1, Int(attacker.troopCount))), moveAllArmiesUponVictory: false)
			
			//NSLog (@"Won attack from %@ to %@? %@", attacker, weakest, won == YES ? @"Yes" : @"No");
		}
		
		return attackResult.conqueredCountry.boolValue
	}
}
