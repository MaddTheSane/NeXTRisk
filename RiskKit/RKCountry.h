//
// $Id: Country.h,v 1.2 1997/12/15 07:43:44 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import <RiskKit/Risk.h>

NS_ASSUME_NONNULL_BEGIN

@class RKCountryShape, RiskMapView;

@interface RKCountry : NSObject <NSSecureCoding>
{
    NSString *name;
    RKCountryShape *countryShape;
    NSString *continentName;
    NSMutableSet<RKCountry*> *neighborCountries;

    // The occupying army:
    RKPlayer playerNumber;
    RKArmyCount troopCount;
    RKArmyCount unmovableTroopCount;
}

- (instancetype)initWithCountryName:(NSString *)aName
                      continentName:(NSString *)aContinentName
                              shape:(RKCountryShape *)aCountryShape
                          continent:(RiskContinent)aContinent NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSString *countryName;
@property (readonly, strong) RKCountryShape *countryShape;
@property (readonly, copy) NSString *continentName;
@property (weak, readonly) NSSet<RKCountry*> *neighborCountries;

- (void) setAdjacentToCountry:(RKCountry *)aCountry;
- (void) resetAdjacentCountries;
- (BOOL) isAdjacentToCountry:(RKCountry *)aCountry;
@property (readonly) BOOL bordersAnotherContinent;

- (void) drawInView:(RiskMapView *)aView isSelected:(BOOL)selected;
- (BOOL) pointInCountry:(NSPoint)aPoint;

@property (readonly, copy) NSString *description;

//----------------------------------------------------------------------
// Army methods
//----------------------------------------------------------------------

@property (nonatomic) RKPlayer playerNumber;
@property (nonatomic) RKArmyCount troopCount;
@property (readonly) RKArmyCount movableTroopCount;

- (void) addTroops:(RKArmyCount)count;

/// We need to keep track of the unmovable troops (the troops that have
/// already been fortified), otherwise under the "fortify many to many
/// neighbors" rule, you could march the armies up to the front one
/// country at a time.
@property (readonly) RKArmyCount unmovableTroopCount;
- (void) addUnmovableTroopCount:(RKArmyCount)count;
- (void) resetUnmovableTroops;

- (void) update;

//======================================================================
// Useful methods:
//======================================================================

@property (readonly, copy) NSSet<RKCountry *> *connectedCountries;
@property (readonly, copy) NSSet<RKCountry *> *ourNeighborCountries;
@property (readonly, copy) NSSet<RKCountry *> *ourConnectedCountries;
@property (readonly, copy) NSSet<RKCountry *> *enemyNeighborCountries;

@property (readonly) RKArmyCount enemyNeighborTroopCount;
@property (readonly) RKArmyCount ourNeighborTroopCount;

//======================================================================
// Useful, somewhat optimized methods:
//======================================================================

@property (readonly) BOOL hasEnemyNeighbors;
@property (readonly) BOOL hasFriendlyNeighborsWithEnemyNeighbors;
@property (readonly) BOOL hasTroops;
@property (readonly) BOOL hasMobileTroops;

- (BOOL) surroundedByPlayerNumber:(RKPlayer)number;
- (BOOL) hasEnemyNeighborsExcludingCountry:(RKCountry *)excludedCountry;

@end

extern NSNotificationName const RKCountryUpdatedNotification;

NS_ASSUME_NONNULL_END
