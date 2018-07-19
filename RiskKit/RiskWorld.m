//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskWorld.m,v 1.3 1997/12/15 07:44:15 nygard Exp $");

#import "RiskWorld.h"

#import "RKCountry.h"
#import "RiskNeighbor.h"
#import "Continent.h"
#import "RiskCard.h"
#import "RKWorldDecoder.h"

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
    
    RKWorldDecoder *decodeDelegate = [RKWorldDecoder new];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSKeyedUnarchiver *keyedUnarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    keyedUnarchive.delegate = decodeDelegate;
    RiskWorld *riskWorld = [keyedUnarchive decodeObject];
    if (!riskWorld) {
        NSUnarchiver *unarchive = [[NSUnarchiver alloc] initForReadingWithData:data];
        [unarchive decodeClassName:@"Country" asClassName:@"RKCountry"];
        riskWorld = [unarchive decodeObject];
    }
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
#define kCardsArrayKey @"Cards2"

#define kCardCountryName @"CountryName"
#define kCardCardType @"CardType"
#define kCardImageName @"ImageName"


#define kCountryNeighborsArrayOldKey @"CountryNeighbors"
#define kCardsArrayOldKey @"Cards"

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:continents forKey:kContinentsKey];
    [aCoder encodeObject:countryNeighbors forKey:kCountryNeighborsArrayKey];
    [aCoder encodeObject:cards forKey:kCardsArrayKey];
}

//----------------------------------------------------------------------

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        allCountries = [[NSMutableSet alloc] init];
        if (aDecoder.allowsKeyedCoding && [aDecoder containsValueForKey:kContinentsKey]) {
            NSMutableArray *tmpCards = [NSMutableArray array];
            
            NSMutableDictionary *countryDictionary;
            continents = [[aDecoder decodeObjectForKey:kContinentsKey] copy];
            
            [self _buildAllCountries];
            
            // Set up country dictionary keyed on name
            countryDictionary = [[NSMutableDictionary alloc] init];
            for (RKCountry *country1 in allCountries)
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
                    RKCountry *country1 = countryDictionary[name1];
                    RKCountry *country2 = countryDictionary[name2];
                    [tmpCountryNeighbors addObject:[RiskNeighbor riskNeighborWithCountries:country1:country2]];
                }
                countryNeighbors = [tmpCountryNeighbors copy];
            }
            
            if ([aDecoder containsValueForKey:kCardsArrayKey]) {
                cards = [[aDecoder decodeObjectForKey:kCardsArrayKey] copy];
            } else {
                NSArray<NSDictionary<NSString*,id>*> *tmptmpCards = [aDecoder decodeObjectForKey:kCardsArrayOldKey];
                for (NSDictionary<NSString*,id> *tmpCard in tmptmpCards) {
                    NSString *name1 = tmpCard[kCardCountryName];
                    RKCountry *country1 = countryDictionary[name1];
                    RKCardType cardType = [tmpCard[kCardCardType] intValue];
                    NSString *imageName = tmpCard[kCardImageName];
                    [tmpCards addObject:[RiskCard riskCardType:cardType withCountry:country1 imageNamed:imageName]];
                }
                
                cards = [tmpCards copy];
            }
        } else {
            int count;
            
            continents = [aDecoder decodeObject];
            
            [self _buildAllCountries];
            
            // Set up country dictionary keyed on name
            NSMutableDictionary *countryDictionary = [[NSMutableDictionary alloc] init];
            for (RKCountry *country1 in allCountries)
            {
                countryDictionary[country1.countryName] = country1;
            }
            
            [aDecoder decodeValueOfObjCType:@encode (int) at:&count];
            NSMutableArray *tmpCountryNeighbors = [[NSMutableArray alloc] initWithCapacity:count];
            for (int l = 0; l < count; l++)
            {
                NSString *name1 = [aDecoder decodeObject];
                NSString *name2 = [aDecoder decodeObject];
                RKCountry *country1 = countryDictionary[name1];
                RKCountry *country2 = countryDictionary[name2];
                [tmpCountryNeighbors addObject:[RiskNeighbor riskNeighborWithCountries:country1:country2]];
            }
            countryNeighbors = [tmpCountryNeighbors copy];
            
            [aDecoder decodeValueOfObjCType:@encode (int) at:&count];
            NSMutableArray *tmpCards = [[NSMutableArray alloc] initWithCapacity:count];
            for (int l = 0; l < count; l++)
            {
                RKCardType cardType;
                NSString *name1 = [aDecoder decodeObject];
                RKCountry *country1 = countryDictionary[name1];
                [aDecoder decodeValueOfObjCType:@encode (RKCardType) at:&cardType];
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
            RKCountry *country1 = neighbor.country1;
            RKCountry *country2 = neighbor.country2;
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
        for (RKCountry *country in allCountries)
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

- (int) continentBonusArmiesForPlayer:(RKPlayer)number
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

- (NSSet *) countriesForPlayer:(RKPlayer)number
{
    return RWcountriesForPlayerNumber (allCountries, number);
}

@end

//======================================================================
// Some utility functions.
//======================================================================

NSSet<RKCountry*> *RWcountriesForPlayerNumber (NSSet *source, RKPlayer number)
{
    NSMutableSet<RKCountry*> *newSet;
    
    newSet = [NSMutableSet set];
    for (RKCountry *country in source)
    {
        if (country.playerNumber == number)
            [newSet addObject:country];
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<RKCountry*> *RWcountriesInContinentNamed (NSSet *source, NSString *continentName)
{
    NSMutableSet<RKCountry*> *newSet;
    
    newSet = [[NSMutableSet alloc] init];
    for (RKCountry *country in source)
    {
        if ([country.continentName isEqualToString:continentName] == YES)
            [newSet addObject:country];
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<RKCountry*> *RWcountriesWithArmies (NSSet *source)
{
    NSMutableSet<RKCountry*> *newSet;
    
    newSet = [[NSMutableSet alloc] init];
    for (RKCountry *country in source)
    {
        if (country.troopCount > 0)
            [newSet addObject:country];
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<RKCountry*> *RWneighborsOfCountries (NSSet<RKCountry*> *source)
{
    NSMutableSet<RKCountry*> *newSet;
    
    newSet = [NSMutableSet set];
    for (RKCountry *country in source)
    {
        [newSet unionSet:country.neighborCountries];
    }
    
    return [newSet copy];
}
