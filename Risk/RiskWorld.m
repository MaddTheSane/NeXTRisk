//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskWorld.m,v 1.3 1997/12/15 07:44:15 nygard Exp $");

#import "RiskWorld.h"

#import "Country.h"
#import "RiskNeighbor.h"
#import "Continent.h"
#import "RiskCard.h"

//======================================================================
// A RiskWorld has a name, continents with countries, and neighboring
// country data.
//
// If multiple RiskWorlds are allowed, each world could be a bundle
// that has the images for each card, as well as the encoded data for
// the world and the RiskMapView background image.
//======================================================================

#define RISKWORLD_DATAFILE @"RiskWorld"
#define RiskWorld_VERSION 1

@implementation RiskWorld
@synthesize continents;

+ (void) initialize
{
    if (self == [RiskWorld class])
    {
        [self setVersion:RiskWorld_VERSION];
    }
}

//----------------------------------------------------------------------

+ defaultRiskWorld
{
    NSBundle *thisBundle;
    NSString *path;
    RiskWorld *riskWorld;

    // Load default countries/shapes...

    thisBundle = [NSBundle bundleForClass:[self class]];
    NSAssert (thisBundle != nil, @"Could not get this bundle.");

    path = [thisBundle pathForResource:RISKWORLD_DATAFILE ofType:@"data"];
    NSAssert (path != nil, @"Could not get path to data file.");

    riskWorld = [NSUnarchiver unarchiveObjectWithFile:path];
    //NSLog (@"default risk world: %@", riskWorld);

    return riskWorld;
}

//----------------------------------------------------------------------

+ riskWorldWithContinents:(NSDictionary *)theContinents countryNeighbors:(NSArray *)neighbors cards:(NSArray *)theCards
{
    return [[[RiskWorld alloc] initWithContinents:theContinents countryNeighbors:neighbors cards:theCards] autorelease];
}

//----------------------------------------------------------------------

- initWithContinents:(NSDictionary *)theContinents countryNeighbors:(NSArray *)neighbors cards:(NSArray *)theCards
{
    if ([super init] == nil)
        return nil;

    allCountries = [[NSMutableSet set] retain];
    countryNeighbors = [neighbors retain];
    continents = [theContinents retain];
    cards = [theCards retain];

    [self _buildAllCountries];

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [self _disconnectCountries];

    SNRelease (allCountries);
    SNRelease (countryNeighbors);
    SNRelease (continents);
    SNRelease (cards);

    [super dealloc];
}

//----------------------------------------------------------------------

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    NSEnumerator *neighborEnumerator;
    RiskNeighbor *riskNeighbor;
    NSEnumerator *cardEnumerator;
    RiskCard *card;
    NSInteger count;
    RiskCardType cardType;
    
    [aCoder encodeObject:continents];
    
    count = [countryNeighbors count];
    [aCoder encodeValueOfObjCType:@encode (NSInteger) at:&count];

    neighborEnumerator = [countryNeighbors objectEnumerator];
    while (riskNeighbor = [neighborEnumerator nextObject])
    {
        [aCoder encodeObject:[[riskNeighbor country1] countryName]];
        [aCoder encodeObject:[[riskNeighbor country2] countryName]];
    }

    count = [cards count];
    [aCoder encodeValueOfObjCType:@encode (NSInteger) at:&count];

    cardEnumerator = [cards objectEnumerator];
    for (card in cards)
    {
        [aCoder encodeObject:[[card country] countryName]];
        cardType = [card cardType];
        [aCoder encodeValueOfObjCType:@encode (RiskCardType) at:&cardType];
        [aCoder encodeObject:[card imageName]];
    }
}

//----------------------------------------------------------------------

- initWithCoder:(NSCoder *)aDecoder
{
    NSMutableDictionary *countryDictionary;
    NSEnumerator *countryEnumerator;
    Country *country1, *country2;
    NSString *name1, *name2;
    int l, count;
    NSMutableArray *tmpCountryNeighbors;

    NSMutableArray *tmpCards;
    RiskCardType cardType;
    NSString *imageName;
    
    if ([super init] == nil)
        return nil;

    continents = [[aDecoder decodeObject] retain];

    allCountries = [[NSMutableSet set] retain];
    [self _buildAllCountries];

    // Set up country dictionary keyed on name
    countryDictionary = [NSMutableDictionary dictionary];
    countryEnumerator = [allCountries objectEnumerator];
    while (country1 = [countryEnumerator nextObject])
    {
        [countryDictionary setObject:country1 forKey:[country1 countryName]];
    }

    tmpCountryNeighbors = [NSMutableArray array];
    [aDecoder decodeValueOfObjCType:@encode (int) at:&count];
    for (l = 0; l < count; l++)
    {
        name1 = [aDecoder decodeObject];
        name2 = [aDecoder decodeObject];
        country1 = [countryDictionary objectForKey:name1];
        country2 = [countryDictionary objectForKey:name2];
        [tmpCountryNeighbors addObject:[RiskNeighbor riskNeighborWithCountries:country1:country2]];
    }
    countryNeighbors = [tmpCountryNeighbors retain];

    tmpCards = [NSMutableArray array];
    [aDecoder decodeValueOfObjCType:@encode (int) at:&count];
    for (l = 0; l < count; l++)
    {
        name1 = [aDecoder decodeObject];
        country1 = [countryDictionary objectForKey:name1];
        [aDecoder decodeValueOfObjCType:@encode (RiskCardType) at:&cardType];
        imageName = [aDecoder decodeObject];
        [tmpCards addObject:[RiskCard riskCardType:cardType withCountry:country1 imageNamed:imageName]];
    }

    cards = [[NSArray alloc] initWithArray:tmpCards];

    [self _connectCountries];

    return self;
}

//----------------------------------------------------------------------

- (void) _buildAllCountries
{
    NSEnumerator *continentEnumerator;
    Continent *continent;

    [allCountries removeAllObjects];

    continentEnumerator = [continents objectEnumerator];
    while (continent = [continentEnumerator nextObject])
    {
        [allCountries unionSet:[continent countries]];
    }
}

//----------------------------------------------------------------------

- (void) _connectCountries
{
    NSEnumerator *neighborEnumerator;
    RiskNeighbor *neighbor;
    Country *country1, *country2;

    if (countryNeighbors != nil)
    {
        neighborEnumerator = [countryNeighbors objectEnumerator];
        while (neighbor = [neighborEnumerator nextObject])
        {
            country1 = [neighbor country1];
            country2 = [neighbor country2];
            [country1 setAdjacentToCountry:country2];
            [country2 setAdjacentToCountry:country1];
        }
    }
}

//----------------------------------------------------------------------

// Remove adjacency dependencies.
- (void) _disconnectCountries
{
    NSEnumerator *countryEnumerator;
    Country *country;

    if (allCountries != nil)
    {
        countryEnumerator = [allCountries objectEnumerator];
        while (country = [countryEnumerator nextObject])
        {
            [country resetAdjacentCountries];
        }
    }
}

//----------------------------------------------------------------------

- (NSSet *) allCountries
{
    return allCountries;
}

//----------------------------------------------------------------------

- (Continent *) continentNamed:(NSString *)continentName
{
    return [continents objectForKey:continentName];
}

//----------------------------------------------------------------------

- (NSArray *) cards
{
    return cards;
}

//----------------------------------------------------------------------
// Calculate the number of bonus armies earned for a player at the
// beginning of a turn based on the continents that they completely
// occupy.
//----------------------------------------------------------------------

- (int) continentBonusArmiesForPlayer:(Player)number
{
    NSEnumerator *continentEnumerator;
    Continent *continent;
    int bonus = 0;

    continentEnumerator = [continents objectEnumerator];
    for (continent in continentEnumerator)
    {
        bonus += [continent bonusArmiesForPlayer:number];
    }

    return bonus;
}

//----------------------------------------------------------------------

- (NSSet *) countriesForPlayer:(Player)number
{
    return RWcountriesForPlayerNumber (allCountries, number);
}

@end

//======================================================================
// Some utility functions.
//======================================================================

NSSet *RWcountriesForPlayerNumber (NSSet *source, Player number)
{
    NSMutableSet *newSet;

    newSet = [NSMutableSet set];
    for (Country *country in source)
    {
        if ([country playerNumber] == number)
            [newSet addObject:country];
    }

    return newSet;
}

//----------------------------------------------------------------------

NSSet *RWcountriesInContinentNamed (NSSet *source, NSString *continentName)
{
    NSMutableSet *newSet;

    newSet = [NSMutableSet set];
    for (Country *country in source)
    {
        if ([[country continentName] isEqualToString:continentName] == YES)
            [newSet addObject:country];
    }

    return newSet;
}

//----------------------------------------------------------------------

NSSet *RWcountriesWithArmies (NSSet *source)
{
    NSMutableSet *newSet;

    newSet = [NSMutableSet set];
    for (Country *country in source)
    {
        if ([country troopCount] > 0)
            [newSet addObject:country];
    }

    return newSet;
}

//----------------------------------------------------------------------

NSSet *RWneighborsOfCountries (NSSet<Country*> *source)
{
    NSMutableSet *newSet;

    newSet = [NSMutableSet set];
    for (Country *country in source)
    {
        [newSet unionSet:[country neighborCountries]];
    }

    return newSet;
}
