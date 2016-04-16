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
    int troopCount;
    int unmovableTroopCount;
}

+ (void) initialize;

- (instancetype)initWithCountryName:(NSString *)aName
        continentName:(NSString *)aContinentName
                shape:(CountryShape *)aCountryShape
            continent:(RiskContinent)aContinent;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@property (readonly, copy) NSString *countryName;
@property (readonly, retain) CountryShape *countryShape;
@property (readonly, copy) NSString *continentName;
@property (readonly) NSSet<Country*> *neighborCountries;

- (void) setAdjacentToCountry:(Country *)aCountry;
- (void) resetAdjacentCountries;
- (BOOL) isAdjacentToCountry:(Country *)aCountry;
- (BOOL) bordersAnotherContinent;

- (void) drawInView:(RiskMapView *)aView isSelected:(BOOL)selected;
- (BOOL) pointInCountry:(NSPoint)aPoint;

- (NSString *) description;

//----------------------------------------------------------------------
// Army methods
//----------------------------------------------------------------------

@property (nonatomic) Player playerNumber;
@property (nonatomic) int troopCount;
@property (readonly) int movableTroopCount;

- (void) addTroops:(int)count;

/// We need to keep track of the unmovable troops (the troops that have
/// already been fortified), otherwise under the "fortify many to many
/// neighbors" rule, you could march the armies up to the front one
/// country at a time.
@property (readonly) int unmovableTroopCount;
- (void) addUnmovableTroopCount:(int)count;
- (void) resetUnmovableTroops;

- (void) update;

//======================================================================
// Useful methods:
//======================================================================

- (NSSet<Country*> *) connectedCountries;
- (NSSet<Country*> *) ourNeighborCountries;
- (NSSet<Country*> *) ourConnectedCountries;
- (NSSet<Country*> *) enemyNeighborCountries;

@property (readonly) int enemyNeighborTroopCount;
@property (readonly) int ourNeighborTroopCount;

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
