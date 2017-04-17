// Coop.m
// Part of Risk by Mike Ferris

#import "Coop.h"
#import <AppKit/AppKit.h>
#import <RiskKit/RiskKit.h>

#define NIBFILE "Coop.cp/Coop.nib"

@implementation Coop

+ initialize
{
	if (self == [Coop class])  {
		[self setVersion:1];
	}
	return self;
}

- (instancetype)initWithPlayerName:(NSString *)aName number:(Player)myPlayerNum gameManager:(RiskGameManager *)aManager
{
    if (self = [super initWithPlayerName:aName number:myPlayerNum gameManager:aManager]) {
		[NSBundle loadNibNamed:@"Coop" owner:self];
		[(NSFormCell*)[myPlayerNumForm cellAtIndex:0] setIntegerValue:myPlayerNum];
        //[diagnosticPanel setBecomeKeyOnlyIfNeeded:YES];
        [diagnosticPanel orderFront:self];
    }
	
    return self;
}

// *****************subclass responsibilities*********************
// "Argentina", "Peru", "Venezuela", "Brazil", "Central America", "Western United States", "Eastern United States", "Alberta", "Northwest Territory", "Ontario", "Alaska", "Quebec", "Greenland", "Iceland", "Great Britain", "Western Europe", "Southern Europe", "Northern Europe", "Ukraine", "Scandinavia", "South Africa", "Congo", "East Africa", "Egypt", "Madagascar", "Middle East", "India", "Siam", "China", "Afghanistan", "Ural", "Siberia", "Mongolia", "Irkutsk", "Yakutsk", "Kamchatka", "Japan", "Western Australia", "Eastern Australia", "New Guinea", "Indonesia", 

- (void)chooseCountry;
{
    int i,j;
	NSArray<Country *> *unoccList = [gameManager unoccupiedCountries];
	Country *country;
	id takeCountry= nil;
// if one of the following is available, take it.
	const char *const preferedCountries[]= { "Indonesia", "New Guinea", "Western Australia", "Eastern Australia", "Greenland", "Iceland", "Argentina", "Peru", "Venezuela", "Brazil", "Central America", "North Africa", "South Africa", "Congo", "East Africa", "Egypt",
"" };
	
	if ([unoccList count]==0)  {
		return;
	}
// try preferred countries first

	for (j=0; *preferedCountries[j] != '\0' && takeCountry==nil; j++) {
		for (i=0; i< [unoccList count] && takeCountry==nil; ++i) {
			country= [unoccList objectAtIndex:i];
			// fprintf( stderr, "\"%s\", ", [country name] );
			if (strcmp(preferedCountries[j], [country countryName].UTF8String) == 0) {
				[self setNotes: [country countryName] ];
				takeCountry= country;
			}
		}
	}

// else inherited chaotic behaviour

	if (takeCountry==nil) {
	    [super chooseCountry];
	} else {
	    [self setNotes:@"sent by -yourChooseCountry.  "
		  "yourChooseCountry chose a country at random."];
	    [self occupyCountry:takeCountry];
	}
}

- (void)placeInitialArmies:(int)numArmies
{
	NSSet<Country*> *mycountries = [gameManager.world countriesForPlayer:playerNumber];
	char *preferedCountries[]= { "Indonesia", "New Guinea", "Greenland", "Iceland", "Brazil", "Central America", "North Africa", "" };
	int j;
	Country *inCountry= nil;

	if ([mycountries count]==0) {
		[self turnDone];
		return;
	}
	for (j=0; *preferedCountries[j] != '\0' && inCountry == nil; ++j) {
		for (Country *country in mycountries) {
			if (inCountry != nil) {
				break;
			}
			//if (strcmp(preferedCountries[j], [country name]) == 0) fprintf(stderr, " %s bekannt mit %d armies.\n", [country name], [country armies] );
			if ( (strcmp(preferedCountries[j], [country countryName].UTF8String) == 0) && ([country troopCount] <= 1) ) {
				[self setNotes: [country countryName] ];
				inCountry = country;
				//fprintf( stderr, "ok, taken");
				break;
			}
		}
	}
	if (inCountry==nil) {
	    inCountry= [self findMyCountryWithMostInferiorEnemy];
	}
	
	if (inCountry==nil) {
	    // fprintf( stderr, "yourInitialPlaceArmies calls super\n" );
	    [super placeInitialArmies: numArmies];
	}
	else {
	    [self placeArmies:numArmies inCountry:inCountry];
	}
	[self turnDone];
}

- (void) placeArmies:(int)numArmies
{
	NSSet<Country*> *mycountries = [gameManager.world countriesForPlayer:playerNumber];
	id inCountry= nil;
	//int i, acount;
	//id attackers;
	BOOL win=NO;
	
	if ([mycountries count]==0)  {
		[self turnDone];
		return;
	}

	// turn in cards

	numArmies += [self turnInCards];
	// fprintf( stderr, "new %d armies, %d countries\n", numArmies, [mycountries count] );
	
// find own country with largest plus of own armies compared to all its neighbours
// repeatedly for all armies to be set

	    
	inCountry= [self findMyCountryWithMostInferiorEnemy];

	if (inCountry == nil) {
		// we don't know what to do, so we behave chaotic like super
		[super placeArmies:numArmies];
	}
	else {
		[self placeArmies:numArmies inCountry:inCountry];
		[self setNotes: [inCountry name] ];
	}
	
// now start attacking. 
	
//	win= [self attackFromMostThreatenedCountry];
	win= [self attackFromLeastThreatenedCountryUntilLeft: 1];
//	fprintf( stderr, "doAttack %s\n", [inCountry name] );
//	win= [self doAttackFrom: inCountry];
	
// only fortify if we haven't won the game

	// fprintf( stderr, "now fortify\n" );
	if (!win)  {
		[self fortifyPosition];
	}
	[self turnDone];
}

- (void) attackPhase
{
	[self turnDone];
}

- (void)playerNumber:(Player)player attackedCountry:(Country *)country
{
	// do nothing.  these methods are for advanced players only.
	// but we do set the notes and pause if we should.
	[self setNotes:@"-youWereAttacked: by: was called."];
	[self clearArgForms];
	[functionCalledForm setStringValue:@""];
	[returnValueForm setStringValue:@""];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
}

- (void)playerNumber:(Player)number capturedCountry:(Country *)capturedCountry
{
	// do nothing.  these methods are for advanced players only.
	// but we do set the notes and pause if we should.
	[self setNotes:@"-youLostCountry: to: was called."];
	[self clearArgForms];
	[functionCalledForm setStringValue:@""];
	[returnValueForm setStringValue:@""];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
}

// *****************country utilities*********************

#if 0
- (BOOL)occupyCountry:country
{
	BOOL retVal;
	
	retVal = [super occupyCountry:country];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)occupyCountry:" at:0];
	[args1Form setTitle:"country" at:0];
	if (country == nil)  {
		[args1Form setStringValue:"nil" at:0];
	}  else  {
		[args1Form setStringValue:[country name] at:0];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[diagnosticPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}
#endif

- (NSArray<Continent*>*)enemyNeighborsToCountry:(Country*)country
{
	NSMutableArray *initialCountryHeap = [[NSMutableArray alloc] init];
	for (Country* neighbor in country.neighborCountries) {
		if (neighbor.playerNumber != playerNumber) {
			[initialCountryHeap addObject:country];
		}
	}
	return [initialCountryHeap copy];
}

- (Country *)findAdjacentEnemyCountryMostSuperiorTo:(Country *) country
{
	int i;
	int diff, maxDiff= -9999;
	id enemiesList= [self enemyNeighborsToCountry: country];
	Country *adj;
	Country *supCountry = country;
	
	for (i= 0; i< [enemiesList count]; ++i) {
		adj= [enemiesList objectAtIndex: i];
		if ( (diff= ([adj troopCount] - [country movableTroopCount]) ) > maxDiff ) {
			maxDiff= diff;
			supCountry= adj;
		}
	}
	// fprintf( stderr, "Most superior enemy to %s is %s\n", [country name], [supCountry name]);
	return supCountry;
}

- (Country *)findAdjacentEnemyCountryMostInferiorTo:(Country *) country
{
    int i;
    int diff, maxDiff= +9999;
    id enemiesList= [self enemyNeighborsToCountry: country];
    Country *adj;
    Country *supCountry= country;

    for (i= 0; i< [enemiesList count]; ++i) {
	adj= [enemiesList objectAtIndex: i];
	if ( (diff= ([adj movableTroopCount] - [country troopCount]) ) < maxDiff ) {
	    maxDiff= diff;
	    supCountry= adj;
	}
    }
    // fprintf( stderr, "Most inferior enemy to %s is %s\n", [country name], [supCountry name]);
    return supCountry;
}

- (Country *)findMyCountryWithMostSuperiorEnemy
{
	NSSet<Country*> *mycountries = [gameManager.world countriesForPlayer:playerNumber];
	Country *inCountry= nil;
	int maxDiffInArmiesForInCountry= -9999;
	//int armiesFromCards;
	int armiesDiff;
	id adjacentEnemyCountryMostSuperior;

	for (Country *country in mycountries) {
	    adjacentEnemyCountryMostSuperior= [self findAdjacentEnemyCountryMostSuperiorTo: country ];
	    if (adjacentEnemyCountryMostSuperior != country && (armiesDiff= [adjacentEnemyCountryMostSuperior troopCount] - [country movableTroopCount]) > maxDiffInArmiesForInCountry) {
		// fprintf( stderr, "worse enemy to %s found: %s\n", [country name], [adjacentEnemyCountryMostSuperior name]);
		maxDiffInArmiesForInCountry= armiesDiff;
		inCountry= country;
	    }
	}
	return inCountry;
}

- (Country *)findMyCountryWithMostInferiorEnemy
{
	NSSet<Country*> *mycountries = [gameManager.world countriesForPlayer:playerNumber];
	id inCountry= nil;
	int diffInArmiesForInCountry= 9999;
	//int armiesFromCards;
	int armiesDiff;
	id adjacentEnemyCountry;

	for (Country *country in mycountries) {
	    adjacentEnemyCountry= [self findAdjacentEnemyCountryMostInferiorTo: country ];
	    if ( adjacentEnemyCountry != country && (armiesDiff= [adjacentEnemyCountry troopCount] - [country movableTroopCount]) < diffInArmiesForInCountry) {
		// fprintf( stderr, "easier enemy to %s found: %s\n", [country name], [adjacentEnemyCountry name]);
		diffInArmiesForInCountry= armiesDiff;
		inCountry= country;
	    }
	}
	return inCountry;
}

// *****************card utilities*********************

- (int)playCards:cardList
{
	int retVal;
	
	retVal = [super playCards:cardList];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(int)playCards:" at:0];
	[args1Form setTitle:"cardList" at:0];
	if (cardList == nil)  {
		[args1Form setStringValue:"nil" at:0];
	}  else  {
		[args1Form setStringValue:"list of cards" at:0];
	}
	[returnValueForm setIntValue:retVal at:0];
	[diagnosticPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************place army utilities*********************

- (BOOL)placeArmies:(int)numArmies inCountry:country
{
	BOOL retVal;
	
	retVal = [super placeArmies:numArmies inCountry:country];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)placeArmies: inCountry:" at:0];
	[args1Form setTitle:"numArmies" at:0];
	[args1Form setIntValue:numArmies at:0];
	[args1Form setTitle:"country" at:1];
	if (country == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[country name] at:1];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[diagnosticPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************attack utilities*********************

- (BOOL)attackFromMostThreatenedCountryUntilLeft: (int)untilLeft
{
    id inCountry;
    BOOL win= NO;
    
// repeatedly attack from country with largest enemy
// (but do not neccessarily attack largest enemy)

	while ( (inCountry= [self findMyCountryWithMostSuperiorEnemy] ) != nil) {
	    //fprintf( stderr, "possibly attacking from %s with %d armies\n", [inCountry name], [inCountry armies] );
	    if ([inCountry movableTroopCount]  <= untilLeft)
		break;
	    //fprintf( stderr, "yes, attack from %s with %d armies\n", [inCountry name], [inCountry armies] );
    
	    win = [self doAttackFrom: inCountry];
	    // if we won the game, clean up and get out.
	    if (win)  {
		break;
	    }
	}
	return win;
}

- (BOOL)attackFromLeastThreatenedCountryUntilLeft: (int)untilLeft
// repeatedly attack from country with relatively weakest enemy
{
	id inCountry;
	BOOL win= NO;
	
	while ( (inCountry= [self findMyCountryWithMostInferiorEnemy] ) != nil) {
		//fprintf( stderr, "possibly attacking from %s with %d armies\n", [inCountry name], [inCountry armies] );
		if ([inCountry movableTroopCount] <= untilLeft)
			break;
		//fprintf( stderr, "yes, attack from %s with %d armies\n", [inCountry name], [inCountry armies] );
		
		[gameManager attackFromCountry:inCountry toCountry:<#(Country *)#> untilArmiesRemain:<#(RiskArmyCount)#> moveAllArmiesUponVictory:<#(BOOL)#>]
		win = [self doAttackFrom: inCountry];
		// if we won the game, clean up and get out.
		if (win)  {
			break;
		}
	}
	return win;
}



- (BOOL)attackOnceFrom:fromCountry to:toCountry
			   victory:(BOOL *)victory fromArmies:(int *)fromArmies
			  toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
				 weWin:(BOOL *)wewin
{
	BOOL retVal;
	
	retVal = [super attackOnceFrom:fromCountry to:toCountry 
					victory:victory fromArmies:fromArmies 
					toArmies:toArmies vanquished:vanquished
					weWin:wewin];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)attackOnceFrom: to: victory: " 
					"fromArmies: toArmies: vanquished: weWin:" at:0];
	[args1Form setTitle:"fromCountry" at:0];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:0];
	}  else  {
		[args1Form setStringValue:[fromCountry name] at:0];
	}
	[args1Form setTitle:"toCountry" at:1];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[toCountry name] at:1];
	}
	[args1Form setTitle:"victory" at:2];
	if (*victory)  {
		[args1Form setStringValue:"YES" at:2];
	}  else  {
		[args1Form setStringValue:"NO" at:2];
	}
	[args1Form setTitle:"fromArmies" at:3];
	[args1Form setIntValue:*fromArmies at:3];
	[args2Form setTitle:"toArmies" at:0];
	[args2Form setIntValue:*toArmies at:0];
	[args2Form setTitle:"vanquished" at:1];
	if (*vanquished)  {
		[args2Form setStringValue:"YES" at:1];
	}  else  {
		[args2Form setStringValue:"NO" at:1];
	}
	[args2Form setTitle:"weWin" at:2];
	if (*wewin)  {
		[args2Form setStringValue:"YES" at:2];
	}  else  {
		[args2Form setStringValue:"NO" at:2];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[diagnosticPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

- (BOOL)attackTimes:(int)times from:fromCountry to:toCountry 
			victory:(BOOL *)victory fromArmies:(int *)fromArmies
		   toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
			  weWin:(BOOL *)wewin
{
	BOOL retVal;
	
	retVal = [super attackTimes:times from:fromCountry to:toCountry 
					victory:victory fromArmies:fromArmies 
					toArmies:toArmies vanquished:vanquished
					weWin:wewin];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)attackTimes: from: to: victory: " 
					"fromArmies: toArmies: vanquished: weWin:" at:0];
	[args1Form setTitle:"times" at:0];
	[args1Form setIntValue:times at:0];
	[args1Form setTitle:"fromCountry" at:1];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[fromCountry name] at:1];
	}
	[args1Form setTitle:"toCountry" at:2];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:2];
	}  else  {
		[args1Form setStringValue:[toCountry name] at:2];
	}
	[args1Form setTitle:"victory" at:3];
	if (*victory)  {
		[args1Form setStringValue:"YES" at:3];
	}  else  {
		[args1Form setStringValue:"NO" at:3];
	}
	[args2Form setTitle:"fromArmies" at:0];
	[args2Form setIntValue:*fromArmies at:0];
	[args2Form setTitle:"toArmies" at:1];
	[args2Form setIntValue:*toArmies at:1];
	[args2Form setTitle:"vanquished" at:2];
	if (*vanquished)  {
		[args2Form setStringValue:"YES" at:2];
	}  else  {
		[args2Form setStringValue:"NO" at:2];
	}
	[args2Form setTitle:"weWin" at:3];
	if (*wewin)  {
		[args2Form setStringValue:"YES" at:3];
	}  else  {
		[args2Form setStringValue:"NO" at:3];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[diagnosticPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

- (BOOL)attackUntilLeft:(int)untilLeft from:fromCountry to:toCountry 
				victory:(BOOL *)victory fromArmies:(int *)fromArmies
			   toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
				  weWin:(BOOL *)wewin
{
	BOOL retVal;
	
	retVal = [super attackUntilLeft:untilLeft from:fromCountry to:toCountry 
					victory:victory fromArmies:fromArmies 
					toArmies:toArmies vanquished:vanquished
					weWin:wewin];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)attackUntilLeft: from: to: "
					"victory: fromArmies: toArmies: vanquished: weWin:" at:0];
	[args1Form setTitle:"untilLeft" at:0];
	[args1Form setIntValue:untilLeft at:0];
	[args1Form setTitle:"fromCountry" at:1];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[fromCountry name] at:1];
	}
	[args1Form setTitle:"toCountry" at:2];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:2];
	}  else  {
		[args1Form setStringValue:[toCountry name] at:2];
	}
	[args1Form setTitle:"victory" at:3];
	if (*victory)  {
		[args1Form setStringValue:"YES" at:3];
	}  else  {
		[args1Form setStringValue:"NO" at:3];
	}
	[args2Form setTitle:"fromArmies" at:0];
	[args2Form setIntValue:*fromArmies at:0];
	[args2Form setTitle:"toArmies" at:1];
	[args2Form setIntValue:*toArmies at:1];
	[args2Form setTitle:"vanquished" at:2];
	if (*vanquished)  {
		[args2Form setStringValue:"YES" at:2];
	}  else  {
		[args2Form setStringValue:"NO" at:2];
	}
	[args2Form setTitle:"weWin" at:3];
	if (*wewin)  {
		[args2Form setStringValue:"YES" at:3];
	}  else  {
		[args2Form setStringValue:"NO" at:3];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[diagnosticPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

- (BOOL)attackUntilCantFrom:fromCountry to:toCountry 
					victory:(BOOL *)victory fromArmies:(int *)fromArmies
				   toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
					  weWin:(BOOL *)wewin
{
	BOOL retVal;
	
	retVal = [super attackUntilCantFrom:fromCountry to:toCountry 
					victory:victory fromArmies:fromArmies 
					toArmies:toArmies vanquished:vanquished
					weWin:wewin];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)attackUntilCantFrom: to: "
					"victory: fromArmies: toArmies: vanquished: weWin:" at:0];
	[args1Form setTitle:"fromCountry" at:0];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:0];
	}  else  {
		[args1Form setStringValue:[fromCountry name] at:0];
	}
	[args1Form setTitle:"toCountry" at:1];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[toCountry name] at:1];
	}
	[args1Form setTitle:"victory" at:2];
	if (*victory)  {
		[args1Form setStringValue:"YES" at:2];
	}  else  {
		[args1Form setStringValue:"NO" at:2];
	}
	[args1Form setTitle:"fromArmies" at:3];
	[args1Form setIntValue:*fromArmies at:3];
	[args2Form setTitle:"toArmies" at:0];
	[args2Form setIntValue:*toArmies at:0];
	[args2Form setTitle:"vanquished" at:1];
	if (*vanquished)  {
		[args2Form setStringValue:"YES" at:1];
	}  else  {
		[args2Form setStringValue:"NO" at:1];
	}
	[args2Form setTitle:"weWin" at:2];
	if (*wewin)  {
		[args2Form setStringValue:"YES" at:2];
	}  else  {
		[args2Form setStringValue:"NO" at:2];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[diagnosticPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************post-attack & fortify utilities*********************

- (BOOL)moveArmies:(int)numArmies from:fromCountry to:toCountry
{
	BOOL retVal;
	
	retVal = [super moveArmies:numArmies from:fromCountry to:toCountry];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)moveArmies: from: to:" at:0];
	[args1Form setTitle:"numArmies" at:0];
	[args1Form setIntValue:numArmies at:0];
	[args1Form setTitle:"fromCountry" at:1];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[fromCountry name] at:1];
	}
	[args1Form setTitle:"toCountry" at:1];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[toCountry name] at:1];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[diagnosticPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************special diagnostic methods*******************special**

- (void)waitForContinue
{
	int retVal;
	
	NSBeep();
	if (![diagnosticPanel isVisible])
		[diagnosticPanel orderFront:self];
	[pauseContinueButton setEnabled:NO];
	retVal = [NSApp runModalForWindow:diagnosticPanel];
}

- (IBAction)continueAction:sender
{
	[NSApp stopModal];
	[pauseContinueButton setEnabled:YES];
}

- (IBAction)checkAction:sender
{
	if ([sender state] == 1)  {
		[continueButton setEnabled:YES];
	}  else  {
		[continueButton setEnabled:NO];
	}
}

- (void)clearArgForms
{
	[(NSFormCell*)[args1Form cellAtIndex:0] setTitle:@"arg1:"];
	[(NSFormCell*)[args1Form cellAtIndex:1] setTitle:@"arg2:"];
	[(NSFormCell*)[args1Form cellAtIndex:2] setTitle:@"arg3:"];
	[(NSFormCell*)[args1Form cellAtIndex:3] setTitle:@"arg4:"];
	[(NSFormCell*)[args2Form cellAtIndex:0] setTitle:@"arg5:"];
	[(NSFormCell*)[args2Form cellAtIndex:1] setTitle:@"arg6:"];
	[(NSFormCell*)[args2Form cellAtIndex:2] setTitle:@"arg7:"];
	[(NSFormCell*)[args2Form cellAtIndex:3] setTitle:@"arg8:"];
	[(NSFormCell*)[args1Form cellAtIndex:0] setStringValue:@""];
	[(NSFormCell*)[args1Form cellAtIndex:1] setStringValue:@""];
	[(NSFormCell*)[args1Form cellAtIndex:2] setStringValue:@""];
	[(NSFormCell*)[args1Form cellAtIndex:3] setStringValue:@""];
	[(NSFormCell*)[args2Form cellAtIndex:0] setStringValue:@""];
	[(NSFormCell*)[args2Form cellAtIndex:1] setStringValue:@""];
	[(NSFormCell*)[args2Form cellAtIndex:2] setStringValue:@""];
	[(NSFormCell*)[args2Form cellAtIndex:3] setStringValue:@""];
}

- (void)setNotes:(NSString *)noteText
{
	[[[notesScrollText documentView] textStorage] setAttributedString: [[NSAttributedString alloc] initWithString:noteText]];
}

@end
