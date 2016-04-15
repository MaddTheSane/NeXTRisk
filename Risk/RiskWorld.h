//
// $Id: RiskWorld.h,v 1.2 1997/12/13 19:37:10 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class Continent;

// This should own the background image for the map view if there will
// be more than one world.

@interface RiskWorld : NSObject
{
    NSMutableSet *allCountries;
    NSArray *countryNeighbors;
    NSDictionary *continents;
    NSArray *cards;
}

+ (void) initialize;

+ defaultRiskWorld;

+ riskWorldWithContinents:(NSDictionary *)theContinents countryNeighbors:(NSArray *)neighbors cards:(NSArray *)theCards;

- initWithContinents:(NSDictionary *)theContinents countryNeighbors:(NSArray *)neighbors cards:(NSArray *)theCards;
- (void) dealloc;

- (void) encodeWithCoder:(NSCoder *)aCoder;
- initWithCoder:(NSCoder *)aDecoder;

- (void) _buildAllCountries;
- (void) _connectCountries;
- (void) _disconnectCountries;

- (NSSet *) allCountries;
- (Continent *) continentNamed:(NSString *)continentName;
- (NSDictionary *) continents;
- (NSArray *) cards;

- (int) continentBonusArmiesForPlayer:(Player)number;
- (NSSet *) countriesForPlayer:(Player)number;

@end

//======================================================================
// Some utility functions.
//======================================================================

NSSet *RWcountriesForPlayerNumber (NSSet *source, Player number);
NSSet *RWcountriesInContinentNamed (NSSet *source, NSString *continentName);
NSSet *RWcountriesWithArmies (NSSet *source);
NSSet *RWneighborsOfCountries (NSSet *source);
