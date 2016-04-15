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

#import "../Risk.h"

RCSID ("$Id: PathFinder.m,v 1.1.1.1 1997/12/09 07:19:16 nygard Exp $");

#import "PathFinder.h"

#import "Country.h"
#import "RiskWorld.h"
#import "SNHeap.h"
#import "DNode.h"
#import "SNUtility.h"

NSComparisonResult PFCompareDistances (id country1, id country2, void *context)
{
    NSDictionary *nodeDictionary;
    NSString *name1, *name2;
    int distance1, distance2;
    NSComparisonResult result;

    nodeDictionary = (NSDictionary *)context;
    name1 = [(Country *)country1 countryName];
    name2 = [(Country *)country2 countryName];

    distance1 = [[nodeDictionary objectForKey:name1] distance];
    distance2 = [[nodeDictionary objectForKey:name2] distance];

    if (distance1 < distance2)
        result = NSOrderedAscending;
    else if (distance1 == distance2)
    {
        int troopCount1, troopCount2;

        // Choose country with fewest troops.
        troopCount1 = [(Country *)country1 troopCount];
        troopCount2 = [(Country *)country2 troopCount];
        
        if (troopCount1 < troopCount2)
        {
            result = NSOrderedAscending;
            //NSLog (@"<");
        }
        else if (troopCount1 == troopCount2)
        {
            result = NSOrderedSame;
            //NSLog (@"==");
        }
        else
        {
            result = NSOrderedDescending;
            //NSLog (@">");
        }

        if (result == NSOrderedAscending)
        {
            NSCAssert (troopCount1 < troopCount2, @"troopCount1 >= troopCount2");
        }
        else if (result == NSOrderedSame)
        {
            NSCAssert (troopCount1 == troopCount2, @"troopCount1 != troopCount2");
        }
        else
        {
            NSCAssert (troopCount1 > troopCount2, @"troopCount1 <= troopCount2");
        }
    }
    else
        result = NSOrderedDescending;

    return result;
}

//----------------------------------------------------------------------

int PFConstantDistance (Country *country1, Country *country2)
{
    return 1;
}

//----------------------------------------------------------------------

BOOL PFCountryForPlayer (Country *country, void *context)
{
    BOOL flag;
    Player number;

    number = (Player)context;
    flag = [country playerNumber] == number;

    return flag;
}

//----------------------------------------------------------------------

BOOL PFCountryForPlayerHasEnemyNeighbors (Country *country, void *context)
{
    BOOL flag;
    Player number;

    number = (Player)context;
    if ([country playerNumber] == number && [[country enemyNeighborCountries] count] > 0)
        flag = YES;
    else
        flag = NO;

    return flag;
}

//======================================================================

@implementation PathFinder


+ shortestPathInRiskWorld:(RiskWorld *)aWorld
              fromCountry:(Country *)source
             forCountries:(BOOL (*)(Country *, void *))anIsCountryAcceptableFunction
                  context:(void *)aContext
         distanceFunction:(int (*)(Country *, Country *))aDistanceFunction
{
    return [[[PathFinder alloc] initWithRiskWorld:aWorld
                                fromCountry:source
                                forCountries:anIsCountryAcceptableFunction
                                context:aContext
                                distanceFunction:aDistanceFunction] autorelease];
}

//----------------------------------------------------------------------

- initWithRiskWorld:(RiskWorld *)aWorld
        fromCountry:(Country *)source
       forCountries:(BOOL (*)(Country *, void *))anIsCountryAcceptableFunction
            context:(void *)aContext
   distanceFunction:(int (*)(Country *, Country *))aDistanceFunction
{
    [super init];

    acceptableCountries = [[NSMutableSet set] retain];
    nodeDictionary = [[NSMutableDictionary dictionary] retain];
    isCountryAcceptable = anIsCountryAcceptableFunction;
    context = aContext;
    distanceFunction = aDistanceFunction;
    world = [aWorld retain];

    [self _buildShortestPathsFromCountry:source];

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [acceptableCountries release];
    [nodeDictionary release];
    [world release];

    [super dealloc];
}

//----------------------------------------------------------------------

- (void) _buildShortestPathsFromCountry:(Country *)source
{
    NSSet *allCountries;
    NSEnumerator *countryEnumerator, *neighborEnumerator;
    Country *country, *neighbor;
    DNode *node;
    SNHeap *countryHeap;

    [nodeDictionary removeAllObjects];
    [acceptableCountries removeAllObjects];

    allCountries = [world allCountries];

    // Build acceptable countries.
    countryEnumerator = [allCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (isCountryAcceptable (country, context) == YES)
        {
            [acceptableCountries addObject:country];
            node = [DNode dNode];
            [nodeDictionary setObject:node forKey:[country countryName]];
        }
    }

    node = [nodeDictionary objectForKey:[source countryName]];
    [node setDistance:0];


    countryHeap = [SNHeap heapUsingFunction:PFCompareDistances context:nodeDictionary];

    countryEnumerator = [acceptableCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        [countryHeap insertObject:country];
    }

    while ((country = [countryHeap extractObject]))
    {
        neighborEnumerator = [[country ourNeighborCountries] objectEnumerator];
        while (neighbor = [neighborEnumerator nextObject])
        {
            int tmp;

            tmp = [[nodeDictionary objectForKey:[country countryName]] distance] + distanceFunction (country, neighbor);
            if ([[nodeDictionary objectForKey:[neighbor countryName]] distance] > tmp)
            {
                [[nodeDictionary objectForKey:[neighbor countryName]] setDistance:tmp withPrevious:country];
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
    SNHeap *countryHeap;
    NSEnumerator *countryEnumerator;
    Country *country;

    countryHeap = [SNHeap heapUsingFunction:PFCompareDistances context:nodeDictionary];
    countryEnumerator = [acceptableCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        [countryHeap insertObject:country];
    }

    return countryHeap;
}

//----------------------------------------------------------------------

- (NSArray *) shortestPathToCountry:(Country *)target
{
    NSMutableArray *path1, *path2;
    DNode *node;
    Country *previous;
    NSEnumerator *objectEnumerator;
    id object;

    path1 = [NSMutableArray array];
    path2 = [NSMutableArray array];

    //NSLog (@"target: %@", target);

    [path1 addObject:target];

    node = [nodeDictionary objectForKey:[target countryName]];
    while ((previous = [node previous]))
    {
        [path1 addObject:previous];
        target = previous;
        node = [nodeDictionary objectForKey:[target countryName]];
    }

    objectEnumerator = [path1 reverseObjectEnumerator];
    while (object = [objectEnumerator nextObject])
    {
        [path2 addObject:object];
    }

    //NSLog (@"Initial path is: %@", path2);
    // Remove first object?  It should be the source.
    if ([path2 count] > 0)
    {
        [path2 removeObjectAtIndex:0];
    }

    return path2;
}

//----------------------------------------------------------------------

- (NSArray *) shortestPathToAcceptableCountry:(BOOL (*)(Country *, void *))isCountryAcceptableTarget context:(void *)aContext
{
    SNHeap *countryHeap;
    Country *country;
    NSArray *path;

    path = nil;
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

- (Country *) firstStepToCountry:(Country *)target
{
    NSArray *path;
    Country *first;

    path = [self shortestPathToCountry:target];

    if ([path count] > 0)
        first = [path objectAtIndex:0];
    else
        first = nil;

    return first;
}

//----------------------------------------------------------------------

- (Country *) firstStepToAcceptableCountry:(BOOL (*)(Country *, void *))isCountryAcceptableTarget context:(void *)aContext
{
    NSArray *path;
    Country *first;

    path = [self shortestPathToAcceptableCountry:isCountryAcceptableTarget context:aContext];

    //NSLog (@"path is: %@", path);

    if ([path count] > 0)
        first = [path objectAtIndex:0];
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
