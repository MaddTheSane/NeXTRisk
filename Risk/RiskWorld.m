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
@synthesize cards;

+ (void) initialize
{
    if (self == [RiskWorld class])
    {
        [self setVersion:RiskWorld_VERSION];
    }
}

//----------------------------------------------------------------------

+ (RiskWorld*)defaultRiskWorld
{
    // Load default countries/shapes...
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSAssert (thisBundle != nil, @"Could not get this bundle.");
    
    NSString *path = [thisBundle pathForResource:RISKWORLD_DATAFILE ofType:@"data"];
    NSAssert (path != nil, @"Could not get path to data file.");
    
    RiskWorld *riskWorld = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!riskWorld)
        riskWorld = [NSUnarchiver unarchiveObjectWithFile:path];
    //NSLog (@"default risk world: %@", riskWorld);
    
    return riskWorld;
}

//----------------------------------------------------------------------

+ (instancetype)riskWorldWithContinents:(NSDictionary *)theContinents countryNeighbors:(NSArray *)neighbors cards:(NSArray *)theCards
{
    return [[RiskWorld alloc] initWithContinents:theContinents countryNeighbors:neighbors cards:theCards];
}

//----------------------------------------------------------------------

- (instancetype)initWithContinents:(NSDictionary *)theContinents countryNeighbors:(NSArray *)neighbors cards:(NSArray *)theCards
{
    if (self = [super init]) {
        allCountries = [[NSMutableSet alloc] init];
        countryNeighbors = neighbors;
        continents = theContinents;
        cards = theCards;
        
        [self _buildAllCountries];
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [self _disconnectCountries];
}

//----------------------------------------------------------------------

#define kContinentsKey @"Continents"
#define kCountryNeighborsArrayKey @"CountryNeighbors2"
#define kCountryNeighborsArrayOldKey @"CountryNeighbors"
#define kCardsArrayKey @"Cards"

#define kCardCountryName @"CountryName"
#define kCardCardType @"CardType"
#define kCardImageName @"ImageName"

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    RiskCard *card;
    
    [aCoder encodeObject:continents forKey:kContinentsKey];
    [aCoder encodeObject:countryNeighbors forKey:kCountryNeighborsArrayKey];
    
    NSMutableArray<NSDictionary<NSString*,id>*> *tmpCards = [NSMutableArray arrayWithCapacity:cards.count];
    for (card in cards) {
        NSDictionary *cardDict = @{
                                   kCardCardType: @(card.cardType),
                                   kCardImageName: card.imageName
                                   };
        
        if (card.country.countryName) {
            NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:cardDict];
            mdict[kCardCountryName] = card.country.countryName;
            cardDict = mdict;
        }
        
        [tmpCards addObject:cardDict];
    }
    [aCoder encodeObject:tmpCards forKey:kCardsArrayKey];
}

//----------------------------------------------------------------------

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        allCountries = [[NSMutableSet alloc] init];
        if (aDecoder.allowsKeyedCoding && [aDecoder containsValueForKey:kContinentsKey]) {
            NSMutableArray *tmpCards = [NSMutableArray array];
            RiskCardType cardType;
            
            NSMutableDictionary *countryDictionary;
            continents = [[aDecoder decodeObjectForKey:kContinentsKey] copy];
            
            [self _buildAllCountries];
            
            // Set up country dictionary keyed on name
            countryDictionary = [[NSMutableDictionary alloc] init];
            for (Country *country1 in allCountries)
            {
                countryDictionary[country1.countryName] = country1;
            }
            
            if ([aDecoder containsValueForKey:kCountryNeighborsArrayKey]) {
                countryNeighbors = [[aDecoder decodeObjectForKey:kCountryNeighborsArrayKey] copy];
            } else {
            NSArray *tmptmp = [aDecoder decodeObjectForKey:kCountryNeighborsArrayOldKey];
            
            NSMutableArray *tmpCountryNeighbors = [[NSMutableArray alloc] init];
            for (NSArray<NSString*> *conCat in tmptmp) {
                NSString *name1 = conCat[0];
                NSString *name2 = conCat[1];
                Country *country1 = countryDictionary[name1];
                Country *country2 = countryDictionary[name2];
                [tmpCountryNeighbors addObject:[RiskNeighbor riskNeighborWithCountries:country1:country2]];
            }
            countryNeighbors = [tmpCountryNeighbors copy];
            }
            NSArray<NSDictionary<NSString*,id>*> *tmptmpCards = [aDecoder decodeObjectForKey:kCardsArrayKey];
            
            for (NSDictionary<NSString*,id> *tmpCard in tmptmpCards) {
                NSString *name1 = tmpCard[kCardCountryName];
                Country *country1 = countryDictionary[name1];
                cardType = [tmpCard[kCardCardType] intValue];
                NSString *imageName = tmpCard[kCardImageName];
                [tmpCards addObject:[RiskCard riskCardType:cardType withCountry:country1 imageNamed:imageName]];
            }
            
            cards = [tmpCards copy];
        } else {
            int count;
            
            continents = [aDecoder decodeObject];
            
            [self _buildAllCountries];
            
            // Set up country dictionary keyed on name
            NSMutableDictionary *countryDictionary = [[NSMutableDictionary alloc] init];
            for (Country *country1 in allCountries)
            {
                countryDictionary[country1.countryName] = country1;
            }
            
            [aDecoder decodeValueOfObjCType:@encode (int) at:&count];
            NSMutableArray *tmpCountryNeighbors = [[NSMutableArray alloc] initWithCapacity:count];
            for (int l = 0; l < count; l++)
            {
                NSString *name1 = [aDecoder decodeObject];
                NSString *name2 = [aDecoder decodeObject];
                Country *country1 = countryDictionary[name1];
                Country *country2 = countryDictionary[name2];
                [tmpCountryNeighbors addObject:[RiskNeighbor riskNeighborWithCountries:country1:country2]];
            }
            countryNeighbors = [tmpCountryNeighbors copy];
            
            [aDecoder decodeValueOfObjCType:@encode (int) at:&count];
            NSMutableArray *tmpCards = [[NSMutableArray alloc] initWithCapacity:count];
            for (int l = 0; l < count; l++)
            {
                RiskCardType cardType;
                NSString *name1 = [aDecoder decodeObject];
                Country *country1 = countryDictionary[name1];
                [aDecoder decodeValueOfObjCType:@encode (RiskCardType) at:&cardType];
                NSString *imageName = [aDecoder decodeObject];
                [tmpCards addObject:[RiskCard riskCardType:cardType withCountry:country1 imageNamed:imageName]];
            }
            
            cards = [tmpCards copy];
        }
        [self _connectCountries];
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) _buildAllCountries
{
    [allCountries removeAllObjects];
    
    for (Continent *continent in [continents allValues])
    {
        [allCountries unionSet:continent.countries];
    }
}

//----------------------------------------------------------------------

- (void) _connectCountries
{
    if (countryNeighbors != nil)
    {
        for (RiskNeighbor *neighbor in countryNeighbors)
        {
            Country *country1 = neighbor.country1;
            Country *country2 = neighbor.country2;
            [country1 setAdjacentToCountry:country2];
            [country2 setAdjacentToCountry:country1];
        }
    }
}

//----------------------------------------------------------------------

// Remove adjacency dependencies.
- (void) _disconnectCountries
{
    if (allCountries != nil)
    {
        for (Country *country in allCountries)
        {
            [country resetAdjacentCountries];
        }
    }
}

//----------------------------------------------------------------------

- (NSSet *) allCountries
{
    return [allCountries copy];
}

//----------------------------------------------------------------------

- (Continent *) continentNamed:(NSString *)continentName
{
    return continents[continentName];
}

//----------------------------------------------------------------------
// Calculate the number of bonus armies earned for a player at the
// beginning of a turn based on the continents that they completely
// occupy.
//----------------------------------------------------------------------

- (int) continentBonusArmiesForPlayer:(Player)number
{
    NSEnumerator *continentEnumerator;
    int bonus = 0;
    
    continentEnumerator = [continents objectEnumerator];
    for (Continent *continent in continentEnumerator)
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

NSSet<Country*> *RWcountriesForPlayerNumber (NSSet *source, Player number)
{
    NSMutableSet<Country*> *newSet;
    
    newSet = [NSMutableSet set];
    for (Country *country in source)
    {
        if (country.playerNumber == number)
            [newSet addObject:country];
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<Country*> *RWcountriesInContinentNamed (NSSet *source, NSString *continentName)
{
    NSMutableSet<Country*> *newSet;
    
    newSet = [[NSMutableSet alloc] init];
    for (Country *country in source)
    {
        if ([country.continentName isEqualToString:continentName] == YES)
            [newSet addObject:country];
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<Country*> *RWcountriesWithArmies (NSSet *source)
{
    NSMutableSet<Country*> *newSet;
    
    newSet = [[NSMutableSet alloc] init];
    for (Country *country in source)
    {
        if (country.troopCount > 0)
            [newSet addObject:country];
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<Country*> *RWneighborsOfCountries (NSSet<Country*> *source)
{
    NSMutableSet<Country*> *newSet;
    
    newSet = [NSMutableSet set];
    for (Country *country in source)
    {
        [newSet unionSet:country.neighborCountries];
    }
    
    return [newSet copy];
}
