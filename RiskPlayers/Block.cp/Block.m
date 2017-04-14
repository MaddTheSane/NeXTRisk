// Block.m
// Part of Risk by Mike Ferris

#import "Block.h"
#import <appkit/Application.h>
#import <appkit/Form.h>
#import <appkit/Button.h>
#import <appkit/Text.h>
#import <appkit/ScrollView.h>
#import <appkit/Panel.h>
#import <objc/List.h>
#import <appkit/publicWraps.h>

#include <libc.h>
#include <stdlib.h>

#define NIBFILE "Block.cp/Block.nib"

//#define MIN(a,b) ( (a)<(b) ? (a) : (b) )
//#define MAX(a,b) ( (a)>(b) ? (a) : (b) )
#define SLEEP  /*sleep(4)*/
@implementation Block

+ initialize
{
	if (self = [Block class])  {
		[self setVersion:1];
	}
	return self;
}

- initPlayerNum:(int)pnum mover:mover gameSetup:gamesetup mapView:mapview
				cardManager:cardmanager
{
	[super initPlayerNum:pnum mover:mover gameSetup:gamesetup mapView:mapview
				cardManager:cardmanager];
	return self;
}

- free
{	
	return [super free];
}

// *****************subclass responsibilities*********************
// "Argentina", "Peru", "Venezuela", "Brazil", "Central America", "Western United States", "Eastern United States", "Alberta", "Northwest Territory", "Ontario", "Alaska", "Quebec", "Greenland", "Iceland", "Great Britain", "Western Europe", "Southern Europe", "Northern Europe", "Ukraine", "Scandinavia", "South Africa", "Congo", "East Africa", "Egypt", "Madagascar", "Middle East", "India", "Siam", "China", "Afghanistan", "Ural", "Siberia", "Mongolia", "Irkutsk", "Yakutsk", "Kamchatka", "Japan", "Western Australia", "Eastern Australia", "New Guinea", "Indonesia", 

- yourChooseCountry
{
	id unoccList = [self unoccupiedCountries];
	id takeCountry= nil;
       	id preferedCountries= [self preferedCountriesEmpty: YES];
	
	if ([unoccList count]==0)  {
		return nil;
	}
        // try preferred countries first, select one free country randomly

	if ( [preferedCountries count] > 0) {
	    takeCountry= [preferedCountries objectAt: [rng randMax: [preferedCountries count] - 1] ];
	}
	// fprintf( stderr, "choose: prefList: %d, random chosen %s\n", [preferedCountries count],[takeCountry name] );
	
        // else inherited chaotic behaviour

	if (takeCountry==nil) {
	    [super yourChooseCountry];
	}
	else {
	    [self occupyCountry:takeCountry];
	}
	
	[preferedCountries free];
	[unoccList free];
	return self;
}

- yourInitialPlaceArmies:(int)numArmies
{
	id mycountries = [self myCountries];
	id inCountry= nil;
	id preferedCountries= [self preferedCountriesEmpty: NO];
//	id l= nil;
	int try,tries= 20;
	int chunk, anz;
	
	//fprintf(stderr, "initial: %d\n", numArmies);

	if ([mycountries count]==0)
		return nil;

        // if one of our pref Countries is available choose one randomly, with less than numArmies 
        // but only if we do not already have anz enemy neighbors advantage
	anz= MAX(numArmies, 5);
	
	while (numArmies > 0 && tries-- > 0) {
	    for (try=0; try< 10 && inCountry==nil; ++try) {
		if ([preferedCountries count] > 0) {
		    inCountry= [self randomFromList: preferedCountries maxArmies:numArmies-1];
		if (tries > 5 && inCountry && 
		    [inCountry armies] - [self sumEnemyNeighborsTo:inCountry] >= anz  )
		    inCountry= nil;
		}
	    }
	
	    if (inCountry==nil) {
		inCountry= [self findMyCountryWithMostSuperiorEnemy];
	    }
	    if (inCountry!=nil) {
		id en,my;
		en= [self mostSuperiorEnemyTo:inCountry];
		my= [self myStrongestNeighborTo:en];
		//fprintf( stderr, "initial place: I am %d, inCountry=%s belongs to %d , has strongest enemyNeighbor %s belongs to %d, my strongest neighbor %s belongs to %d\n", myPlayerNum, [inCountry name], [inCountry player], [en name], [en player], [my name], [my player]);
		if ([my player]==myPlayerNum)
		    inCountry= my;
		if (tries > 5 && inCountry && 
		    [inCountry armies] - [self sumEnemyNeighborsTo:inCountry] >= anz  )
		    inCountry= nil;
	    }

	    
	    if (inCountry==nil) {
		fprintf( stderr, "no good country for initial placement in tries=%d\n", tries );
	    }
	    else {
		numArmies-= (chunk= MIN(anz/2, numArmies));
		[self placeArmies:chunk inCountry:inCountry];
	    }
	}
	if (numArmies > 0) {
	    fprintf( stderr, "finally no good country for initial placement\n");
	    [super yourInitialPlaceArmies: numArmies];	    
	}
	

	[mycountries free];
	[preferedCountries free];
	return self;
}

- yourTurnWithArmies:(int)numArmies andCards:(int)numCards
{
	id mycountries = [self myCountries];
	id inCountry= nil;
	int try, anz, chunk;
	BOOL win=NO;
	
	//fprintf(stderr, "turn: %d %d", numArmies, numCards);
	
	if ([mycountries count]==0)  {
		return nil;
	}

// turn in cards

	numArmies += [self turnInCards];
	//fprintf(stderr, " +cards > %d \n", numArmies);
	// fprintf( stderr, "new %d armies, %d countries\n", numArmies, [mycountries count] );
	
// find own country with largest plus of own armies compared to all its neighbours
// repeatedly for all armies to be set

	try= 20;
	anz= MAX(numArmies, 4);
	while (numArmies > 0 && try-- > 0) {
	    
	    inCountry= [self myStrongestNeighborTo:[self mostSuperiorEnemyTo:[self findMyCountryWithMostSuperiorEnemy]]];
	    if ([inCountry player] != myPlayerNum) {
		fprintf( stderr, "*** this should not happen\n");
		inCountry= [self findMyCountryWithMostSuperiorEnemy];
	    }
	    if (try > 5 && inCountry && 
		[inCountry armies] - [self sumEnemyNeighborsTo:inCountry] >= anz  )
		inCountry= nil;
    
	    if (inCountry == nil) {
		fprintf( stderr, "turn, no country to set in\n" );
		// we don't know what to do, so we behave chaotic like super
	    }
	    else {
		numArmies-= (chunk= MIN(anz/2, numArmies));
		[self placeArmies:chunk inCountry:inCountry];
	    }
	}
	[self placeArmies:numArmies];

	
// now start attacking. 
	
	for (try=3; try>=0 && !win; --try)
	    win= [self attackFromMostThreatenedCountryUntilLeft: try+2];
	if (! win)
	    for (try=3; try>=0 && !win; --try)
		win= [self attackFromLeastThreatenedCountryUntilLeft: try+1];

// only fortify if we haven't won the game 

	// fprintf( stderr, "now fortify\n" );
	if (!win)  {
		[self fortifyPosition];
	}
	
	//[attackers free];
	[mycountries free];
	//sleep(2);
	// fprintf( stderr, "turn: end\n\n");
	
	return self;
}

- youWereAttacked:country by:(int)player
{
	// do nothing.  these methods are for advanced players only.
	// but we do set the notes and pause if we should.

	return self;
}

- youLostCountry:country to:(int)player
{
	// do nothing.  these methods are for advanced players only.
	// but we do set the notes and pause if we should.

	return self;
}

- getCountryNamed:(char*)name
{
	id countryList = [self countryList];
	int i,cnt = [countryList count];
	id c;
	
	//fprintf( stderr, "getC: %s, listC=%d\n", name, cnt);
	
	for (i=0; i<cnt; i++)
	{
	    c= [countryList objectAt:i];
	    
		if (!strcmp(name, [c name]))
		{
                        // fprintf(stderr, "Got:%s Wanted:%s\n",[[countryList objectAt:i] name], name); 
			[countryList free];
			return c;
		}
	}
	[countryList free];
	return nil;
}


- preferedCountriesEmpty: (BOOL)yes
{
    // return List of following countries, which are 
    // Yes: also empty
    // No:  belong to myself
	char *preferedCountries[]= { "Greenland", "Indonesia", "New Guinea", "Western Australia", "Eastern Australia", "Argentina", "Peru", "Venezuela", "Brazil", "Iceland",  "Central America", "North Africa", "South Africa", "Congo", "East Africa", "Egypt", 
"" };
	id list= [[List alloc] initCount: 20];
	int j;
	id c;
	
		
	for (j=0; *preferedCountries[j] != '\0'; j++) {
	    c= [self getCountryNamed: preferedCountries[j]];
	    // fprintf( stderr, "c=%s, wanted %s\n", [c name], preferedCountries[j] );
	    if ( c!= nil && ((yes && [c armies] < 1) || (!yes && [c player]==myPlayerNum)) )
		[list addObject: c];
	}
	return list;
}

- randomFromList:list maxArmies:(int)anz
{
    int i;
    id r=nil;
    
    id l= [[List alloc] init];
    
    for (i= 0; i< [list count]; ++i)
	if ([[list objectAt:i] armies] <= anz) [l addObject:[list objectAt:i]];
    if ([l count] > 0)
	r= [l objectAt:[rng randMax:[l count]-1] ];
    [l free];
    return r;
}

- mostSuperiorEnemyTo:country
{
    id ret= nil;
    int i;
    id list= [self enemyNeighborsTo:country];
    int d= -999;
    id en;
    
    for (i= 0; i< [list count]; ++i) {
	en= [list objectAt:i];
	if (i==0 || [en armies] > d) {
	    d= [en armies];
	    ret= en;
	}
    }
    [list free];
    return ret;
}

- myStrongestNeighborTo:en
{
    id ret= nil;
    int i;
    id l= [self neighborsTo:en];
    int d= -999;
    id n;
    for (i=0; i<[l count]; ++i) {
	n= [l objectAt:i];
	if ( (ret==nil || [n armies]>d) && [n player]==myPlayerNum ) {
	    d= [n armies];
	    ret= n;
	}
    }
    [l free];
    return ret;
}

- (BOOL)doAttackFrom:fromc
// attacks from fromc.  This method chooses a number between 1 and the number
// of armies in fromc.  It attacks until fromc has that number of armies left.
// Sometimes it won't attack at all (if the random number is the same as the
// number of armies in fromc).  If it conquers, it moves forward half of the
// armies remaining in fromc.  If it vanquishes someone, it turns in cards
// if it needs to and places any armies resulting.  returns whether the
// game is over.
{
	id toc, en = [self enemyNeighborsTo:fromc];
	int i, minArmies, fa, ta, enc = [en count];
	BOOL vict, vanq, win;
	
	// fprintf( stderr, "Block:doAttackFrom:%s with %d armies\n", [fromc name], [fromc armies]);
	
	// figure out which neighbor to attack
	if (en == nil)  {
	    SLEEP;
	    return NO;
	}
	// attack the weakest neighbor (bully tactics)
	toc = [en objectAt:0];
	for (i=1;i<enc;i++)  {
		if ([[en objectAt:i] armies] < [toc armies])  {
			toc = [en objectAt:i];
		}
	}
	// now we're done with en so free it.
	[en free];
	
	// figure out how long to attack.  pick a number between one and
	// the number of armies in fromc.  attack until there are that
	// many armies left in fromc
	minArmies = [rng randMin:1 max:[fromc armies]/3+1]; //js bully
	
	if (minArmies >= [fromc armies])  {
	    SLEEP;
	    return NO;
	}
		
	// now attack
	if ([self attackUntilLeft:minArmies from:fromc to:toc victory:&vict 
					fromArmies:&fa toArmies:&ta vanquished:&vanq weWin:&win]) {
		// if we didn't conquer the country, there is nothing more to do
		if (!vict)  {
		    SLEEP;
		    return NO;
		}
		// if we've won, there is no need to continue
		if (win)  {
			return YES;
		}
		// otherwise we must deal with the victory
		if (fa > 1)  {
			// if there are armies enough to move remaining in the fromc
			// move half of them into toc.
			
			// for diagnostic
//			[self setNotes:"sent by -(BOOL)doAttackFrom:.  doAttackFrom "
//						"advanced attacking forces."];
			
			// move half
			[self moveArmies:7*fa/8 from:fromc to:toc]; //js fu man chu
		}
		if (vanq)  {
			// if we vanquished a player, we got any cards he had, so check
			// to see if we must turn in cards.
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
		// we didn't win if we got here
	    SLEEP;
		return NO;
	}  else  {
	    // the attack failed... we didn't win
	    SLEEP;
	    return NO;
	}
}

- (int)sumEnemyNeighborsTo:c
{
    int s,i;
    id l= [self enemyNeighborsTo:c];
    for (s=0, i= 0; i<[l count]; ++i)
	s+= [[l objectAt:i] armies];
    [l free];
    return s;
}

@end

