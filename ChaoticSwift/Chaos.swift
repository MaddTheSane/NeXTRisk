//
//  Chaos.swift
//  Risk
//
//  Created by C.W. Betts on 4/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Cocoa
import RiskKit
import RiskKit.RiskPlayer

public class Chaos: RiskPlayer {
	private var unoccupiedContinents = Set<String>()
	private var attackingCountries = Set<RKCountry>()

	override public init(playerName aName: String, number: RKPlayer, gameManager aManager: RiskGameManager) {
		super.init(playerName: aName, number: number, gameManager: aManager)
		
		let world = gameManager.world
		let continents = world.continents
		
		unoccupiedContinents.formIntersection(continents.keys)
	}

	//MARK:- Subclass Responsibilities

	//MARK: Card management

	/// While the game manager will automatically turn in our best sets for
	/// us if we don't choose the cards ourselves, we'll do it ourselves
	/// just to be nice.
	public override func mustTurnInCards() {
		gameManager.automaticallyTurnInCards(forPlayerNumber: playerNumber)
	}

	//MARK: Initial game phases

	/// A chaotic player seeks to wreak havoc (in a very limited way) on the
	/// rest of the players.  Toward this end he tries to choose at least one
	/// country in each continent.  After that he chooses random countries.
	public override func chooseCountry() {
		// 1. Make a list of unoccupied countries in continents that we don't have a presence.
		// 2. Randomly choose one of these, updating its continent flag
		// 3. Otherwise, randomly pick country
		
		let unoccupiedCountries = gameManager.unoccupiedCountries
		assert(unoccupiedCountries.count > 0, "No unoccupied countries.")
		var array = [RKCountry]()
		let country: RKCountry
		for country in unoccupiedCountries {
			if unoccupiedContinents.contains(country.continentName) {
				array.append(country)
			}
		}
		
		if array.count > 0 {
			country = array.randomElement()!
			unoccupiedContinents.remove(country.continentName)
		} else {
			country = unoccupiedCountries.randomElement()!
		}
		gameManager.player(self, choseCountry: country)
		turnDone()
	}


	/// place all armies in random countries with `-placeArmies:`.
	public override func placeInitialArmies(_ count: Int32) {
		placeArmies(count)
	}

	//MARK: Regular turn phases

	public override func placeArmies(_ count: Int32) {
		//myCountries = [[self myCountriesWithHostileNeighborsAndCapableOfAttack:NO] allObjects];
		let ourCountries = countries(withAllOptions: .withEnemyNeighbors, from: self.ourCountries)
		let countryCount = ourCountries.count
		
		assert(countryCount > 0, "We have no countries!");
		
		for _ in 0..<count {
			let country = ourCountries.randomElement()!
			
			let okay = gameManager.player(self, placesArmies: 1, in: country)
			assert(okay, "Could not place army in country: \(country)");
		}
		turnDone()
	}

	public override func attackPhase() {
		if attackingCountries.isEmpty {
			attackingCountries = countries(withAllOptions: [.withEnemyNeighbors, .withTroops], from: ourCountries)
		}
		var mustEndTurn = false
		
		for country in attackingCountries {
			mustEndTurn = doAttack(from: country)
			if mustEndTurn {
				break
			}
		}
		
		if !mustEndTurn {
			turnDone()
		}
		// Otherwise, automatically entered into different state
	}

	/// Move forward half of the remaining armies.
	public override func moveAttackingArmies(_ count: Int32, between source: RKCountry, _ destination: RKCountry) {
		// Move half the armies to destination
		// For odd count, leave extra army in the source country.
		let tmp = count / 2;
		gameManager.player(self, placesArmies: tmp, in: destination)
		gameManager.player(self, placesArmies: count - tmp, in: source)
	}

	public override func fortifyPhase(_ fortifyRule: RKFortifyRule) {
		let sourceCountries = countries(withAllOptions: [.withMovableTroops, .withoutEnemyNeighbors], from: ourCountries)
		let source: RKCountry
		
		guard !sourceCountries.isEmpty else {
			turnDone()
			return
		}
		
		switch fortifyRule {
		case .manyToManyNeighbors, .manyToManyConnected:
			source = sourceCountries.first!; // All of them will be done in turn.
			
		case .oneToOneNeighbor, .oneToManyNeighbors:
			source = sourceCountries.randomElement()!
		}
		
		gameManager.fortifyArmies(from: source)
	}

	/// Try to find a friendly neighbor who has unfriendly neighbors
	/// Otherwise, pick random country.
	public override func placeFortifyingArmies(_ count: Int32, from source: RKCountry) {
		var destination: RKCountry?
		
		let ourNeighborCountries = source.ourNeighborCountries
		
		for country in ourNeighborCountries {
			if country.hasEnemyNeighbors {
				destination = country
				break
			}
		}
		
		if destination == nil {
			// Pick random country
			destination = ourNeighborCountries.randomElement()
		}
		
		gameManager.player(self, placesArmies: count, in: destination!)
		turnDone()
	}

	public override func willEndTurn() {
		attackingCountries.removeAll()
	}

	//MARK: - Custom methods

	/// attack the weakest neighbor (bully tactics).
	func doAttack(from attacker: RKCountry) -> Bool {
		let enemies = attacker.enemyNeighborCountries
		var weakest: RKCountry?
		var attackResult = RKAttackResult()
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
			attackResult = gameManager.attack(from: attacker, to: weakest, untilArmiesRemain: RKArmyCount.random(in: 1 ..< attacker.troopCount), moveAllArmiesUponVictory: false)
			
			//NSLog (@"Won attack from %@ to %@? %@", attacker, weakest, won == YES ? @"Yes" : @"No");
		}
		
		return attackResult.conqueredCountry.boolValue
	}
}
