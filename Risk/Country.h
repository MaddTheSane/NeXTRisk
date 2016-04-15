//
// $Id: Country.h,v 1.2 1997/12/15 07:43:44 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class CountryShape, RiskMapView;

@interface Country : NSObject
{
    NSString *name;
    CountryShape *countryShape;
    NSString *continentName;
    NSMutableSet *neighborCountries;

    // The occupying army:
    Player playerNumber;
    int troopCount;
    int unmovableTroopCount;
}

+ (void) initialize;

- initWithCountryName:(NSString *)aName
        continentName:(NSString *)aContinentName
                shape:(CountryShape *)aCountryShape
            continent:(RiskContinent)aContinent;
- (void) dealloc;

- (void) encodeWithCoder:(NSCoder *)aCoder;
- initWithCoder:(NSCoder *)aDecoder;

- (NSString *) countryName;
- (CountryShape *) countryShape;
- (NSString *) continentName;
- (NSSet *) neighborCountries;

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

- (Player) playerNumber;
- (int) troopCount;
- (int) movableTroopCount;

- (void) setPlayerNumber:(Player)aPlayerNumber;
- (void) setTroopCount:(int)count;

- (void) addTroops:(int)count;

- (int) unmovableTroopCount;
- (void) addUnmovableTroopCount:(int)count;
- (void) resetUnmovableTroops;

- (void) update;

//======================================================================
// Useful methods:
//======================================================================

- (NSSet *) connectedCountries;
- (NSSet *) ourNeighborCountries;
- (NSSet *) ourConnectedCountries;
- (NSSet *) enemyNeighborCountries;

- (int) enemyNeighborTroopCount;
- (int) ourNeighborTroopCount;

//======================================================================
// Useful, somewhat optimized methods:
//======================================================================

- (BOOL) hasEnemyNeighbors;
- (BOOL) hasFriendlyNeighborsWithEnemyNeighbors;
- (BOOL) hasTroops;
- (BOOL) hasMobileTroops;

- (BOOL) surroundedByPlayerNumber:(Player)number;
- (BOOL) hasEnemyNeighborsExcludingCountry:(Country *)excludedCountry;

@end

extern NSString *CountryUpdatedNotification;
