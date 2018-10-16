
/*###########################################################
	Written by Don McGregor  Version 1.0, Feb 1992.
	Modified by Royce Howland for Risk players.

	This code is free for any use.  GNU copyleft
	rules apply.  This code has no warrantability
	of fitness for a particular use, I am not 
	responsible for any damage to data that might
	be caused by bugs, etc, etc. 
	
	I encourage others to examine and improve on this
	code, and to post the improvements to the net.

	Don McGregor, mcgregdr@conan.ie.orst.edu (for now).

 ###########################################################*/


#import <objc/Object.h>
#import <objc/List.h>
#import <appkit/Text.h>
#import <objc/HashTable.h>

	//Sort order, by rising value or falling value
	
#define ASCENDING	0
#define	DESCENDING	1

#define	CURRENT_SORTED_LIST_VERSION	1

	//type of calculation to use in ordering objects

#define	COUNTRYBYARMIES				0
#define ENEMYBYATTACKABILITY			1
#define	COUNTRYBYTACTICALADVANTAGEWEAK		2
#define	COUNTRYBYTACTICALADVANTAGESTRONG	3
#define	PLAYERBYCOUNTRIES			4
#define	COUNTRYBYREINFORCEPRIO			5

@interface StratSortedList:List
{  
  int	sortOrder;	//ascending or descending
  BOOL	caseSensitive;	//case sensitive string ordering or not
  int	keySortType;	//type of sort to do on objects
  id	riskPlayer;	//the player object on whose behalf we're working
}

+ initialize;				//sets class version

- initCount:(unsigned int)numSlots forPlayer:thePlayer;	//initialization

- setSortOrder:(int)theSortOrder; 	//the sort order, asc or desc
- (int)sortOrder;		 	//returns the sort order

- setCaseSensitive:(BOOL)isIt;		//whether strings are case senstive
- (BOOL)caseSensitive;

- setKeySortType:(int)theKeySortType;	//sets type of key sort
- (int)keySortType;			//returns type of key sort

- printKeyValues;			//useful for debugging

- addObject:anObject;			//slap a new object into list
- addObjectIfAbsent:anObject;		//override of List method 
- (int)compare:thisObject to:thatObject;//compare operator on keys
- (BOOL)isEqual:anObject;		//similar to List op

- copy;					//override of List
- copyFromZone:(NXZone*)zone;

- insertionSort;


/*--------------------------------------
      Methods that are NOT implemented
      since they make no sense for a 
      sorted list.  Attempting to call
      these will result in a runtime error.
--------------------------------------*/
 
 
- insertObject:anObject at:(unsigned int)index;
- replaceObjectAt:(unsigned int)index with:newObject; 
- replaceObject:anObject with:newObject;


/*--------------------------------------
         Archiving methods
--------------------------------------*/

- write:(NXTypedStream*)stream;
- read:(NXTypedStream*)stream;

@end
