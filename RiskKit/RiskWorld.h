//
// $Id: RiskWorld.h,v 1.2 1997/12/13 19:37:10 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class Continent;
@class RKCountry;
@class RKCard;
@class RiskNeighbor;

NS_ASSUME_NONNULL_BEGIN

//! A \c RiskWorld has a name, continents with countries, and neighboring
//! country data.
//!
//! If multiple RiskWorlds are allowed, each world could be a bundle
//! that has the images for each card, as well as the encoded data for
//! the world and the RiskMapView background image.
//!
//! This should own the background image for the map view if there will
//! be more than one world.
@interface RiskWorld : NSObject <NSCoding>
{
    NSMutableSet<RKCountry*> *allCountries;
    NSArray<RiskNeighbor*> *countryNeighbors;
    NSDictionary<NSString*,Continent *> *continents;
    NSArray<RKCard*> *cards;
}

+ (RiskWorld*)defaultRiskWorld NS_SWIFT_NAME(init(default:));

+ (instancetype)riskWorldWithContinents:(NSDictionary<NSString*,Continent *> *)theContinents countryNeighbors:(NSArray<RiskNeighbor*> *)neighbors cards:(NSArray<RKCard*> *)theCards NS_SWIFT_UNAVAILABLE("Use init(continents:countryNeighbors:cards:) instead");

- (instancetype)initWithContinents:(NSDictionary<NSString*,Continent *> *)theContinents countryNeighbors:(NSArray<RiskNeighbor*> *)neighbors cards:(NSArray<RKCard*> *)theCards NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (void) _buildAllCountries;
- (void) _connectCountries;
- (void) _disconnectCountries;

@property (copy, readonly) NSSet<RKCountry*> *allCountries;
- (nullable Continent *) continentNamed:(NSString *)continentName NS_SWIFT_NAME(continent(named:));
@property (readonly, strong) NSDictionary<NSString*,Continent *> *continents;
@property (readonly, strong) NSArray<RKCard*> *cards;

/// Calculate the number of bonus armies earned for a player at the
/// beginning of a turn based on the continents that they completely
/// occupy.
- (RKArmyCount) continentBonusArmiesForPlayer:(RKPlayer)number;
- (NSSet<RKCountry*> *) countriesForPlayer:(RKPlayer)number;

@end

//======================================================================
// Some utility functions.
//======================================================================

NSSet<RKCountry*> *RWcountriesForPlayerNumber (NSSet<RKCountry*> *source, RKPlayer number);
NSSet<RKCountry*> *RWcountriesInContinentNamed (NSSet<RKCountry*> *source, NSString *continentName);
NSSet<RKCountry*> *RWcountriesWithArmies (NSSet<RKCountry*> *source);
NSSet<RKCountry*> *RWneighborsOfCountries (NSSet<RKCountry*> *source);

NS_ASSUME_NONNULL_END
