//
// $Id: RiskWorld.h,v 1.2 1997/12/13 19:37:10 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class Continent;
@class Country;
@class RiskCard;
@class RiskNeighbor;

// This should own the background image for the map view if there will
// be more than one world.

@interface RiskWorld : NSObject <NSCoding>
{
    NSMutableSet<Country*> *allCountries;
    NSArray<RiskNeighbor*> *countryNeighbors;
    NSDictionary<NSString*,Continent *> *continents;
    NSArray<RiskCard*> *cards;
}

+ (RiskWorld*)defaultRiskWorld;

+ (instancetype)riskWorldWithContinents:(NSDictionary<NSString*,Continent *> *)theContinents countryNeighbors:(NSArray<RiskNeighbor*> *)neighbors cards:(NSArray *)theCards NS_SWIFT_UNAVAILABLE("Use init(continents:countryNeighbors:cards:) instead");

- (instancetype)initWithContinents:(NSDictionary<NSString*,Continent *> *)theContinents countryNeighbors:(NSArray<RiskNeighbor*> *)neighbors cards:(NSArray<RiskCard*> *)theCards NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (void) _buildAllCountries;
- (void) _connectCountries;
- (void) _disconnectCountries;

@property (weak, readonly) NSSet<Country*> *allCountries;
- (Continent *) continentNamed:(NSString *)continentName;
@property (readonly, strong) NSDictionary<NSString*,Continent *> *continents;
@property (readonly, strong) NSArray<RiskCard*> *cards;

/// Calculate the number of bonus armies earned for a player at the
/// beginning of a turn based on the continents that they completely
/// occupy.
- (RiskArmyCount) continentBonusArmiesForPlayer:(Player)number;
- (NSSet<Country*> *) countriesForPlayer:(Player)number;

@end

//======================================================================
// Some utility functions.
//======================================================================

NSSet<Country*> *RWcountriesForPlayerNumber (NSSet<Country*> *source, Player number);
NSSet<Country*> *RWcountriesInContinentNamed (NSSet<Country*> *source, NSString *continentName);
NSSet<Country*> *RWcountriesWithArmies (NSSet<Country*> *source);
NSSet<Country*> *RWneighborsOfCountries (NSSet<Country*> *source);
