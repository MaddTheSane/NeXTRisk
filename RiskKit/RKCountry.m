//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: Country.m,v 1.2 1997/12/15 07:43:46 nygard Exp $");

#import "RKCountry.h"

#import "RKCountryShape.h"
#import "RiskMapView.h"

#define Country_VERSION 2

NSString *const RKCountryUpdatedNotification = @ "CountryUpdatedNotification";

@implementation RKCountry
@synthesize countryName = name;
@synthesize countryShape;
@synthesize continentName;
@synthesize playerNumber;
@synthesize troopCount;
@synthesize unmovableTroopCount;

+ (void) initialize
{
    if (self == [RKCountry class])
    {
        [self setVersion:Country_VERSION];
    }
}

//----------------------------------------------------------------------

- (instancetype) initWithCountryName:(NSString *)aName
                       continentName:(NSString *)aContinentName
                               shape:(RKCountryShape *)aCountryShape
                           continent:(RiskContinent)aContinent
{
    if (self = [super init]) {
        name = [aName copy];
        countryShape = aCountryShape;
        continentName = [aContinentName copy];
        neighborCountries = [[NSMutableSet alloc] init];
        
        playerNumber = 0;
        troopCount = 0;
        unmovableTroopCount = 0;
    }
    
    return self;
}


//----------------------------------------------------------------------

#define kCountryName @"Name"
#define kCountryShape @"CountryShape"
#define kCountryContinentName @"ContinentName"
#define kCountryPlayerNumber @"PlayerNumber"
#define kCountryTroopCount @"TroopCount"
#define kCountryUnmovableTroopCount @"UnmovableTroopCount"

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name forKey:kCountryName];
    [aCoder encodeObject:countryShape forKey:kCountryShape];
    [aCoder encodeObject:continentName forKey:kCountryContinentName];
    // World will encode neighbors
    [aCoder encodeInteger:playerNumber forKey:kCountryPlayerNumber];
    [aCoder encodeInt:troopCount forKey:kCountryTroopCount];
    [aCoder encodeInt:unmovableTroopCount forKey:kCountryUnmovableTroopCount];
}

//----------------------------------------------------------------------

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        if (aDecoder.allowsKeyedCoding && [aDecoder containsValueForKey:kCountryName]) {
            name = [[aDecoder decodeObjectOfClass:[NSString class] forKey:kCountryName] copy];
            countryShape = [aDecoder decodeObjectOfClass:[RKCountryShape class] forKey:kCountryShape];
            continentName = [[aDecoder decodeObjectOfClass:[NSString class] forKey:kCountryContinentName] copy];
            playerNumber = [aDecoder decodeIntegerForKey:kCountryPlayerNumber];
            troopCount = [aDecoder decodeIntForKey:kCountryTroopCount];
            unmovableTroopCount = [aDecoder decodeIntForKey:kCountryUnmovableTroopCount];
        } else {
            name = [[aDecoder decodeObject] copy];
            countryShape = [aDecoder decodeObject];
            continentName = [[aDecoder decodeObject] copy];
            
            int aTmp = 0;
            [aDecoder decodeValueOfObjCType:@encode (int) at:&aTmp];
            playerNumber = aTmp;
            [aDecoder decodeValueOfObjCType:@encode (int) at:&troopCount];
            [aDecoder decodeValueOfObjCType:@encode (int) at:&unmovableTroopCount];
        }
        // World has encoded neighbors
        neighborCountries = [[NSMutableSet alloc] init];
    }
    
    return self;
}

//----------------------------------------------------------------------

+ (BOOL)supportsSecureCoding
{
    return YES;
}

//----------------------------------------------------------------------

- (NSSet *) neighborCountries
{
    return [neighborCountries copy];
}

//----------------------------------------------------------------------

- (void) setAdjacentToCountry:(RKCountry *)aCountry
{
    [neighborCountries addObject:aCountry];
}

//----------------------------------------------------------------------

- (void) resetAdjacentCountries
{
    [neighborCountries removeAllObjects];
}

//----------------------------------------------------------------------

- (BOOL) isAdjacentToCountry:(RKCountry *)aCountry
{
    return [neighborCountries containsObject:aCountry];
}

//----------------------------------------------------------------------

- (BOOL) bordersAnotherContinent
{
    BOOL flag = NO;
    
    for (RKCountry *country in neighborCountries)
    {
        if ([country.continentName isEqualToString:continentName] == NO)
        {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

//----------------------------------------------------------------------

- (void) drawInView:(RiskMapView *)aView isSelected:(BOOL)selected
{
    if (countryShape != nil)
    {
        [countryShape drawWithCountry:self inView:aView isSelected:selected];
    }
}

//----------------------------------------------------------------------

- (BOOL) pointInCountry:(NSPoint)aPoint
{
    return [countryShape pointInShape:aPoint];
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@", name];
}

//----------------------------------------------------------------------
// Army methods
//----------------------------------------------------------------------

+ (NSSet *)keyPathsForValuesAffectingMovableTroopCount
{
    return [NSSet setWithObjects:@"troopCount", @"unmovableTroopCount", nil];
}

- (int) movableTroopCount
{
    return troopCount - unmovableTroopCount;
}

//----------------------------------------------------------------------

- (void) setPlayerNumber:(RKPlayer)aPlayerNumber
{
    playerNumber = aPlayerNumber;
    
    // These need to be reset when a country is captured.
    troopCount = 0;
    unmovableTroopCount = 0;
    
    [self update];
}

//----------------------------------------------------------------------

- (void) setTroopCount:(int)count
{
    troopCount = count;
    [self update];
#if 0
    if (troopCount < 0)
        troopCount = 0;
#endif
}

//----------------------------------------------------------------------

- (void) addTroops:(int)count
{
    [self willChangeValueForKey:@"troopCount"];
    troopCount += count;
    [self didChangeValueForKey:@"troopCount"];
    [self update];
#if 0
    if (troopCount < 0)
        troopCount = 0;
#endif
}

//----------------------------------------------------------------------

- (void) addUnmovableTroopCount:(int)count
{
    [self willChangeValueForKey:@"unmovableTroopCount"];
    unmovableTroopCount += count;
    [self didChangeValueForKey:@"unmovableTroopCount"];
    NSAssert (unmovableTroopCount <= troopCount, @"Too many unmovable troops!");
}

//----------------------------------------------------------------------

- (void) resetUnmovableTroops
{
    [self willChangeValueForKey:@"unmovableTroopCount"];
    unmovableTroopCount = 0;
    [self didChangeValueForKey:@"unmovableTroopCount"];
}

//----------------------------------------------------------------------

- (void) update
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RKCountryUpdatedNotification
                                                        object:self];
}

//======================================================================
// Useful methods:
//======================================================================

- (NSSet *) connectedCountries
{
    NSMutableSet *connectedSet, *greySet, *tmpSet;
    RKCountry *current;
    
    connectedSet = [NSMutableSet set];
    greySet = [NSMutableSet setWithObject:self];
    
    while ((current = [greySet anyObject]))
    {
        [greySet removeObject:current];
        [connectedSet addObject:current];
        
        // Now, add neighbors:
        tmpSet = [NSMutableSet setWithSet:current.neighborCountries];
        [tmpSet minusSet:connectedSet];
        [greySet unionSet:tmpSet];
    }
    
    return connectedSet;
}

//----------------------------------------------------------------------

- (NSSet *) ourNeighborCountries
{
    NSMutableSet *ourNeighborCountries = [NSMutableSet set];
    
    for (RKCountry *country in self.neighborCountries) {
        if (country.playerNumber == playerNumber) {
            [ourNeighborCountries addObject:country];
        }
    }
    
    return ourNeighborCountries;
}

//----------------------------------------------------------------------

- (NSSet *) ourConnectedCountries
{
    NSMutableSet *connectedSet, *greySet, *tmpSet;
    RKCountry *current;
    
    connectedSet = [NSMutableSet set];
    greySet = [NSMutableSet setWithObject:self];
    
    while ((current = [greySet anyObject]))
    {
        [greySet removeObject:current];
        [connectedSet addObject:current];
        
        // Now, add neighbors:
        tmpSet = [NSMutableSet setWithSet:[current ourNeighborCountries]];
        [tmpSet minusSet:connectedSet];
        [greySet unionSet:tmpSet];
    }
    
    return connectedSet;
}

//----------------------------------------------------------------------

- (NSSet *) enemyNeighborCountries
{
    NSMutableSet *enemyNeighborCountries = [NSMutableSet set];
    
    for (RKCountry *country in self.neighborCountries) {
        if (country.playerNumber != playerNumber) {
            [enemyNeighborCountries addObject:country];
        }
    }
    
    return enemyNeighborCountries;
}

//----------------------------------------------------------------------

- (int) enemyNeighborTroopCount
{
    int count = 0;
    
    for (RKCountry *country in [self enemyNeighborCountries])
    {
        count += country.troopCount;
    }
    
    return count;
}

//----------------------------------------------------------------------

- (int) ourNeighborTroopCount
{
    int count = 0;
    
    for (RKCountry *country in [self ourNeighborCountries])
    {
        count += country.troopCount;
    }
    
    return count;
}

//======================================================================
// Useful, somewhat optimized methods:
//======================================================================

- (BOOL) hasEnemyNeighbors
{
    BOOL flag = NO;
    
    for (RKCountry *country in neighborCountries) {
        if (country.playerNumber != playerNumber) {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

//----------------------------------------------------------------------

- (BOOL) hasFriendlyNeighborsWithEnemyNeighbors
{
    BOOL flag = NO;
    
    for (RKCountry *country in [self ourNeighborCountries]) {
        if (country.hasEnemyNeighbors == YES) {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

//----------------------------------------------------------------------

- (BOOL) hasTroops
{
    return troopCount > 0;
}

//----------------------------------------------------------------------

- (BOOL) hasMobileTroops
{
    return self.movableTroopCount > 0;
}

//----------------------------------------------------------------------

- (BOOL) surroundedByPlayerNumber:(RKPlayer)number
{
    BOOL flag = YES;
    
    for (RKCountry *country in self.neighborCountries) {
        if (country.playerNumber != number) {
            flag = NO;
            break;
        }
    }
    
    return flag;
}

//----------------------------------------------------------------------

- (BOOL) hasEnemyNeighborsExcludingCountry:(RKCountry *)excludedCountry
{
    BOOL flag = NO;
    
    for (RKCountry *country in neighborCountries) {
        if (country != excludedCountry && country.playerNumber != playerNumber) {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

@end
