// PlayerCode.m
// Part of Risk by Mike Ferris
// Based on Chaotic.m by Mike Ferris, modified by Royce Howland

// From Mike's original Chaotic.m:
// Chaotic players don't have much strategy, but they do attack, turn in
// cards, and generally try to screw other players up.

#import "PlayerCode.h"
#import "SortedList.h"
#import <AppKit/AppKit.h>

#define rearguard()	(2 * ((gameTurn / 4) + 1))

@implementation Strat

+ (void)initialize
// set the version number
{
	if (self == [Strat class])  {
		[self setVersion:1];
	}
}

- (instancetype)initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager
// initialize my instance vars
{
	NSArray<RKCountry*> *countries;
	int i, j, countryNum;
    RKCountry *theCountry;
    id otherCountries;
	int k, exits, forneighbors, contneighbors;
	
	// always call the super
	self = [super initWithPlayerName:aName number:number gameManager:aManager];
	
	// Loop through each continent, setting up various instance vars.
	for (i = 0; i < 6; i++)  {
		// No country possessed in this continent yet.
		countryInContinent[i] = NO;

		// Set up the country/continent array for this continent.
		// Also init country conquered array.
		countries = [self countriesInContinent:i];
		for (j = 0; j < [countries count]; j++) {
			countryNum = [[countries objectAtIndex:j] idNum];
			if (countryNum >= MINCOUNTRY && countryNum <= MAXCOUNTRY) {
				countryContinents[countryNum] = i;
				turnCountryConquered[countryNum] = 0;
			}
		}
	}

	// For each continent, find the number of countries on it that
	// border another continent.  Also find the number of countries
	// on other continents that border each country on it, and that
	// border it in total (non-unique; a country on continent B that
	// borders two countries on continent A counts twice as a neighbor
	// of continent A).
	continentFudge[RiskContinentNorthAmerica] = initContinentFudge[RiskContinentNorthAmerica] = 50;
	continentFudge[RiskContinentSouthAmerica] = initContinentFudge[RiskContinentSouthAmerica] = 50;
	continentFudge[RiskContinentEurope] = initContinentFudge[RiskContinentEurope] = 25;
	continentFudge[RiskContinentAfrica] = initContinentFudge[RiskContinentAfrica] = 25;
	continentFudge[RiskContinentAsia] = initContinentFudge[RiskContinentAsia] = -50;
	continentFudge[RiskContinentAustralia] = initContinentFudge[RiskContinentAustralia] = 50;
	for (i = 0; i < 6; i++)  {
		initContinentFudge[i] += [rng randomNumberWithMaximum:30] - 15;
		continentExits[i] = continentNeighbors[i] = contneighbors = 0;
		countries = [gameManager countriesInContinent:i];
		for (j = 0; j < [countries count]; j++) {
			forneighbors = exits = 0;
			theCountry = [countries objectAtIndex:j];
			countryNum = [theCountry idNum];
			countryNeighbors[countryNum] = 0;
			otherCountries = [self neighborsTo:theCountry];
			for (k = 0; k < [otherCountries count]; k++) {
				countryNeighbors[countryNum]++;
				if (countryContinents[countryNum] !=
						countryContinents[[[otherCountries objectAtIndex:k] idNum]]) {
					exits = 1;
					forneighbors++;
					contneighbors++;
				}
			}
			countryForeignNeighbors[countryNum] = forneighbors;
			if (exits)
				continentExits[i]++;
		}
		continentNeighbors[i] = contneighbors;
	}
#if 0
	continentExits[NORTH_AMERICA] = 3;
	continentNeighbors[NORTH_AMERICA] = 3;
	continentExits[SOUTH_AMERICA] = 2;
	continentNeighbors[SOUTH_AMERICA] = 2;
	continentExits[EUROPE] = 4;
	continentNeighbors[EUROPE] = 8;
	continentExits[AFRICA] = 3;
	continentNeighbors[AFRICA] = 6;
	continentExits[ASIA] = 5;
	continentNeighbors[ASIA] = 8;
	continentExits[AUSTRALIA] = 1;
	continentNeighbors[AUSTRALIA] = 1;
#endif

	gameTurn = 0;
	numCountriesLastTurn = 0;
	turnsSinceVict = 0;
	front1 = front2 = front3 = -1;

	// Attack all out all the time?
	banzaiMode = NO;
	if ([rng randomNumberWithMaximum:99] >= 85)
		banzaiMode = YES;

	// Limit our attack to a lesser number of fronts depending on
	// various conditions?
	limitMode = NO;
	if ([rng randomNumberWithMaximum:99] >= 75)
		limitMode = YES;

	return self;
}

// *****************subclass responsibilities*********************

- (void)chooseCountry
// A chaotic player seeks to wreak havoc (in a very limited way) on the
// rest of the players.  Toward this end he tries to choose at least one
// country in each continent.  After that he chooses random countries.
{
	RKCountry *temp, *country=nil;
	int cont=0;

#if 0
	// first try to get a country in each of the continents
	// find the first continent we haven't got a country in yet
	while ((cont<6) && (country==nil))  {
		if (countryInContinent[cont] == NO)  {
			id contList = [self countriesInContinent:cont];
			int i, c = [contList count];
			// we found a continent we don't have a country in yet.
			// see if there are unoccupied countries in it.
			
			// loop backwards cause we're gonna delete from the list
			for (i=c-1;i>=0;i--)  {
				// if this country is occupied remove it
				if ([[contList objectAt:i] player] != -1)  {
					[contList removeObjectAt:i];
				}
			}
			// now contList contains a list of all unoccupied countries
			// in the continent, but are there any?
			if ([contList count] > 0)  {
				// Yes, so choose a random country
				country=[contList objectAt:[rng randMax:[contList count]-1]];
				// record the fact that we've got a country in this continent
				countryInContinent[cont]=YES;
			}
			// remember to always free any list you ask for
			[contList free];
		}
		cont++;
	}
	
	// choose a random country if we still haven't got one
	if (country == nil)  {
		id unoccList = [self unoccupiedCountries];
		if ([unoccList count] > 0)  {
			country = [unoccList objectAt:[rng randMax:[unoccList count]-1]];
		}
		// always free lists you ask for
		[unoccList free];
	}
#else
	// Now choose countries according to how desirable their continents
	// look.
	if (country == nil) {
		id countries;
		int i, cc, numfr, bestCont = 0;
		float score, bestContScore = -1000, bestCountryScore = -1000;

		// For each continent, find its score and compare to the
		// best score seen so far.  Record the best continent & its
		// score.  A continent with no unoccupied countries is
		// ignored.
		for (cont = 0; cont < 6; cont++) {
			// Basic score based on the percentage of the
			// continent occupied by us already, if there are
			// unoccupied countries, plus a bit for each
			// unoccupied country.  If there aren't any, the
			// continent is ignored.
			countries = [gameManager countriesInContinent:cont];
			cc = [countries count];
			numfr = 0;
			score = 0;
			for (i = cc - 1; i >= 0; i--) {
				temp = [countries objectAtIndex:i];
				if ([temp playerNumber] == -1)
					score += 5;
				else {
					if ([temp playerNumber] == self.playerNumber)
						numfr++;
					[countries removeObjectAtIndex:i];
				}
			}
			if ([countries count] == 0)	// None unoccupied.
				score = -1000;
			else
				score += (double)numfr / (double)cc * 500;

			// Ignore the continent?
			if (score == -1000)
				continue;	// Yes.

			// Penalty for the number of countries in the
			// continent.  This makes us tend to go after smaller
			// continents (smaller penalty for smaller continents).
			// Other penalties for the number of entry/exit points
			// on the continent, and the number of neighboring
			// countries on other continents.
			score -= cc * 5;
			score -= [self exitsOfContinent:cont] * 5;
			score -= [self neighborsOfContinent:cont] * 5;

			// Add the game start fudge factor bonus.
			score += initContinentFudge[cont];

			// Is this the best score so far?  Record it if so.
			// If it equals a previous score, maybe pick it.
			if (score > bestContScore ||
					(score == bestContScore &&
					[rng randomNumberWithMaximum:99] < 50)) {
				bestCont = cont;
				bestContScore = score;
			}
		}

		// Now that we have the best continent picked, grab an
		// unoccupied country on it.  Pick the country with the
		// fewest neighbors.  If several have an equal number of
		// neighbors, semi-randomly choose one of them.
		countries = [self countriesInContinent:bestCont];
		for (i = 0; i < [countries count]; i++) {
			temp = [countries objectAtIndex:i];
			if ([temp playerNumber] == -1 &&
					(countryNeighbors[[temp idNum]] > bestCountryScore ||
					(countryNeighbors[[temp idNum]] == bestCountryScore &&
					[rng randomNumberWithMaximum:99] < 50))) {
				country = [countries objectAtIndex:i];
				bestCountryScore = countryNeighbors[[country idNum]];
			}
		}
	}
#endif
	
	// for diagnostic
	// the following code is used while developing when you are making the
	// player a subclass of Diagnostic.  When the class is a subclass of
	// ComputerPlayer, it must be removed.
//	[self setNotes:"sent by yourChooseCountry.  "
//					"yourChooseCountry chose a country at random."];
	
	// now occupy the country we've chosen
	[gameManager player:self choseCountry:country];
	numCountriesLastTurn++;		// We have another country.
}

- (void)placeInitialArmies:(RKArmyCount)count
// Place all armies in countries with placeArmies:.
{
	[self placeArmies:count];

	// for diagnostic
//	[self setNotes:"yourInitialPlaceArmies: ran.  "
//					"yourInitialPlaceArmies placed all armies into "
//					"non land locked countries."];
}

// Take a country list and return a list sorted by armies.  Does not
// free the input list.
- sortCountriesByArmies:countries
{
	int i;
	id scountries;

	scountries = [[StratSortedList alloc] initWithCount:2 forPlayer:self];
	[scountries setSortOrder:SSSortOrderDescending];
	[scountries setKeySortType:SSSortCountryByArmies];

	for (i=0; i<[countries count]; i++)
		[scountries addObject:[countries objectAtIndex:i]];

//	[scountries printKeyValues];

	return scountries;
}

// Take a country list and return a list sorted by armies.  Does not
// free the input list.
- sortCountriesByTAS:countries
{
	int i;
	id scountries;

	scountries = [[StratSortedList alloc] initWithCount:2 forPlayer:self];
	[scountries setSortOrder:SSSortOrderDescending];
	[scountries setKeySortType:SSSortCountryByTacticalAdvantageStrong];

	for (i=0; i<[countries count]; i++)
		[scountries addObject:[countries objectAtIndex:i]];

//	[scountries printKeyValues];

	return scountries;
}

// Take a country list and return a list sorted by need for armies, with most
// needy countries first, least needy countries last.  Does not free the
// input list.
- (StratSortedList*)sortCountriesByReinforcePrio:countries
{
	int i;
	id scountries;

	scountries = [[StratSortedList alloc] initWithCount:2 forPlayer:self];
	[scountries setSortOrder:SSSortOrderDescending];
	[scountries setKeySortType:SSSortCountryByReinforcePriority];

	for (i=0; i<[countries count]; i++)
		[scountries addObject:[countries objectAtIndex:i]];

//	[scountries printKeyValues];

	return scountries;
}

// Take an enemy list and return a list sorted by attackability, with most
// choice targets first, least choice target last.  Does not free the
// input list.
- sortEnemiesByAttackability:countries
{
	int i;
	id scountries;

	scountries = [[StratSortedList alloc] initWithCount:2 forPlayer:self];
	[scountries setSortOrder:SSSortOrderDescending];
	[scountries setKeySortType:SSSortEnemyAttackAbility];

	for (i=0; i<[countries count]; i++)
		[scountries addObject:[countries objectAt:i]];

//	[scountries printKeyValues];

	return scountries;
}

// Wipe out the fronts we were using.
- resetFronts
{
	front1 = front2 = front3 = -1;
	return self;
}

- (int)continentOfCountry:country
// Return the integer continent code (0 - 5) for the given country.
{
	int countryNum = [country idNum];

	if (countryNum >= MINCOUNTRY && countryNum <= MAXCOUNTRY)
		return countryContinents[countryNum];
	else
		return -1;	// Should never happen, but...
}

// Return which front a country is located along, 0 if none.
- (int)frontOfCountry:country
{
	int cont = [self continentOfCountry:country];

	if (cont == front1)
		return 1;
	else if (cont == front2)
		return 2;
	else if (cont == front3)
		return 3;
	return 0;
}

// Return the number of foreign neighbors (on another continent) a country has.
- (int)foreignNeighborsOfCountry:country
{
	int countryNum = [country idNum];

	if (countryNum >= MINCOUNTRY && countryNum <= MAXCOUNTRY)
		return countryForeignNeighbors[countryNum];
	else
		return 0;	// Should never happen, but...
}

// Find out how many countries a player has left.
- (int)numPlayersCountries:(int)player
{
	id countries;
	int num = 0;

	countries = [self playersCountries:player];
	if (countries != nil) {
		num = [countries count];
		[countries free];
	}
	return num;
}

// Find out how many players are left.
- (int)numPlayers
{
	int i, num = 0;

	for (i = 0; i < 6; i++) {
		if ([self numPlayersCountries:i] > 0)
			num++;
	}
	return num;
}

// Given a list of countries from which we can attack, find the top 3
// continents represented by them, and remove any countries not in the
// top 3 continents.  This concentrates our efforts on fewer fronts.
- limitCountriesToFronts:countries
{
	int i, cc, cont, numpl, numfronts;

	// Sanity check; shouldn't ever happen.
	if (countries == nil)
		return self;

	// Find out how many fronts we should be concentrating on.
	numpl = [self numPlayers];
	if (numpl > 4 && gameTurn > 1 && gameTurn < 5)
		numfronts = 1;
	else if (numpl > 4)
		numfronts = 2;
	else if (numpl > 1)
		numfronts = 3;
	else
		return self;	// No fronts, if only 1 enemy player.

	// If we're not doing well recently, reduce the fronts a bit.
	if (turnsSinceVict > 0 ||
			numCountriesLastTurn > [self numPlayersCountries:myPlayerNum])
		numfronts = (numfronts + 1) / 2;

	// Make one pass through the countries to find the top-ranked fronts,
	// which are really just continents we possess that border some
	// desirable enemy target(s).
	cc = [countries count];
	for (i = 0; i < cc; i++) {
		cont = [self continentOfCountry:[countries objectAt:i]];
		if (front1 == -1)
			front1 = cont;
		else if (numfronts >= 2 && front2 == -1 && cont != front1)
			front2 = cont;
		else if (numfronts >= 3 && front3 == -1 && cont != front1 && cont != front2) {
			front3 = cont;
			break;
		}
	}

	// Make another pass to remove the countries that aren't on one of
	// the fronts.
	for (i = cc - 1; i >= 0; i--) {
		cont = [self continentOfCountry:[countries objectAt:i]];
		if (cont != front1 && cont != front2 && cont != front3) {
			[countries removeObjectAt:i];
		}
	}

	return self;
}

- yourTurnWithArmies:(int)numArmies andCards:(int)numCards
// go through the phases of a well-formed Risk turn.  turn in cards,
// place armies, attack, fortify.
{
	int i, acount;
	id attackers, sattackers;
	BOOL vict=NO, avict=YES;
	BOOL win=NO;
	
	// turn in cards if possible, keeping track of the extra armies
	// we receive from the card sets.
	numArmies += [self turnInCards];
	
	// Place armies (only as many as we are supposed to).  Pick some
	// new fronts to attack along, maybe.
	[self resetFronts];
	[self placeArmies:numArmies];
		
	// We haven't taken a country yet.
	takenc = NO;

	// Now start attacking.  Go through the list of my countries with
	// 2 or more armies and at least one enemy neighbor, and try
	// attacking from each one in turn.  Sort my countries by attack
	// advantage.
	attackers = [self myCountriesCapableOfAttack:YES];
//	sattackers = [self sortCountriesByArmies:attackers];
	sattackers = [self sortCountriesByTAS:attackers];
	[attackers free];

	while (sattackers != nil && avict && !win) {
		acount = [sattackers count];
		avict = NO;		// Start with no victories
		for (i=0;i<acount && !win;i++)  {
			vict = NO;
			win = [self doAttackFrom:[sattackers objectAt:i] victory:&vict];

			// As soon as we conquer a country, break out of the
			// loop so we can rebuild the attacker list, which
			// might have moved some countries around due to
			// altered advantages.
			if (vict) {
				avict = YES;	// Got a victory
				break;
			}
		}

		if (avict && !win) {
			[sattackers free];
			attackers = [self myCountriesCapableOfAttack:YES];
//			sattackers = [self sortCountriesByArmies:attackers];
			sattackers = [self sortCountriesByTAS:attackers];
			[attackers free];
		}
	}

	// always free lists you asked for.
	[sattackers free];
	
	// only fortify if we haven't won the game
	if (!win)  {
		[self fortifyPosition];
	}
	
	gameTurn++;			// Another turn done.
	if (!takenc)			// Count winless turns.
		turnsSinceVict++;

	// Record how many countries we've got so we can tell next turn if
	// we're slipping.
	numCountriesLastTurn = [self numPlayersCountries:myPlayerNum];

	return self;
}

// ************************** my utilities ***************************

- (BOOL)takenACountry
// Return YES if we've taken a country this round, NO otherwise.
{
	return takenc;
}

- (float)ourPercentageOfContinent:(int)cont
// Return the percentage of a continent's countries possessed by us.
{
	int i, numfr = 0;
	float ratio;
	id countries;

	countries = [self countriesInContinent:cont];
	for (i = 0; i < [countries count]; i++) {
		if ([[countries objectAt:i] player] == myPlayerNum)
			numfr++;
	}
	ratio = (double)numfr / (double)[countries count];
	[countries free];

	return ratio;
}

- (int)exitsOfContinent:(int)cont
// Return the number of countries on this continent that border some other
// continent.
{
	return continentExits[cont];
}

- (int)neighborsOfContinent:(int)cont
// Return the number of countries on other continents that border this
// continent.
{
	return continentNeighbors[cont];
}

- (int)fudgeOfContinent:(int)cont
// Return the fudge factor for a continent.
{
	return continentFudge[cont];
}

- countryOfAttack
// Return the country from which we're planning an attack on somebody.
{
	return theCountryOfAttack;
}

- setCountryOfAttack:country
// Set the country from which we're planning an attack on somebody.
{
	theCountryOfAttack = country;
	return self;
}

- enemyNeighborsTo:country
// returns a list of all the neighbors to country which are not
// occupied by you.  We use this to find out if the country borders
// at least one enemy.
{
	id en = [self neighborsTo:country];
	int i;
	
	// weed out the neighbors which are mine
	// loop backwards since we want to delete from the list as we go
	for (i=[en count]-1;i>=0;i--)  {
		// if the country is ours, get rid of it.
		if ([[en objectAt:i] player] == myPlayerNum)  {
			[en removeObjectAt:i];
		}
	}
	
	// if the list is empty, free it and return nil, otherwise return it.
	if ([en count]==0)  {
		// free the list and return nil
		[en free];
		return nil;
	}  else  {
		// don't free en since we want to return it.
		return en;
	}
}

- (int)enemyArmiesAround:country
// returns the total number of armies in all the neighbors to country which
// are not occupied by you.
{
	id enemies = [self neighborsTo:country];
	int i, armies=0;
	
	// add up the armies in the neighbors which are not mine
	for (i=0;i<[enemies count];i++)  {
		if ([[enemies objectAt:i] player] != myPlayerNum)  {
			armies += [[enemies objectAt:i] armies];
		}
	}
	[enemies free];
	
	return armies;
}

- (id)friendlyNeighborsTo:(id)country
// returns a list of all the neighbors to country which are
// occupied by you.
{
	id fr = [self neighborsTo:country];
	int i;
	
	// weed out the neighbors which are not mine
	// loop backwards since we want to delete from the list as we go
	for (i=[fr count]-1;i>=0;i--)  {
		// if the country isn't ours, get rid of it.
		if ([[fr objectAt:i] player] != myPlayerNum)  {
			[fr removeObjectAt:i];
		}
	}
	
	// if the list is empty, free it and return nil, otherwise return it.
	if ([fr count]==0)  {
		// free the list and return nil
		[fr free];
		return nil;
	}  else  {
		// don't free fr since we want to return it.
		return fr;
	}
}

- (int)friendlyArmiesAround:country
// returns the total number of armies in all the neighbors to country which
// are occupied by you.
{
	id friends = [self neighborsTo:country];
	int i, armies=0;
	
	// add up the armies in the neighbors which are mine
	for (i=0;i<[friends count];i++)  {
		if ([[friends objectAt:i] player] == myPlayerNum)  {
			armies += [[friends objectAt:i] armies];
		}
	}
	[friends free];
	
	return armies;
}

- myCountriesCapableOfAttack:(BOOL)attack
// returns a list of all my countries which have at least one enemy neighbor.
// if attack is YES then only countries with 2 or more armies are returned.
{
	id l;
	int i, c;
	
	// get a list of countries depending on attack
	if (attack)  {
		l = [self myCountriesWithAvailableArmies];
	}  else  {
		l = [self myCountries];
	}
	c = [l count];
	
	// weed out those countries which are completely surrounded by friendly
	// neighbors.  loop backwards cause we'll be deleting from the list.
	for (i=c-1;i>=0;i--)  {
		id en = [self enemyNeighborsTo:[l objectAt:i]];
		if (en != nil)  {
			// it has enemy neighbors, so keep it in the list, but free en.
			[en free];
		}  else  {
			[l removeObjectAtIndex:i];
		}
	}
	
	// if there aren't any such countries, just return nil
	// This should not happen, but better safe than sorry.
	if ([l count] == 0)  {
		[l free];
		return nil;
	}
	
	// don't free l because we're gonna return it.
	return l;
}

- (int)turnInCards
// if we can turn in cards, do it until we can't
{
	id cardSet;
	int temp, numArmies = 0;
	
	// get our best set
	cardSet = [self bestSet];
	// if there is a best set, play it, and see if there's another set.
	while (cardSet != nil)  {
		// for diagnostic
//		[self setNotes:"sent by -(int)turnInCards.  turnInCards turned in "
//						"the best possible set of cards."];
		
		// play the set.
        [gameManager turnInCardSet:cardSet forPlayerNumber:self.playerNumber];
		temp = [self playCards:cardSet];
		// free the list we asked for
		// if playCards returned -1 there was a problem
		if (temp == -1)  {
			// should never happen
			NXRunAlertPanel("Debug", "bestSet returned an invalid cardset", 
							"OK", NULL, NULL);
			// stop trying to turn in cards, but this is an error.
			cardSet=nil;
		}  else  {
			// all is well, accumulate the armies received
			numArmies += temp;
			// see if there is another set.
			cardSet = [self bestSet];
		}
	}
	// return the number of armies received in total, will be 0 if we didn't
	// turn any in.
	return numArmies;
}

- (BOOL)weGotOverkill:country
// For a country we're thinking of putting some armies into, see if we
// should avoid this because of strong friendly neighbors, even though the
// country itself might be outnumbered by neighboring enemies.  I.e. don't
// put more armies here if weGotOverkill!
{
	id en = [self enemyNeighborsTo:country];
	id enemy;
	int enc;
	BOOL overkill;

	enc = [en count];
	// Sanity check; shouldn't ever execute this method if
	// there are no enemies; if it does, claim to have overkill
	// so we put no armies here.
	if ([en count] == 0)
		overkill = YES;
	else if (enc == 1) {
		// only one enemy neighbor; try to figure out if we
		// need more armies or not by looking at the combined
		// armies of all friendlies surrounding the enemy,
		// compared to all enemies surrounding the enemy (incl.
		// itself, too).
		enemy = [en objectAt:0];
		if (([self enemyArmiesAround:enemy] + [enemy armies]) * 1.5 >=
				[self friendlyArmiesAround:enemy])
			overkill = NO;
		else
			overkill = YES;
	}
	else {
		// several enemy neighbors; give up trying to figure
		// out subtleties, just use massive overkill!
		overkill = NO;
	}
	[en free];
	return overkill;
}

// This routine places numAmries armies in suitable countries. It only
// chooses from those countries which we own, and which have at least
// one enemy neighbor.  Such countries are prioritized according to need;
// high priority countries get all the armies first, up until the point
// at which the armies in them outnumber their surrounding enemies, or
// exceed a reasonable rearguard threshhold, whichever is higher.
- (BOOL)placeArmies:(int)numArmies
{
	id countries, prioCountries, someCountries, otherCountries;
	id country = nil, weakenemy = nil;
	int i, j, num, numToPlace, placeAmt;
	float contRatio, outgunRatio;
	BOOL attackWeak = NO, foundIt;
	
	// Get all countries with enemy neighbors.
	countries = [self myCountriesCapableOfAttack:NO];

	// Sanity check.  Should never happen.
	if (countries == nil)  {
		return NO;
	}

	// Prioritize the countries with enemy neighbors in order of
	// greatest to least need for reinforcements.
	prioCountries = [self sortCountriesByReinforcePrio:countries];
	[countries free];

	// Now perhaps limit the playing field to key fronts.
	if (limitMode)
		[self limitCountriesToFronts:prioCountries];

	// for diagnostic
//	[self setNotes:"sent by placeArmies.  "
//					"placeArmies placed some armies in a "
//					"suitable country"];
	
	// Place armies in larger chunks as the game progesses, and if we are
	// placing above a certain threshhold amount.
	if (gameTurn >= 14 || numArmies >= 25)
		placeAmt = 5;
	else if (gameTurn >= 7 || numArmies >= 9)
		placeAmt = 3;
	else
		placeAmt = 1;

	// Stagger the ratio by which we must outgun enemy neighbors,
	// decreasing as we go along.  Victory is more crucial early on when
	// the numbers of armies we're dealing with are smaller, and thus
	// odds may go against us more easily even though we have more
	// armies; so we want more of an edge when attacking.
	if (gameTurn >= 14) {
		outgunRatio = 1.25;
		banzaiMode = NO;		// Stop going all out at this point.
	}
	else if (gameTurn >= 7)
		outgunRatio = 1.65;
	else
		outgunRatio = 2;

	// If we're down to few countries or have lost ground, double the
	// outgun ratio so our armies will be concentrated in fewer places.
	if ([self numPlayersCountries:myPlayerNum] < 5 ||
			[self numPlayersCountries:myPlayerNum] <
			numCountriesLastTurn * 0.8)
		outgunRatio *= 2;

	// If we haven't taken a country recently, pick our weakest enemy
	// neighbor overall as a target for destruction.
	if (turnsSinceVict > 0) {
		attackWeak = YES;
		num = 1000;
		for (i = 0; i < [prioCountries count]; i++) {
			someCountries = [self enemyNeighborsTo:[prioCountries objectAt:i]];
			for (j = 0; j < [someCountries count]; j++) {
				if ([[someCountries objectAt:j] armies] < num) {
					weakenemy = [someCountries objectAt:j];
					num = [weakenemy armies];
				}
			}
			[someCountries free];
		}
		// Now that we have our weakest enemy, find our strongest
		// country neighboring it, so we can reinforce our strongest
		// position.
		someCountries = [self friendlyNeighborsTo:weakenemy];
		otherCountries = [self sortCountriesByArmies:someCountries];
		country = [otherCountries objectAt:0];
		[someCountries free];
		[otherCountries free];
	}

	// Reinforce countries around our weakest enemy if this is the action
	// we need to take.  Otherwise reinforce our countries in order of
	// priority needs for armies.
	numToPlace = numArmies;
	while (numToPlace)  {
		if (!attackWeak) {
			// Look first for a country that doesn't outgun its
			// enemy neighbors.
			foundIt = NO;
			for (i = 0; i < [prioCountries count]; i++) {
				country = [prioCountries objectAt:i];

        			// Now that we have a country to look at, find
				// the percentage of its continent possessed
				// by us, for use in modifying the outgunRatio.
				// The concept is to go after smaller
				// continents where we have a stronger
				// presence, so we want higher outnumber ratios
				// when placing armies in such countries.
				contRatio = [self ourPercentageOfContinent:[self continentOfCountry:country]];

				// Now that we have the occupation ratio,
				// adjust it to a value that can be multiplied
				// to the outgunRatio to achieve our aim.
				if (contRatio <= .25)
					contRatio = .75;
				else if (contRatio <= .5)
					contRatio = 1.25;
				else if (contRatio <= .75)
					contRatio = 1.5;
				else
					contRatio = 1.0;

				// Now see if this country needs more armies.
				if (([self enemyArmiesAround:country] + 1) *
						outgunRatio * contRatio >=
							[country armies] &&
						![self weGotOverkill:country]) {
					foundIt = YES;
					break;
				}
			}

			// If no luck, look next for a country with less than
			// a suitable rear guard.
			if (!foundIt) {
				for (i = 0; i < [prioCountries count]; i++) {
					country = [prioCountries objectAt:i];
					if ([country armies] < rearguard()) {
						foundIt = YES;
						break;
					}
				}
			}

			// If still no luck, pick a random country.
			if (!foundIt)
				country = [prioCountries objectAt:[rng randMax:[prioCountries count] - 1]];
		}

		if (numToPlace > placeAmt) {
			[self placeArmies:placeAmt inCountry:country];
			numToPlace -= placeAmt;
		}
		else {
			[self placeArmies:numToPlace inCountry:country];
			numToPlace = 0;
		}
		if (attackWeak) {
			if ([country armies] > ([weakenemy armies] + 1) * (outgunRatio + 0.25))
				attackWeak = NO;
		}

		// Reprioritize the countries; now that we've placed a few
		// armies, the ordering may have shifted a little.
		someCountries = [prioCountries copy];
		[prioCountries free];
		prioCountries = [self sortCountriesByReinforcePrio:someCountries];
		[someCountries free];
	}

	// Free what we asked for.
	[prioCountries free];
	return YES;
}

- (BOOL)doAttackFrom:fromc victory:(BOOL *)vict
// attacks from fromc.  This method chooses a number between 1 and the number
// of armies in fromc.  It attacks until fromc has that number of armies left.
// Sometimes it won't attack at all (if the random number is the same as the
// number of armies in fromc).  If it conquers, it moves forward half of the
// armies remaining in fromc.  If it vanquishes someone, it turns in cards
// if it needs to and places any armies resulting.  returns whether the
// game is over.  Sets the BOOL vict if the attack succeeded.
{
	id target, enemies, sortedenemies;
	int i, fa, ta, olda, newa, movea, opc, enc, minArmies, cont;
	float attrat, discretion1, discretion2;
	BOOL vanq, win, weakenemy = NO, outnumbered = NO;
	
	// If no enemy neighbors, no attack is possible, so return.
	enemies = [self enemyNeighborsTo:fromc];
	if (enemies == nil)  {
		return NO;
	}
	enc = [enemies count];

	// Set our continent of attack, locally and globally.
	cont = [self continentOfCountry:fromc];
	[self setCountryOfAttack:fromc];

	// Order enemy neighbors by attackability.  Pick the most desirable
	// target (first in the sorted list) and proceed.
	sortedenemies = [self sortEnemiesByAttackability:enemies];
	target = [sortedenemies objectAt:0];
	[sortedenemies free];
	[enemies free];

	// See if we've got either a really weak opponent that we should
	// go after with greater abandon, or if we've got an opponent
	// blocking us from nearly having a continent and whom we should
	// thus go after with greater abandon.
	opc = [self numPlayersCountries:[target player]];
	if (opc <= 3 || ([self ourPercentageOfContinent:cont] >= .7 &&
			cont == [self continentOfCountry:target]))
		weakenemy = YES;

	// Set up some values that influence discretion as the better part
	// of valor.  If we haven't had a victory recently, we want to
	// attack with a little less concern for odds being in our favor.
	// Likewise if our territory is shrinking.
	discretion1 = 1.25;
	if (turnsSinceVict > 0) {
		discretion1 = 0.95;
	}
	else if ([self numPlayersCountries:myPlayerNum] <
			numCountriesLastTurn * 0.8) {
		discretion1 = 1.05;
	}
	discretion2 = discretion1 * 2;

	// If our combined surrounding strength is weaker than the chosen
	// country's strength plus 25% (safety margin), don't attack, unless
	// we're in banzai mode.
	if (!banzaiMode && takenc && [self friendlyArmiesAround:target] <
			([target armies] + (takenc ? 1 : 0)) * discretion1) {
		return NO;
	}

	// If our combined surrounding strength is weaker than the chosen
	// country's strength plus 25% (safety margin), factoring in other
	// surrounding enemies, and we have taken a country this turn, and
	// the enemy is not near extinction, then don't attack, unless we're
	// in banzai mode.
	attrat = (float)([self friendlyArmiesAround:target] -
		[self enemyArmiesAround:target]) /
			(float)([target armies] + (takenc ? 1 : 0));
	if (!banzaiMode && takenc && !weakenemy && attrat < discretion1) {
		return NO;
	}

	// If we have taken a country this turn, and we're early in the
	// game or getting down to few countries, and the enemy we're looking
	// at attacking is not somebody we really want to stomp, and we don't
	// massively outnumber the enemy and its surroundings, then don't
	// attack, unless we're in banzai mode.
	if (!banzaiMode && takenc && !weakenemy && attrat < discretion2 &&
			(gameTurn < 4 || [self numPlayersCountries:myPlayerNum] < 5))
		return NO;

	// If there's only the one enemy country, and we've got some
	// surrounding friendlies, hold off attacking to give a chance to
	// fortify for a stronger attack next turn; unless the opponent is
	// near extinction or we massively outnumber him or we haven't
	// taken a country yet or we're in banzai mode, in which case go
	// for it.
	if (!banzaiMode && takenc && enc == 1 && !weakenemy) {
		id fr = [self friendlyNeighborsTo:fromc], country;
		int i, frc = 0;
		float nattrat;

		if ( fr != nil )
			for (i = 0; i < [fr count]; i++) {
				country = [fr objectAt:i];
				if ([self enemyArmiesAround:country] == 0)
					frc += [country armies];
			}
		[fr free];
		nattrat = (float)([self friendlyArmiesAround:target] + frc -
				[self enemyArmiesAround:target]) /
				(float)([target armies] + (takenc ? 1 : 0));
		if (frc && ((attrat < discretion2 && nattrat - attrat >= 2) ||
				(attrat < discretion2 * 2 && nattrat - attrat >= 4)))
			return NO;
	}

	// Figure out whether to attack until a certain number of armies
	// remain (if we have taken a country this turn), or until no
	// further attack is possible (if we haven't taken a country yet
	// this turn).  If the enemy is weak or we're in banzai mode, attack
	// all out.
	minArmies = 1;
	if (!banzaiMode && takenc && !weakenemy) {
		if ([fromc armies] >= [self friendlyArmiesAround:target] * .5)
			minArmies = rearguard() / 3 + 1;
	}

	// for diagnostic
//	[self setNotes:"sent by -(BOOL)doAttackFrom:.  doAttackFrom "
//					"attacked its weakest neighbor."];
	
	// Now attack.  If the attack takes place, deal with the results.
	if ([self attackUntilLeft:minArmies from:fromc to:target victory:vict 
		fromArmies:&fa toArmies:&ta vanquished:&vanq weWin:&win]) {
#if 0
	if ([self attackUntilCantFrom:fromc to:target victory:vict 
		fromArmies:&fa toArmies:&ta vanquished:&vanq weWin:&win]) {
#endif

		// If we didn't conquer the country, there is nothing to do.
		if (!*vict)  {
			return NO;
		}
		// If we've won the game, there is no need to continue.
		if (win)  {
			return YES;
		}

		// If we get here, we must deal with the victory.  Make note
		// that we took a country this turn, and note which turn the
		// country was taken.  Update the turn conquered value of the
		// attacking country as well.
		takenc = YES;
		turnsSinceVict = 0;
		turnCountryConquered[[target idNum]] = gameTurn;
		turnCountryConquered[[fromc idNum]] = gameTurn;

		// If there are any armies to move, figure out how many
		// and do it.
		if (fa > 1)  {
			
			// for diagnostic
//			[self setNotes:"sent by -(BOOL)doAttackFrom:.  doAttackFrom "
//						"advanced attacking forces."];
			
			// Figure out how many armies to move; count up enemy
			// armies around old & new countries.  Set a flag if
			// an enemy by the new country is near extinction, and
			// not already outnumbered by surrounding friendlies,
			// so we can shift more armies that direction.
			// Set a second flag if the new country has only one
			// enemy neighbor who is already outnumbered by
			// friendlies.
			weakenemy = NO;
			enemies = [self enemyNeighborsTo:target];
			if (enemies != nil) {
				enc = [enemies count];
				for (i = 0; i < enc; i++) {
					opc = [self numPlayersCountries:[[enemies objectAt:i] player]];
					if (opc <= 3 && [self friendlyArmiesAround:[enemies objectAt:i]] <
							([[enemies objectAt:i] armies] + 1) * 1.5) {
						weakenemy = YES;
						break;
					}
				}
				if (enc == 1) {
					id theEnemy = [enemies objectAt:0];

					if ([self friendlyArmiesAround:theEnemy] >=
							([theEnemy armies] + 1) * 1.5)
						outnumbered = YES;
				}
				[enemies free];
			}

			// Set a flag if there's only one enemy neighbor left
			// by the old country, and it also neighbors the
			// conquered country, and it is outnumbered and thus
			// can be taken out on another attack, if we move all
			// the armies into the conquered country.
			if (!weakenemy) {
				id oldEnemies = [self enemyNeighborsTo:fromc];

				if (oldEnemies != nil && [oldEnemies count] == 1) {
					id theEnemy = [oldEnemies objectAt:0];
					id friends = [self friendlyNeighborsTo:theEnemy];

					for (i = 0; i < [friends count]; i++) {
						if (target == [friends objectAt:i]) {
							attrat = (float)([self friendlyArmiesAround:theEnemy] -
								[self enemyArmiesAround:theEnemy]) /
									(float)([theEnemy armies] + (takenc ? 1 : 0));
							if (attrat >= discretion1 || banzaiMode)
								weakenemy = YES;
							break;
						}
					}
					[friends free];
				}
				if (oldEnemies != nil)
					[oldEnemies free];
			}
			// Move half if no enemies around either country.
			olda = [self enemyArmiesAround:fromc];
			newa = [self enemyArmiesAround:target];
			if (olda + newa == 0) {
				[self moveArmies:((fa+ta)/2-ta) from:fromc to:target];
			}
			// Else move all if no enemies around old country, or
			// if new country has an enemy neighbor near death;
			// must leave one army behind.
			else if (olda == 0 || weakenemy) {
				[self moveArmies:fa-1 from:fromc to:target];
			}
			// Else move none if no enemies around new country, or
			// if there is one enemy that is already outnumbered
			// by surrounding friendlies.
			else if (newa == 0 || outnumbered) {
//				[self moveArmies:0 from:fromc to:target];
			}
			// Else move proportionate amount to each country,
			// leaving behind a reasonable rearguard, at minimum.
			else {
				movea = (int)((float)(fa + ta) * (float)newa /
					((float)olda + (float)newa)) - ta;
		
				// Must leave at least 1 behind.
				if (movea == fa) {
					--movea;
				}

				// Leave a reasonable rear guard, if the
				// proportions would cause too little to be
				// left behind.
				if ((fa - movea) < rearguard()) {
					movea = fa - rearguard();
				}

				// Move 'em out.
				if (movea > 0) {
					[self moveArmies:movea from:fromc to:target];
				}
			}
	
		}

		// If we vanquished a player, we got any cards he had, so check
		// to see if we must turn in cards.
		if (vanq) {
			int numArmies = 0;
			id cards = [self myCards];
			
			// only turn in if we're allowed to (we have five or more)
			if ([cards count] > 4)  {
				numArmies += [self turnInCards];
			}
			// now we are done with cards
			[cards free];
			if (numArmies > 0)  {
				[self placeArmies:numArmies];
			}
		}
	}

	// We didn't win the game if we get here.
	return NO;
}

- (void)fortifyPhase:(RKFortifyRule)fortifyRule
// fortify our position at the end of the turn.
{
	id cl=[self myCountriesWithAvailableArmies];
	int i, clc=[cl count];
	
	// first get a list of isolated countries with armies
	for (i=clc-1;i>=0;i--)  {
		id en=[self enemyNeighborsTo:[cl objectAt:i]];
		if (en != nil)  {
			[en free];
			[cl removeObjectAt:i];
		}
	}
	clc = [cl count];
	if (clc != 0)  {
		int numArmies[clc], strongest;
		
		// before we move anything, figure out how many armies can be moved
		// from each country so we don't move anything twice; also find
		// the country with the most armies to be moved
		strongest = 0;
		for (i=0;i<clc;i++)  {
			numArmies[i]=[[cl objectAt:i] armies]-1;
			if (numArmies[i] > [[cl objectAt:strongest] armies] - 1)
				strongest = i;
		}
		// we fortify all our countries from one to one at a time
		// all we need to distinguish is whether we can fortify once
		// or as many as we want.
		switch ([self fortifyRule])  {
			case FR_ONE_ONE_N:
			case FR_ONE_MANY_N:
//				strongest=[rng randMax:clc-1];
				// fortify from the country with the most
				// armies to be moved
				[self fortifyArmies:numArmies[strongest] from:[cl objectAt:strongest]];
				break;
			case FR_MANY_MANY_N:
			case FR_MANY_MANY_C:
				// loop through the countries and try to fortify from each
				for (i=0;i<clc;i++)  {
					[self fortifyArmies:numArmies[i] from:[cl objectAt:i]];
				}
				break;
			default:
				break;
		}
	}
	// free the list
	[cl free];
	return self;
}

- (void)placeFortifyingArmies:(RKArmyCount)numArmies fromCountry:(RKCountry *)country
{
	// get a list of friendly neighbors for the country
	id fr=[self friendlyNeighborsTo:country];
	int frc=[fr count];
	id fr2;
	int fr2c, cont, cont2, cid, conqed, turnconqed;
	id toc=nil;
	int i, j, numWithEnemies = 0, firstOne = 0, anyOutGunned = NO, toa,
		totalEnemies = 0, firstId = 0;
	float outgunnedBy;
	int armiesAt[10], enemiesAround[10], ownershipRatio[10];
	
	// sanity check
	if (frc == 0) {
		[fr free];
		return;
	}

	// count up enemy armies around each friendly neighbor
	for (i = 0; i < frc; i++) {
		armiesAt[i] = [[fr objectAtIndex:i] armies];
		enemiesAround[i] = [self enemyArmiesAround:[fr objectAtIndex:i]];
		if (enemiesAround[i] > 0) {
			if (!numWithEnemies)
				firstOne = i;
			numWithEnemies++;
		}
	}

	// If numWithEnemies = 0 then there isn't a friendly neighbor
	// with unfriendly neighbors, so look one country further out
	// beyond the current friendly neighbors for other friendly
	// neighbors with enemies, or that are on a continent that contains
	// enemies somewhere.
	if (numWithEnemies == 0)  {
		// First look for friendly neighbors that have friendly
		// neighbors that have enemy neighbors.
		for (i = 0; i < frc; i++)  {
			fr2 = [self friendlyNeighborsTo:[fr objectAt:i]];
			fr2c = [fr2 count];
			for (j = 0; j < fr2c; j++) {
				enemiesAround[i] += [self enemyArmiesAround:[fr2 objectAt:j]];
			}
			[fr2 free];
			if (enemiesAround[i] > 0) {
				numWithEnemies++;
				if (enemiesAround[i] > totalEnemies) {
					firstOne = i;
					totalEnemies = enemiesAround[i];
				}
			}
		}

		// If numWithEnemies = 0, there are no friendly neighbors with
		// friendly neighbors with enemy neighbors, so look for
		// friendly neighbors that border another continent
		// containing some enemies.
		if (numWithEnemies == 0) {
			for (i = 0; i < frc; i++)  {
				cont = [self continentOfCountry:[fr objectAt:i]];
				fr2 = [self friendlyNeighborsTo:[fr objectAt:i]];
				fr2c = [fr2 count];
				for (j = 0; j < fr2c; j++) {
					cont2 = [self continentOfCountry:[fr2 objectAt:j]];
					if (cont != cont2)
						ownershipRatio[i] += 100 - 100 *
							[self ourPercentageOfContinent:cont2];
				}
				[fr2 free];
				if (ownershipRatio[i] > 0) {
					numWithEnemies++;
					if (ownershipRatio[i] > totalEnemies) {
						firstOne = i;
						totalEnemies = ownershipRatio[i];
					}
				}
			}
		}

		// If numWithEnemies = 0 still, give up and follow the trail
		// of most recent conquest.
		if (numWithEnemies == 0)  {
			conqed = -1;
			for (i = 0; i < frc; i++) {
				cid = [[fr objectAt:i] idNum];
				turnconqed = turnCountryConquered[cid];
				if (conqed < turnconqed) {
					conqed = turnconqed;
					firstOne = i;
					firstId = cid;
				}
				else if (conqed == turnconqed) {
					if (countryForeignNeighbors[firstId] < countryForeignNeighbors[cid] ||
							countryNeighbors[firstId] < countryNeighbors[cid]) {
						conqed = turnconqed;
						firstOne = i;
						firstId = cid;
					}
				}
			}
		}

		// Now move the armies to the friendly neighbor that is in
		// the direction of greatest need.
#if 0
		toc = [fr objectAt:[rng randMax:frc-1]];
#endif
		toc = [fr objectAt:firstOne];
		[self moveArmies:numArmies from:country to:toc];
	}
	// else if numWithEnemies = 1 then there is one friendly neighbor
	// with unfriendly neighbors, so pick it
	else if (numWithEnemies == 1) {
		toc = [fr objectAt:firstOne];
		[self moveArmies:numArmies from:country to:toc];
	}
	// else if we can only move into one neighbor, pick the one that
	// needs it most
	else if ([self fortifyRule] == FR_ONE_ONE_N) {
		// find neighbor most in need
		firstOne = 0;
		outgunnedBy = (float)armiesAt[0] / (float)enemiesAround[0];
		for (i = 1; i < frc; i++) {
			if ((float)armiesAt[i] / (float)enemiesAround[i] < outgunnedBy) {
				firstOne = i;
				outgunnedBy = (float)armiesAt[i] / (float)enemiesAround[i];
			}
		}
		toc = [fr objectAt:firstOne];
		[self moveArmies:numArmies from:country to:toc];
	}
	// else there are several friendly neighbors with unfriendly
	// neighbors, so distribute the armies among them as needed
	else {
		// first see if any of our friendly neighbors are outgunned;
		// if so, remove any that are not outgunned from the list
		for (i = 0; i < frc; i++) {
			if ((float)armiesAt[i] / (float)enemiesAround[i] < 1.25) {
				anyOutGunned = YES;
				break;
			}
		}
		if (anyOutGunned) {
			for (i = frc - 1; i >= 0; i--) {
				if ((float)armiesAt[i] / (float)enemiesAround[i] >= 1.25)
					[fr removeObjectAt:i];
			}
			frc = [fr count];
			// redo arrays
			for (i = 0; i < frc; i++)  {
				armiesAt[i] = [[fr objectAt:i] armies];
				enemiesAround[i] = [self enemyArmiesAround:[fr objectAt:i]];
			}
		}
		// now we have a list of countries to move armies into;
		// move in proportion to how many enemies are around each
		for (i = 0; i < frc; i++)  {
			totalEnemies += enemiesAround[i];
		}
		for (i = 0; i < frc - 1; i++) {
			toa = numArmies * ((float)enemiesAround[i] / (float)totalEnemies);
			if (toa) {
				toc = [fr objectAt:i];
				[self moveArmies:toa from:country to:toc];
				numArmies -= toa;
			}
		}
		// move remainder armies to last country
		toc = [fr objectAt:(frc - 1)];
		[self moveArmies:numArmies from:country to:toc];
	}
	[fr free];
	return self;
}

@end
