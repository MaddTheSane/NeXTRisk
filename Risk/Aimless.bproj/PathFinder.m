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

RCSID ("$Id: PathFinder.m,v 1.1.1.1 1997/12/09 07:19:16 nygard Exp $");

#import "PathFinder.h"

#import <RiskKit/RKCountry.h>
#import <RiskKit/RiskWorld.h>
#import "SNHeap.h"
#import "DNode.h"
#import <RiskKit/SNUtility.h>

static NSComparisonResult PFCompareDistances(RKCountry *country1, RKCountry *country2, void *context)
{
    NSDictionary<NSString*,DNode*> *nodeDictionary = (__bridge NSDictionary *)context;
    NSString *name1 = country1.countryName;
    NSString *name2 = country2.countryName;
    NSInteger distance1 = nodeDictionary[name1].distance;
    NSInteger distance2 = nodeDictionary[name2].distance;
    NSComparisonResult result;
    
    if (distance1 < distance2) {
        result = NSOrderedAscending;
    } else if (distance1 == distance2) {
        int troopCount1, troopCount2;
        
        // Choose country with fewest troops.
        troopCount1 = country1.troopCount;
        troopCount2 = country2.troopCount;
        
        if (troopCount1 < troopCount2) {
            result = NSOrderedAscending;
            //NSLog (@"<");
        } else if (troopCount1 == troopCount2) {
            result = NSOrderedSame;
            //NSLog (@"==");
        } else {
            result = NSOrderedDescending;
            //NSLog (@">");
        }
        
        if (result == NSOrderedAscending) {
            NSCAssert (troopCount1 < troopCount2, @"troopCount1 >= troopCount2");
        } else if (result == NSOrderedSame) {
            NSCAssert (troopCount1 == troopCount2, @"troopCount1 != troopCount2");
        } else {
            NSCAssert (troopCount1 > troopCount2, @"troopCount1 <= troopCount2");
        }
    } else {
        result = NSOrderedDescending;
    }
    
    return result;
}

//----------------------------------------------------------------------

int PFConstantDistance (RKCountry *country1, RKCountry *country2)
{
    return 1;
}

//----------------------------------------------------------------------

BOOL PFCountryForPlayer (RKCountry *country, void *context)
{
    BOOL flag;
    RKPlayer number;
    
    number = (RKPlayer)context;
    flag = country.playerNumber == number;
    
    return flag;
}

//----------------------------------------------------------------------

BOOL PFCountryForPlayerHasEnemyNeighbors (RKCountry *country, void *context)
{
    BOOL flag;
    RKPlayer number;
    
    number = (RKPlayer)context;
    if (country.playerNumber == number && [country enemyNeighborCountries].count > 0)
        flag = YES;
    else
        flag = NO;
    
    return flag;
}

//======================================================================

@implementation PathFinder


+ (id)shortestPathInRiskWorld:(RiskWorld *)aWorld
                  fromCountry:(RKCountry *)source
                 forCountries:(BOOL (*)(RKCountry *, void *))anIsCountryAcceptableFunction
                      context:(void *)aContext
             distanceFunction:(int (*)(RKCountry *, RKCountry *))aDistanceFunction
{
    return [[PathFinder alloc] initWithRiskWorld:aWorld
                                fromCountry:source
                                forCountries:anIsCountryAcceptableFunction
                                context:aContext
                                distanceFunction:aDistanceFunction];
}

//----------------------------------------------------------------------

- (id)initWithRiskWorld:(RiskWorld *)aWorld
            fromCountry:(RKCountry *)source
           forCountries:(BOOL (*)(RKCountry *, void *))anIsCountryAcceptableFunction
                context:(void *)aContext
       distanceFunction:(int (*)(RKCountry *, RKCountry *))aDistanceFunction
{
    if (self = [super init]) {
        acceptableCountries = [[NSMutableSet alloc] init];
        nodeDictionary = [[NSMutableDictionary alloc] init];
        isCountryAcceptable = anIsCountryAcceptableFunction;
        context = aContext;
        distanceFunction = aDistanceFunction;
        world = aWorld;
        
        [self _buildShortestPathsFromCountry:source];
    }

    return self;
}

//----------------------------------------------------------------------

- (void) _buildShortestPathsFromCountry:(RKCountry *)source
{
    NSSet<RKCountry*> *allCountries;
    RKCountry *country;
    DNode *node;
    SNHeap<RKCountry*> *countryHeap;

    [nodeDictionary removeAllObjects];
    [acceptableCountries removeAllObjects];

    allCountries = world.allCountries;

    // Build acceptable countries.
    for (RKCountry *country in allCountries)
    {
        if (isCountryAcceptable (country, context) == YES)
        {
            [acceptableCountries addObject:country];
            node = [DNode new];
            nodeDictionary[country.countryName] = node;
        }
    }

    node = nodeDictionary[source.countryName];
    node.distance = 0;


    countryHeap = [SNHeap heapUsingFunction:PFCompareDistances context:(__bridge void *)(nodeDictionary)];

    for (RKCountry *country in acceptableCountries)
    {
        [countryHeap insertObject:country];
    }

    while ((country = [countryHeap extractObject]))
    {
        for (RKCountry *neighbor in [country ourNeighborCountries])
        {
            NSInteger tmp;

            tmp = nodeDictionary[country.countryName].distance + distanceFunction (country, neighbor);
            if (nodeDictionary[neighbor.countryName].distance > tmp)
            {
                [nodeDictionary[neighbor.countryName] setDistance:tmp withPrevious:country];
                //[countryHeap heapifyFromObject:neighbor];
                [countryHeap removeObject:neighbor];
                [countryHeap insertObject:neighbor];
            }
        }
    }
}

//----------------------------------------------------------------------

- (SNHeap *) _minimumDistanceCountryHeap
{
    SNHeap<RKCountry*> *countryHeap;
    RKCountry *country;

    countryHeap = [SNHeap heapUsingFunction:PFCompareDistances context:(__bridge void *)(nodeDictionary)];
    for (country in acceptableCountries)
    {
        [countryHeap insertObject:country];
    }

    return countryHeap;
}

//----------------------------------------------------------------------

- (NSArray *) shortestPathToCountry:(RKCountry *)target
{
    NSMutableArray *path1, *path2;
    DNode *node;
    RKCountry *previous;
    NSEnumerator *objectEnumerator;

    path1 = [NSMutableArray array];
    path2 = [NSMutableArray array];

    //NSLog (@"target: %@", target);

    [path1 addObject:target];

    node = nodeDictionary[target.countryName];
    while ((previous = node.previous))
    {
        [path1 addObject:previous];
        target = previous;
        node = nodeDictionary[target.countryName];
    }

    objectEnumerator = [path1 reverseObjectEnumerator];
    for (id object in objectEnumerator)
    {
        [path2 addObject:object];
    }

    //NSLog (@"Initial path is: %@", path2);
    // Remove first object?  It should be the source.
    if (path2.count > 0)
    {
        [path2 removeObjectAtIndex:0];
    }

    return path2;
}

//----------------------------------------------------------------------

- (NSArray *) shortestPathToAcceptableCountry:(BOOL (*)(RKCountry *, void *))isCountryAcceptableTarget context:(void *)aContext
{
    SNHeap<RKCountry*> *countryHeap;
    RKCountry *country;
    NSArray *path = nil;

    countryHeap = [self _minimumDistanceCountryHeap];
    while ((country = [countryHeap extractObject]))
    {
        if (isCountryAcceptableTarget (country, aContext) == YES)
        {
            path = [self shortestPathToCountry:country];
            break;
        }
    }

    return path;
}

//----------------------------------------------------------------------

- (RKCountry *) firstStepToCountry:(RKCountry *)target
{
    NSArray *path;
    RKCountry *first;

    path = [self shortestPathToCountry:target];

    if (path.count > 0)
        first = path[0];
    else
        first = nil;

    return first;
}

//----------------------------------------------------------------------

- (RKCountry *) firstStepToAcceptableCountry:(BOOL (*)(RKCountry *, void *))isCountryAcceptableTarget context:(void *)aContext
{
    NSArray *path;
    RKCountry *first;

    path = [self shortestPathToAcceptableCountry:isCountryAcceptableTarget context:aContext];

    //NSLog (@"path is: %@", path);

    if (path.count > 0)
        first = path[0];
    else
        first = nil;
#if 0
    if (first == nil)
    {
        NSLog (@"path is: %@", path);
    }
#endif
    return first;
}

@end
