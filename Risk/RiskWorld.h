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
    NSMutableSet *allCountries;
    NSArray<RiskNeighbor*> *countryNeighbors;
    NSDictionary<NSString*,Continent *> *continents;
    NSArray<RiskCard*> *cards;
}

+ (RiskWorld*)defaultRiskWorld;

+ (instancetype)riskWorldWithContinents:(NSDictionary<NSString*,Continent *> *)theContinents countryNeighbors:(NSArray<RiskNeighbor*> *)neighbors cards:(NSArray *)theCards;

- (instancetype)initWithContinents:(NSDictionary<NSString*,Continent *> *)theContinents countryNeighbors:(NSArray<RiskNeighbor*> *)neighbors cards:(NSArray *)theCards NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (void) _buildAllCountries;
- (void) _connectCountries;
- (void) _disconnectCountries;

- (NSSet<Country*> *) allCountries;
- (Continent *) continentNamed:(NSString *)continentName;
@property (readonly, retain) NSDictionary<NSString*,Continent *> *continents;
@property (readonly, retain) NSArray<RiskCard*> *cards;

- (int) continentBonusArmiesForPlayer:(Player)number;
- (NSSet<Country*> *) countriesForPlayer:(Player)number;

@end

//======================================================================
// Some utility functions.
//======================================================================

NSSet<Country*> *RWcountriesForPlayerNumber (NSSet<Country*> *source, Player number);
NSSet<Country*> *RWcountriesInContinentNamed (NSSet<Country*> *source, NSString *continentName);
NSSet<Country*> *RWcountriesWithArmies (NSSet<Country*> *source);
NSSet<Country*> *RWneighborsOfCountries (NSSet<Country*> *source);