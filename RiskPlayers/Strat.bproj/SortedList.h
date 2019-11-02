
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


#import <Foundation/Foundation.h>
#import <AppKit/NSText.h>

@class RiskPlayer;

/// Sort order, by rising value or falling value
typedef NS_ENUM(NSInteger, SSSortOrder) {
    SSSortOrderAscending	= 0,
	SSSortOrderDescending	= 1
};

#define	CURRENT_SORTED_LIST_VERSION	1

	//type of calculation to use in ordering objects

typedef NS_ENUM(NSInteger, SSSortType) {
    SSSortCountryByArmies				= 0,
    SSSortEnemyAttackAbility		    = 1,
    SSSortCountryByTacticalAdvantageWeak	= 2,
    SSSortCountryByTacticalAdvantageStrong	= 3,
    SSSortPlayerByCountries			    = 4,
    SSSortCountryByReinforcePriority    = 5
};

@interface StratSortedList: NSMutableArray <NSMutableCopying>
{  
  SSSortOrder	sortOrder;	//ascending or descending
  BOOL	caseSensitive;	//case sensitive string ordering or not
  SSSortType	keySortType;	//type of sort to do on objects
  RiskPlayer	*riskPlayer;	//the player object on whose behalf we're working
}

+ (void)initialize;				//sets class version

- (instancetype)initWithCount:(NSInteger)cnt forPlayer:(RiskPlayer*)thePlayer;	//initialization

//! the sort order
@property (nonatomic) SSSortOrder sortOrder;

//! whether strings are case senstive
@property BOOL caseSensitive;

//! type of key sort
@property (nonatomic) SSSortType keySortType;

- printKeyValues;			//useful for debugging

- (void)addObject:anObject;			//slap a new object into list
- (void)addObjectIfAbsent:anObject;		//override of List method 
- (NSComparisonResult)compare:thisObject to:thatObject;//compare operator on keys
- (BOOL)isEqual:anObject;		//similar to List op

- insertionSort;


/*--------------------------------------
      Methods that are NOT implemented
      since they make no sense for a 
      sorted list.  Attempting to call
      these will result in a runtime error.
--------------------------------------*/
 
 
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- replaceObject:anObject with:newObject;


/*--------------------------------------
         Archiving methods
--------------------------------------*/

//- write:(NXTypedStream*)stream;
//- read:(NXTypedStream*)stream;

@end
