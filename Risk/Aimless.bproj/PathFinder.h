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

@class RKCountry, RiskWorld, SNHeap<ObjectType>;
@class DNode;

NS_ASSUME_NONNULL_BEGIN

typedef int(*PFDistance)(RKCountry *country1, RKCountry *country2);
typedef BOOL(*PFAcceptableCountry)(RKCountry *country, void *__nullable context);

extern int PFConstantDistance (RKCountry *country1, RKCountry *country2);
extern BOOL PFCountryForPlayer (RKCountry *country, void *context);
extern BOOL PFCountryForPlayerHasEnemyNeighbors (RKCountry *country, void *context);

//! Uses Dijkstra's single-source shortest path algorithm.  This means that the
//! distance function must return a positive result.
@interface PathFinder : NSObject
{
    NSMutableSet<RKCountry*> *acceptableCountries;
    NSMutableDictionary<NSString*,DNode*> *nodeDictionary;
    BOOL (*isCountryAcceptable)(RKCountry *, void *);
    void *context;
    int (*distanceFunction)(RKCountry *, RKCountry *);

    RiskWorld *world;
}

+ (instancetype)shortestPathInRiskWorld:(RiskWorld *)aWorld
                            fromCountry:(RKCountry *)source
                           forCountries:(PFAcceptableCountry)anIsCountryAcceptableFunction
                                context:(void *)aContext
                       distanceFunction:(PFDistance)aDistanceFunction;

- (instancetype)initWithRiskWorld:(RiskWorld *)aWorld
                      fromCountry:(RKCountry *)source
                     forCountries:(PFAcceptableCountry)anIsCountryAcceptableFunction
                          context:(void *)aContext
                 distanceFunction:(PFDistance)aDistanceFunction NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void) _buildShortestPathsFromCountry:(RKCountry *)source;
@property (readonly, strong) SNHeap<RKCountry*> *_minimumDistanceCountryHeap;

- (NSArray<RKCountry*> *) shortestPathToCountry:(RKCountry *)target;
- (nullable NSArray<RKCountry*> *) shortestPathToAcceptableCountry:(PFAcceptableCountry)isCountryAcceptableTarget context:(nullable void *)aContext;

- (nullable RKCountry *) firstStepToCountry:(RKCountry *)target;
- (nullable RKCountry *) firstStepToAcceptableCountry:(PFAcceptableCountry)isCountryAcceptableTarget context:(void *)aContext;

@end

NS_ASSUME_NONNULL_END
