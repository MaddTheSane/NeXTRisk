//
// $Id: Country.h,v 1.2 1997/12/15 07:43:44 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class CountryShape, RiskMapView;

@interface Country : NSObject <NSCoding>
{
    NSString *name;
    CountryShape *countryShape;
    NSString *continentName;
    NSMutableSet<Country*> *neighborCountries;

    // The occupying army:
    Player playerNumber;
    RiskArmyCount troopCount;
    RiskArmyCount unmovableTroopCount;
}

- (instancetype)initWithCountryName:(NSString *)aName
                      continentName:(NSString *)aContinentName
                              shape:(CountryShape *)aCountryShape
                          continent:(RiskContinent)aContinent NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSString *countryName;
@property (readonly, strong) CountryShape *countryShape;
@property (readonly, copy) NSString *continentName;
@property (weak, readonly) NSSet<Country*> *neighborCountries;

- (void) setAdjacentToCountry:(Country *)aCountry;
- (void) resetAdjacentCountries;
- (BOOL) isAdjacentToCountry:(Country *)aCountry;
@property (readonly) BOOL bordersAnotherContinent;

- (void) drawInView:(RiskMapView *)aView isSelected:(BOOL)selected;
- (BOOL) pointInCountry:(NSPoint)aPoint;

@property (readonly, copy) NSString *description;

//----------------------------------------------------------------------
// Army methods
//----------------------------------------------------------------------

@property (nonatomic) Player playerNumber;
@property (nonatomic) RiskArmyCount troopCount;
@property (readonly) RiskArmyCount movableTroopCount;

- (void) addTroops:(RiskArmyCount)count;

/// We need to keep track of the unmovable troops (the troops that have
/// already been fortified), otherwise under the "fortify many to many
/// neighbors" rule, you could march the armies up to the front one
/// country at a time.
@property (readonly) RiskArmyCount unmovableTroopCount;
- (void) addUnmovableTroopCount:(RiskArmyCount)count;
- (void) resetUnmovableTroops;

- (void) update;

//======================================================================
// Useful methods:
//======================================================================

@property (readonly, copy) NSSet<Country *> *connectedCountries;
@property (readonly, copy) NSSet<Country *> *ourNeighborCountries;
@property (readonly, copy) NSSet<Country *> *ourConnectedCountries;
@property (readonly, copy) NSSet<Country *> *enemyNeighborCountries;

@property (readonly) RiskArmyCount enemyNeighborTroopCount;
@property (readonly) RiskArmyCount ourNeighborTroopCount;

//======================================================================
// Useful, somewhat optimized methods:
//======================================================================

@property (readonly) BOOL hasEnemyNeighbors;
@property (readonly) BOOL hasFriendlyNeighborsWithEnemyNeighbors;
@property (readonly) BOOL hasTroops;
@property (readonly) BOOL hasMobileTroops;

- (BOOL) surroundedByPlayerNumber:(Player)number;
- (BOOL) hasEnemyNeighborsExcludingCountry:(Country *)excludedCountry;

@end

extern NSString *const CountryUpdatedNotification;
