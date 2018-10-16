
/*###########################################################
	Written by Don McGregor  Version 1.0, Feb 1992.

	This code is free for any use.  GNU copyleft
	rules apply.  This code has no warrantability
	of fitness for a particular use, I am not 
	responsible for any damage to data that might
	be caused by bugs, etc, etc. 
	
	I encourage others to examine and improve on this
	code, and to post the improvements to the net.
	
	Don McGregor, mcgregdr@conan.ie.orst.edu (for now).

 ###########################################################*/

#import "SortedList.h"
#import "Country.h"
#import "PlayerCode.h"

@implementation StratSortedList

+ initialize
{
  /*-----------------------------------------------------------
      Sets the class version; useful for unarchiving several
      older versions of the object as time improves it.
  -----------------------------------------------------------*/
  
  [StratSortedList setVersion:CURRENT_SORTED_LIST_VERSION];
  
  return self;
}

- initCount:(unsigned int)numSlots forPlayer:thePlayer
{
  /*-----------------------------------------------------------
      Initialize the data and internal structures.  This should
      not be used to reinitialize an already alloc'd and init'd
      instance; instead, free the list first and then create
      a new one.
      
      This is the designated initializer for the class.
    -----------------------------------------------------------*/
    
    [super initCount:numSlots];
					
    riskPlayer		= thePlayer;
    sortOrder 		= ASCENDING;
    caseSensitive 	= YES;
    keySortType		= -1;		//causes error if not set
    					//to something else
      
    return self;
}

- setSortOrder:(int)theSortOrder
{
  /*-----------------------------------------------------------
      Just sets the way in which the sortedList is maintained,
      either ascending order (1,2,3,4...) or descending (5,4,3,2,1).
      
      Also resorts the list if this is a change from the prior
      sort order.  This can be done by simply reversing the order
      of the list; no fancy sorts needed.  This does it by removing
      the top object and putting it at the end size times.
      
      Can't use addObject: in the for loop, even though it looks
      like a good place for it; that method calls insertObject:at:
      internally and sends the message to self.  that blows up 
      when the message gets sent to this object.
    -----------------------------------------------------------*/
    int	i, size;
    id	tempObj;
    
    if(sortOrder != theSortOrder)
    	{
    		sortOrder = theSortOrder;
		size = [self count];
		
		for(i = 0; i < size; i++)
		  {
		  	tempObj = [self removeObjectAt:0];
			[super insertObject:tempObj at:(size - 1)];
		  }
	}
    
    return self;
}

- (int)sortOrder
{
  /*-----------------------------------------------------------
      Returns the sort order.
  -----------------------------------------------------------*/
  
  return sortOrder;
}

-setCaseSensitive:(BOOL)isIt
{
  /*-----------------------------------------------------------
     Whether or not compares on strings are case sensitive
  -----------------------------------------------------------*/
  
  caseSensitive = isIt;
  
  return self;
}

- (BOOL)caseSensitive
{
  return caseSensitive;
}

- setKeySortType:(int)theKeySortType
{
  /*-----------------------------------------------------------
      sets the type of sort to use on the list; resort the list
    -----------------------------------------------------------*/

    keySortType = theKeySortType;

    if ([self count] > 1)
	[self insertionSort];  	//new sort method, new order too.		
    
    return self;
}

- (int)keySortType
{
  /*-----------------------------------------------------------
     Returns the type of sort to use on the list
  -----------------------------------------------------------*/
  
  return keySortType;
}

// Return the number of armies in a country.
- (int)armiesOfCountry:thisCountry;
{
	return [thisCountry armies];
}

// Return the attackability of an enemy country.  It is desirable to attack
// stronger enemies before weaker ones, unless we don't have a card yet, in
// which case the opposite applies.  It is also desireable to attack
// enemies near extinction before those not.  It is desireable to attack
// enemies with fewer/weaker enemy neighbors than other enemies.  It is also
// desirable to attack enemies with more/stronger friendly neighbors than
// other enemies.
// The higher the score returned by this method, the more desirable the
// country is as a target of attack.
- (double)attackabilityOfEnemy:thisCountry;
{
	BOOL bust = YES;
	int i, cc, morecc, cont, encont, enpl;
	double score = 0;
	id countries, morecountries;

	// Basic score, based on how many enemy armies there are.  Normally,
	// we want to attack stronger enemies, but if we haven't taken a
	// country yet this turn, weaker enemies are more attractive targets.
	if ([riskPlayer takenACountry])
		score = [thisCountry armies];
	else
		score = -[thisCountry armies];

	// Big-time bonus for being near extinction; the nearer, the bigger.
	// Small per country penalty to make it more attractive to attack
	// players with fewer countries.
	enpl = [thisCountry player];
	countries = [riskPlayer playersCountries:enpl];
	cc = [countries count];
	[countries free];
	if (cc <= 3)
		score += 400 * (4 - cc);
	else
		score -= 5 * cc;

	// Penalty for having enemy neighbors.
	score -= [riskPlayer enemyArmiesAround:thisCountry];

	// Further penalty for having several neighboring enemy countries,
	// regardless of their strength.  But add a big-time bonus if any
	// of them are near extinction (the nearer, the bigger); also a
	// small per country penalty to make it more attractive to attack
	// enemies who have enemy neighbors with fewer countries.
	countries = [riskPlayer enemyNeighborsTo:thisCountry];
	if (countries != nil) {
		cc = [countries count];
		for (i = 0; i < cc; i++) {
			morecountries = [riskPlayer playersCountries:[[countries objectAt:i] player]];
			morecc = [morecountries count];
			[morecountries free];
			if (morecc <= 3)
				score += 200 * (4 - morecc);
			else
				score -= 5 * morecc;
		}
		[countries free];
		score -= 20 * cc;
	}

	// Bonus for having friendly neighbors.
	score += [riskPlayer friendlyArmiesAround:thisCountry];

	// Further bonus for having several neighboring friendly countries,
	// regardless of their strength.  Slightly higher per country bonus
	// than is the per country penalty for enemy neighbors, making us
	// more inclined to attack where we have a larger presence.
	countries = [riskPlayer friendlyNeighborsTo:thisCountry];
	cc = [countries count];
	[countries free];
	score += 25 * cc;

	// Another bonus if the country is on the same continent as the
	// attacking country.
	cont = [riskPlayer continentOfCountry:[riskPlayer countryOfAttack]];
	encont = [riskPlayer continentOfCountry:thisCountry];
	if (encont == cont)
		score += 25;

	// Another bonus if the country is on a different continent, one
	// completely possessed by an enemy player.  We wanna bust the
	// continent, if possible.
	if (encont != cont) {
		countries = [riskPlayer countriesInContinent:encont];
		for (i = 0; i < [countries count]; i++) {
			if ([[countries objectAt:i] player] != enpl) {
				bust = NO;
				break;
			}
		}
		[countries free];
		if (bust)
			score += 50;
	}

	return score;
}

// Return the reinforcement priority of a country.  It is desirable to
// reinforce our countries that do not outnumber their surrounding enemies
// before our countries that do.  It is also desirable to reinforce countries
// that neighbor enemies who have a lot of high attackability features (e.g.
// they are just about wiped out [we want their cards], they are owned by a
// player who possesses the whole continent [we want to bust it], etc.).  See
// the attackabilityOfEnemy: method.  It is also more desirable to reinforce
// countries on continents where we occupy a higher percentage of the
// countries than other continents (to improve our chances to take over
// continents).
// The higher the score returned by this method, the more desirable the
// country is as a site for reinforcement.  The reinforcing algorithm may
// decide not to reinforce it after all, however, for some other reason.
- (double)reinforcePrioOfCountry:thisCountry;
{
	BOOL bust = NO;
	int i, j, cc, cont, mycont, encont, mypl, enpl, numfr = 0;
	double score = 0;
	id enemies, countries;

	// Sanity check.  If no enemy armies surround thisCountry, don't
	// bother reinforcing.
	if ([riskPlayer enemyArmiesAround:thisCountry] == 0)
		return 0;

	// Basic score based on the percentage of this continent possessed
	// by us.  This makes us tend to go after continents where we have
	// a stronger presence.
	mycont = [riskPlayer continentOfCountry:thisCountry];
	mypl = [thisCountry player];
	countries = [riskPlayer countriesInContinent:mycont];
	cc = [countries count];
	for (i = 0; i < cc; i++) {
		if ([[countries objectAt:i] player] == mypl)
			numfr++;
	}
	[countries free];
	score += (double)numfr / (double)cc * 500;

	// Penalty for the number of countries in the continent.
	// This makes us tend to go after smaller continents (smaller
	// penalty for smaller continents).  Other penalties for the
	// number of entry/exit points on the continent, and the number
	// of neighboring countries on other continents.
	score -= cc * 5;
	score -= [riskPlayer exitsOfContinent:mycont] * 5;
	score -= [riskPlayer neighborsOfContinent:mycont] * 5;

	// Add the fudge factor bonus for the continent.
	score += [riskPlayer fudgeOfContinent:mycont];

	// Bonus/penalty score, based on the ratio of surrounding enemy
	// armies to armies in the country itself.  If we outnumber the
	// enemies more than 25%, apply a penalty, else apply a bonus.
	if ([thisCountry armies] >= ([riskPlayer enemyArmiesAround:thisCountry] + 1) * 1.25) {
		score -= (double)[thisCountry armies] /
				(double)[riskPlayer enemyArmiesAround:thisCountry] * 25;
	}
	else {
		score += ((double)[riskPlayer enemyArmiesAround:thisCountry] + 1) /
				(double)[thisCountry armies] * 25;
	}

	// Bonus for having neighboring friendly countries, regardless of
	// their strength, making us more inclined to reinforce where we have
	// a larger presence.  Big bonus for having neighboring friendlies
	// on another continent that we mostly/completely possess; we want to
	// protect this point.
	countries = [riskPlayer friendlyNeighborsTo:thisCountry];
	if (countries != nil) {
		cc = [countries count];
		score += 5 * cc;
		for (i = 0; i < cc; i++) {
			cont = [riskPlayer continentOfCountry:[countries objectAt:i]];
			if (cont != mycont &&
					[riskPlayer ourPercentageOfContinent:cont] >= 0.75)
				score += 200;
		}
		[countries free];
	}

	// Bonus if this country is an entry/exit point for a continent; it
	// should have a higher priority due to its strategic position.
	score += [riskPlayer foreignNeighborsOfCountry:thisCountry] * 10;

	// Big-time bonus for having enemy neighbors near extinction; the
	// nearer, the bigger.  Small per country penalty to make neighbors
	// with fewer countries more attractive to reinforce against.
	// Another bonus if there are enemy neighbors on the same continent,
	// and we're close to possessing the continent.
	// Yet another bonus if there are neighbors on a different continent,
	// one completely possessed by an enemy player.  We wanna bust the
	// continent, if possible.
	enemies = [riskPlayer enemyNeighborsTo:thisCountry];
	for (i = 0; i < [enemies count]; i++) {
		// Check for weaklings.
		enpl = [[enemies objectAt:i] player];
		countries = [riskPlayer playersCountries:enpl];
		cc = [countries count];
		[countries free];
		if (cc <= 3)
			score += 200 * (4 - cc);
		else
			score -= cc * 10;

		// Check for enemy neighbors on our continent.
		encont = [riskPlayer continentOfCountry:[enemies objectAt:i]];
		if (encont == mycont && [riskPlayer ourPercentageOfContinent:mycont] >= 0.75) {
			score += 200;
		}
		else if (encont != mycont) { // Now check for continent busting.
			countries = [riskPlayer countriesInContinent:encont];
			bust = YES;
			for (j = 0; j < [countries count]; j++) {
				if ([[countries objectAt:j] player] != enpl) {
					bust = NO;
					break;
				}
			}
			[countries free];
		}
		if (bust)
			score += 75;
	}
	[enemies free];

	// Small penalty for armies already in this country so that, all other
	// things being nearly equal, countries with fewer armies are favored.
	score -= [thisCountry armies] * 2;

	return score;
}

#if 0
// Return the attack advantage of a country with respect to its weakest
// neighbor.
- (double)advantageWeakOfCountry:thisCountry;
{
	int i, enc;
	double advantage = 0;
	id enemies, weakest;

	enemies = [riskPlayer enemyNeighborsTo:thisCountry];
	enc = [enemies count];
	if (enc) {
		weakest = [enemies objectAt:0];
		for (i = 1; i < enc; i++)
			if ([[enemies objectAt:i] armies] < [weakest armies])
				weakest = [enemies objectAt:i];

		// The advantage is the country's armies divided by its
		// weakest neighbor's armies, plus the country's armies.  We
		// add the country's armies to weight the advantage; this
		// makes odds of 20 to 10 look better than odds of 2 to 1,
		// which would otherwise be ranked evenly.
		advantage = (double)[thisCountry armies] /
				(double)[weakest armies] +
				(double)[thisCountry armies];
	}
	[enemies free];
	return advantage;
}
#endif

// Return the attack advantage of a country with respect to its strongest
// neighbor.
- (double)advantageStrongOfCountry:thisCountry;
{
	int i, enc;
	double advantage = 0;
	id enemies, friends, strongest;

	enemies = [riskPlayer enemyNeighborsTo:thisCountry];
	enc = [enemies count];
	if (enc) {
		strongest = [enemies objectAt:0];
		for (i = 1; i < enc; i++)
			if ([[enemies objectAt:i] armies] > [strongest armies])
				strongest = [enemies objectAt:i];

		// The basic advantage is based on the country's armies
		// divided by its strongest neighbor's armies.
		advantage = (double)[thisCountry armies] /
				(double)[strongest armies] * 20;

		// Bonus for the country's armies.  We do this to weight the
		// advantage, making odds of 20 to 10 look better than odds
		// of 2 to 1, which would otherwise be ranked evenly.
		advantage += (double)[thisCountry armies];

		// Big penalty for the country's number of enemy neighbors * 10.
		// We do this to give countries with fewer enemy neighbors
		// a better advantage than countries with more enemies.  We
		// thus attack first in areas of fewer options and second in
		// areas of greater options.
		advantage -= (double)(enc * 50);

		// Bonus for the country's number of friendly neighbors * 15.
		// We do this to give countries with more friendly neighbors
		// a better advantage than countries with less.  The bonus is
		// higher per friend than is the penalty per enemy, to weight
		// things in favor of attack from strength rather than against
		// weakness.
		friends = [riskPlayer friendlyNeighborsTo:thisCountry];
		if (friends != nil) {
			advantage += (double)([friends count] * 15);
			[friends free];
		}
	}
	[enemies free];
	return advantage;
}

- printKeyValues
{
  /*-----------------------------------------------------------
      Prints out the key values of the objects in the sortedList,
      in the order they are stored in the list.  This is really
      just an internal debugging sort of thing, but most people
      wind up using something like this sooner or later.
      
      This method should not be called in any production code.
  -----------------------------------------------------------*/
  
  int	count, i;
  id	listObject;
  
  printf("---------------\n");
  count = [self count];
  
  for(i = 0; i < count; i++) {
  
	listObject = [self objectAt:i];
	
	switch(keySortType) {
		    case COUNTRYBYARMIES:
			printf("%d: %d, for object %d\n", i, 
				[self armiesOfCountry:listObject],
				(int)listObject);
			break;
		    case ENEMYBYATTACKABILITY:
			printf("%d: %g, for object %d\n", i, 
				[self attackabilityOfEnemy:listObject],
				(int)listObject);
			break;
		    case COUNTRYBYREINFORCEPRIO:
			printf("%d: %g, for object %d\n", i, 
				[self reinforcePrioOfCountry:listObject],
				(int)listObject);
			break;
#if 0
		    case COUNTRYBYTACTICALADVANTAGEWEAK:
			printf("%d: %g, for object %d\n", i, 
				[self advantageWeakOfCountry:listObject],
				(int)listObject);
			break;
#endif
		    case COUNTRYBYTACTICALADVANTAGESTRONG:
			printf("%d: %g, for object %d\n", i, 
				[self advantageStrongOfCountry:listObject],
				(int)listObject);
			break;
#if 0
		    case PLAYERBYCOUNTRIES:
			printf("%d: %d, for object %d\n", i, 
				[self countriesOfPlayer:listObject],
				(int)listObject);
			break;
#endif
		    default:
			[self error:"attempt print contents of StratSortedList when the key value of object is of unknown type"];
			break;
	}
		
  }
   
  printf("---------------\n");

  return self;
}


- addObject:anObject
{
  /*-----------------------------------------------------------
     Adds an object to the sortedList.  Uses a binary search to
     find the insert point.
     
     By convention, the "top" of the list is at 0, and the "bottom"
     of the list is at the last slot.  Conceptually this is a 
     top-to bottom arrangement, a convention followed in naming
     the variables here.
     
     If the object does not respond to the accessor method, we
     should catch it here and punt big-time.
   -----------------------------------------------------------*/
   
   int	topPtr = 0, bottomPtr, pivot;
   int	compareResult;
   
   bottomPtr 	= [self count] - 1;
   pivot 	= (int)((topPtr + bottomPtr)/2);
   
   	//empty list; insert and get out of here
	
   if(bottomPtr == -1)	
     {
       [super insertObject:anObject at:0];
       return self;
     }  
   
   
   	//The real interest.  Do a binary search until the insertion pt
	//is found.
	
   compareResult = [self compare:[self objectAt:pivot] to:anObject];

   do
     {      
   	if(compareResult > 0)
      		    bottomPtr 	= pivot - 1;
		 else
		    topPtr 	= pivot + 1;
		    
   	pivot = (int)((topPtr + bottomPtr)/2);
	compareResult = [self compare:[self objectAt:pivot] to:anObject];
     }
   while ((compareResult != 0) && (topPtr < bottomPtr));
   
   	//Insert the new object
	
   if(compareResult >= 0)
  	[super insertObject:anObject at:pivot];
     else 
     	[super insertObject:anObject at:pivot+1];

  return self;
}

- addObjectIfAbsent:anObject
{
  /*-----------------------------------------------------------
     More overrides of List methods.  We need to make sure all additions
     are done through the addObject: method to ensure it all stays
     sorted.
  -----------------------------------------------------------*/
  
 if([self indexOf:anObject] == NX_NOT_IN_LIST)
     {
       [self addObject:anObject];
     }
 return self;
}

- (BOOL)isEqual:anObject
{
  /*-----------------------------------------------------------
     Similar to the list op,which compares the to lists for equality.
     We also need to check for the new instance vars declared
     in this object, and make sure this is a StratSortedList rather
     than just a List.
  -----------------------------------------------------------*/
  
  if([self class] != [anObject class])
     return NO;
  
  if(([anObject sortOrder] 	!= [self sortOrder]) 	 ||
     ([anObject caseSensitive] 	!= [self caseSensitive]) ||
     ([anObject keySortType] 	!= [self keySortType]))
        return NO;

   return [super isEqual:anObject];
}
  
- (int)compare:thisObject to:thatObject
{
  /*-----------------------------------------------------------
     Compares the values of the keys of thisObject and thatObject
     using the specified sort mechanism.
     
     returns a number larger than zero if the first object's key is 
     larger than the other object's, a number smaller than zero if  
     the first object is less than the second, and zero if they have 
     the same key values.  For complex sorts, "larger" means that it
     comes after the object when sorted in ascending order.
     
    -----------------------------------------------------------*/
   
   double	compareResults = 0;	// Difference between two numerics
   int		orderFlag;
   
   
   	//This can be either ascending or descending.  To do with compares we'll
	//just use a flag, -1 or 1, and multiply that by the integer result.
	//that'll flip the comparision results depending on asc or desc.
	
   orderFlag = (sortOrder == ASCENDING) ? 1 : -1;
      
   switch(keySortType)
     {
	case COUNTRYBYARMIES:
		compareResults = (double)[self armiesOfCountry:thisObject] -
			[self armiesOfCountry:thatObject];
		break;
	case ENEMYBYATTACKABILITY:
		compareResults = [self attackabilityOfEnemy:thisObject] -
				[self attackabilityOfEnemy:thatObject];
		break;
	case COUNTRYBYREINFORCEPRIO:
		compareResults = [self reinforcePrioOfCountry:thisObject] -
				[self reinforcePrioOfCountry:thatObject];
		break;
#if 0
	case COUNTRYBYTACTICALADVANTAGEWEAK:
		compareResults = [self advantageWeakOfCountry:thisObject] -
			[self advantageWeakOfCountry:thatObject];
		break;
#endif
	case COUNTRYBYTACTICALADVANTAGESTRONG:
		compareResults = [self advantageStrongOfCountry:thisObject] -
			[self advantageStrongOfCountry:thatObject];
		break;
	default:
		[self error:"unspecified type of comparision operator\n"];
    }

    //return -1, 0, or 1.
    if (compareResults < 0) return orderFlag * (-1);
    if (compareResults > 0) return orderFlag * 1;
    return 0;
}


- insertionSort;
{
  /*-----------------------------------------------------------
     do a simple insertion sort.  This is good for files that
     are "alomst sorted", as I suspect that many data sets
     will be in this application.  Besides, it's easy to program
     and I'm lazy right now :-)
     
     I'm sure someone can do something more sophisticated 
     than this.
  -----------------------------------------------------------*/
  
  int	i, j, dataSize, compareResult;
  id	listEl;
  
  dataSize = [self count];
  
  for(i = 1; i < dataSize; i++)
    {
      j = i-1;
      listEl = [self objectAt:i];
      
      while(((compareResult = [self compare:[self objectAt:j] to:listEl]) > 0) &&
       	     		(j >=1))
	j--;
      
      if(compareResult > 0)
        {
      	  [super removeObjectAt:i];
          [super insertObject:listEl at:j];
	}
	
   }
   
 return self;
}

-copy
{
  /*-----------------------------------------------------------
     An override to keep things hunky-dory with all the instance 
     vars.
  -----------------------------------------------------------*/
  
  id	newList;
  
  newList = [super copy];
  
  [newList setSortOrder:	[self sortOrder]];
  [newList setCaseSensitive:	[self caseSensitive]];
  [newList setKeySortType:	[self keySortType]];
  
  return newList;
}
  
-copyFromZone:(NXZone*)zone
{
  /*-----------------------------------------------------------
      Ditto above method.
  -----------------------------------------------------------*/
  
  id	newList;
  
  newList = [super copyFromZone:zone];
  
  [newList setSortOrder:	[self sortOrder]];
  [newList setCaseSensitive:	[self caseSensitive]];
  [newList setKeySortType:	[self keySortType]];
  
  return newList;
}


/*-----------------------------------------------------------  
         Methods that return a rutime error if called 
  -----------------------------------------------------------*/

- insertObject:anObject at:(unsigned int)index
{
  [self error:" objects should not be sent insertObject:at: messages.\n"];
	
  return self;	//foo-faw to keep the compiler happy 'bout return types
}

- replaceObjectAt:(unsigned int)index with:newObject 
{
  [self error:"%s objects should not be sent replaceObjectAt:with: messages.\n"];
	
  return self;	//foo-faw to keep the compiler happy 'bout return types

}

- replaceObject:anObject with:newObject
{
  [self error:"%s objects should not be sent replaceObject:with: messages.\n"];
	
  return self;	//foo-faw to keep the compiler happy 'bout return types

}

/*-----------------------------------------------------------
                    Archiving methods
-----------------------------------------------------------*/

-write:(NXTypedStream*)stream
{
  /*-----------------------------------------------------------
     Write out the instance variables and the superclass
     object structure.
  -----------------------------------------------------------*/
  
  [super write:stream];
  NXWriteTypes(stream, "ic:i", &sortOrder, 
		  &caseSensitive, &keySortType);
			
  return self;
}

- read:(NXTypedStream*)stream
{
  /*-----------------------------------------------------------
    Read the object back in
  -----------------------------------------------------------*/
  
  [super read:stream];
  NXReadTypes(stream, "ic:i", &sortOrder, 
		  &caseSensitive, &keySortType);

  return self;
}
 
  
@end
