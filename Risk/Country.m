//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: Country.m,v 1.2 1997/12/15 07:43:46 nygard Exp $");

#import "Country.h"

#import "CountryShape.h"
#import "NSObjectExtensions.h"
#import "RiskMapView.h"

#define Country_VERSION 2

DEFINE_NSSTRING (CountryUpdatedNotification);

@implementation Country

+ (void) initialize
{
    if (self == [Country class])
    {
        [self setVersion:Country_VERSION];
    }
}

//----------------------------------------------------------------------

- initWithCountryName:(NSString *)aName
        continentName:(NSString *)aContinentName
                shape:(CountryShape *)aCountryShape
            continent:(RiskContinent)aContinent
{
    if ([super init] == nil)
        return nil;

    name = [aName retain];
    countryShape = [aCountryShape retain];
    continentName = [aContinentName retain];
    neighborCountries = [[NSMutableSet set] retain];;

    playerNumber = 0;
    troopCount = 0;
    unmovableTroopCount = 0;

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (name);
    SNRelease (continentName);
    SNRelease (countryShape);
    SNRelease (neighborCountries);
    
    [super dealloc];
}

//----------------------------------------------------------------------

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:name];
    [aCoder encodeObject:countryShape];
    [aCoder encodeObject:continentName];
    // World will encode neighbors
    [aCoder encodeValueOfObjCType:@encode (int) at:&playerNumber];
    [aCoder encodeValueOfObjCType:@encode (int) at:&troopCount];
    [aCoder encodeValueOfObjCType:@encode (int) at:&unmovableTroopCount];
}

//----------------------------------------------------------------------

- initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    name = [[aDecoder decodeObject] retain];
    countryShape = [[aDecoder decodeObject] retain];
    continentName = [[aDecoder decodeObject] retain];
    neighborCountries = [[NSMutableSet set] retain];;

    [aDecoder decodeValueOfObjCType:@encode (int) at:&playerNumber];
    [aDecoder decodeValueOfObjCType:@encode (int) at:&troopCount];
    [aDecoder decodeValueOfObjCType:@encode (int) at:&unmovableTroopCount];

    return self;
}

//----------------------------------------------------------------------

- (NSString *) countryName
{
    return name;
}

//----------------------------------------------------------------------

- (CountryShape *) countryShape
{
    return countryShape;
}

//----------------------------------------------------------------------

- (NSString *) continentName
{
    return continentName;
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
        if ([[country continentName] isEqualToString:continentName] == NO)
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

- (Player) playerNumber
{
    return playerNumber;
}

//----------------------------------------------------------------------

- (int) troopCount
{
    return troopCount;
}

//----------------------------------------------------------------------

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
    troopCount += count;
    [self update];
#if 0
    if (troopCount < 0)
        troopCount = 0;
#endif
}

//----------------------------------------------------------------------
// We need to keep track of the unmovable troops (the troops that have
// already been fortified), otherwise under the "fortify many to many
// neighbors" rule, you could march the armies up to the front one
// country at a time.
//----------------------------------------------------------------------

- (int) unmovableTroopCount
{
    return unmovableTroopCount;
}

//----------------------------------------------------------------------

- (void) addUnmovableTroopCount:(int)count
{
    unmovableTroopCount += count;
    NSAssert (unmovableTroopCount <= troopCount, @"Too many unmovable troops!");
}

//----------------------------------------------------------------------

- (void) resetUnmovableTroops
{
    unmovableTroopCount = 0;
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

    while (current = [greySet anyObject])
    {
        [greySet removeObject:current];
        [connectedSet addObject:current];

        // Now, add neighbors:
        tmpSet = [NSMutableSet setWithSet:[current neighborCountries]];
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
    countryEnumerator = [[self neighborCountries] objectEnumerator];

    while (country = [countryEnumerator nextObject])
    {
        if ([country playerNumber] == playerNumber)
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

    while (current = [greySet anyObject])
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
    countryEnumerator = [[self neighborCountries] objectEnumerator];

    while (country = [countryEnumerator nextObject])
    {
        if ([country playerNumber] != playerNumber)
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
        count += [country troopCount];
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
        count += [country troopCount];
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
        if ([country playerNumber] != playerNumber)
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
        if ([country hasEnemyNeighbors] == YES)
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
    return [self movableTroopCount] > 0;
}

//----------------------------------------------------------------------

- (BOOL) surroundedByPlayerNumber:(Player)number
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;

    flag = YES;
    countryEnumerator = [[self neighborCountries] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if ([country playerNumber] != number)
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
        if (country != excludedCountry && [country playerNumber] != playerNumber)
        {
            flag = YES;
            break;
        }
    }

    return flag;
}

@end
