//
// $Id: PathFinder.h,v 1.1.1.1 1997/12/09 07:19:16 nygard Exp $
//

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

#import <Foundation/Foundation.h>
#import <RiskKit/RiskKit.h>

@class Country, RiskWorld, SNHeap<ObjectType>;
@class DNode;

extern NSComparisonResult PFCompareDistances (id country1, id country2, void *context);
extern int PFConstantDistance (Country *country1, Country *country2);
extern BOOL PFCountryForPlayer (Country *country, void *context);
extern BOOL PFCountryForPlayerHasEnemyNeighbors (Country *country, void *context);

// Uses Dijkstra's single-source shortest path algorithm.  This means that the
// distance function must return a positive result.

@interface PathFinder : NSObject
{
    NSMutableSet<Country*> *acceptableCountries;
    NSMutableDictionary<NSString*,DNode*> *nodeDictionary;
    BOOL (*isCountryAcceptable)(Country *, void *);
    void *context;
    int (*distanceFunction)(Country *, Country *);

    RiskWorld *world;
}

+ (instancetype)shortestPathInRiskWorld:(RiskWorld *)aWorld
              fromCountry:(Country *)source
             forCountries:(BOOL (*)(Country *, void *))anIsCountryAcceptableFunction
                  context:(void *)aContext
         distanceFunction:(int (*)(Country *, Country *))aDistanceFunction;

- (instancetype)initWithRiskWorld:(RiskWorld *)aWorld
        fromCountry:(Country *)source
       forCountries:(BOOL (*)(Country *, void *))anIsCountryAcceptableFunction
            context:(void *)aContext
   distanceFunction:(int (*)(Country *, Country *))aDistanceFunction NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void) _buildShortestPathsFromCountry:(Country *)source;
@property (readonly, strong) SNHeap<Country*> *_minimumDistanceCountryHeap;

- (NSArray<Country*> *) shortestPathToCountry:(Country *)target;
- (NSArray<Country*> *) shortestPathToAcceptableCountry:(BOOL (*)(Country *, void *))isCountryAcceptableTarget context:(void *)aContext;

- (Country *) firstStepToCountry:(Country *)target;
- (Country *) firstStepToAcceptableCountry:(BOOL (*)(Country *, void *))isCountryAcceptableTarget context:(void *)aContext;

@end
