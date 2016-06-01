//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: Country.m,v 1.2 1997/12/15 07:43:46 nygard Exp $");

#import "Country.h"

#import "CountryShape.h"
#import "RiskMapView.h"

#define Country_VERSION 2

DEFINE_NSSTRING (CountryUpdatedNotification);

@implementation Country
@synthesize countryName = name;
@synthesize countryShape;
@synthesize continentName;
@synthesize playerNumber;
@synthesize troopCount;
@synthesize unmovableTroopCount;

+ (void) initialize
{
    if (self == [Country class])
    {
        [self setVersion:Country_VERSION];
    }
}

//----------------------------------------------------------------------

- (instancetype) initWithCountryName:(NSString *)aName
                       continentName:(NSString *)aContinentName
                               shape:(CountryShape *)aCountryShape
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
            name = [[aDecoder decodeObjectForKey:kCountryName] copy];
            countryShape = [aDecoder decodeObjectForKey:kCountryShape];
            continentName = [[aDecoder decodeObjectForKey:kCountryContinentName] copy];
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

- (NSSet *) neighborCountries
{
    return neighborCountries;
}

//----------------------------------------------------------------------

- (void) setAdjacentToCountry:(Country *)aCountry
{
    [neighborCountries addObject:aCountry];
}

//----------------------------------------------------------------------

- (void) resetAdjacentCountries
{
    [neighborCountries removeAllObjects];
}

//----------------------------------------------------------------------

- (BOOL) isAdjacentToCountry:(Country *)aCountry
{
    return [neighborCountries containsObject:aCountry];
}

//----------------------------------------------------------------------

- (BOOL) bordersAnotherContinent
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;
    
    flag = NO;
    countryEnumerator = [neighborCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
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

- (void) setPlayerNumber:(Player)aPlayerNumber
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
    [[NSNotificationCenter defaultCenter] postNotificationName:CountryUpdatedNotification
                                                        object:self];
}

//======================================================================
// Useful methods:
//======================================================================

- (NSSet *) connectedCountries
{
    NSMutableSet *connectedSet, *greySet, *tmpSet;
    Country *current;
    
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
    NSMutableSet *ourNeighborCountries;
    NSEnumerator *countryEnumerator;
    Country *country;
    
    ourNeighborCountries = [NSMutableSet set];
    countryEnumerator = [self.neighborCountries objectEnumerator];
    
    while (country = [countryEnumerator nextObject])
    {
        if (country.playerNumber == playerNumber)
            [ourNeighborCountries addObject:country];
    }
    
    return ourNeighborCountries;
}

//----------------------------------------------------------------------

- (NSSet *) ourConnectedCountries
{
    NSMutableSet *connectedSet, *greySet, *tmpSet;
    Country *current;
    
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
    NSMutableSet *enemyNeighborCountries;
    NSEnumerator *countryEnumerator;
    Country *country;
    
    enemyNeighborCountries = [NSMutableSet set];
    countryEnumerator = [self.neighborCountries objectEnumerator];
    
    while (country = [countryEnumerator nextObject])
    {
        if (country.playerNumber != playerNumber)
            [enemyNeighborCountries addObject:country];
    }
    
    return enemyNeighborCountries;
}

//----------------------------------------------------------------------

- (int) enemyNeighborTroopCount
{
    NSEnumerator *countryEnumerator;
    Country *country;
    int count;
    
    count = 0;
    countryEnumerator = [[self enemyNeighborCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        count += country.troopCount;
    }
    
    return count;
}

//----------------------------------------------------------------------

- (int) ourNeighborTroopCount
{
    NSEnumerator *countryEnumerator;
    Country *country;
    int count;
    
    count = 0;
    countryEnumerator = [[self ourNeighborCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
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
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;
    
    flag = NO;
    countryEnumerator = [neighborCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country.playerNumber != playerNumber)
        {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

//----------------------------------------------------------------------

- (BOOL) hasFriendlyNeighborsWithEnemyNeighbors
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;
    
    flag = NO;
    countryEnumerator = [[self ourNeighborCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country.hasEnemyNeighbors == YES)
        {
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

- (BOOL) surroundedByPlayerNumber:(Player)number
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;
    
    flag = YES;
    countryEnumerator = [self.neighborCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country.playerNumber != number)
        {
            flag = NO;
            break;
        }
    }
    
    return flag;
}

//----------------------------------------------------------------------

- (BOOL) hasEnemyNeighborsExcludingCountry:(Country *)excludedCountry
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;
    
    flag = NO;
    countryEnumerator = [neighborCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if (country != excludedCountry && country.playerNumber != playerNumber)
        {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

@end
