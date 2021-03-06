//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: RiskWorld.m,v 1.3 1997/12/15 07:44:15 nygard Exp $");

#import "RiskWorld.h"

#import "RKCountry.h"
#import "RKNeighbor.h"
#import "RKContinent.h"
#import "RKCard.h"
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
    
    NSURL *path = [thisBundle URLForResource:RISKWORLD_DATAFILE withExtension:@"data"];
    NSAssert (path != nil, @"Could not get path to data file.");
    
    RKWorldDecoder *decodeDelegate = [RKWorldDecoder new];
    
    NSData *data = [NSData dataWithContentsOfURL:path];
    NSKeyedUnarchiver *keyedUnarchive;
    if (@available(macOS 10.13, *)) {
        NSError *err;
        keyedUnarchive = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&err];
        if (err) {
            NSLog(@"%@", err);
        }
    } else {
        keyedUnarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    }
    keyedUnarchive.delegate = decodeDelegate;
    RiskWorld *riskWorld = [keyedUnarchive decodeObjectOfClass:[RiskWorld class] forKey:NSKeyedArchiveRootObjectKey];
    if (keyedUnarchive.error) {
        NSLog(@"%@", keyedUnarchive.error);
    }
    if (!riskWorld) {
        NSUnarchiver *unarchive = [[NSUnarchiver alloc] initForReadingWithData:data];
        [unarchive decodeClassName:@"Country" asClassName:@"RKCountry"];
        [unarchive decodeClassName:@"Continent" asClassName:@"RKContinent"];
        [unarchive decodeClassName:@"CountryShape" asClassName:@"RKCountryShape"];
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
            
            NSMutableDictionary *countryDictionary = [[NSMutableDictionary alloc] init];
            continents = [[aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSDictionary class], [NSString class], [RKContinent class], nil] forKey:kContinentsKey] copy];
            
            [self _buildAllCountries];
            
            // Set up country dictionary keyed on name
            for (RKCountry *country1 in allCountries)
            {
                countryDictionary[country1.countryName] = country1;
            }
            
            if ([aDecoder containsValueForKey:kCountryNeighborsArrayKey]) {
                countryNeighbors = [[aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [RKNeighbor class], nil] forKey:kCountryNeighborsArrayKey] copy];
            } else {
                NSArray *tmptmp = [aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [NSString class], nil] forKey:kCountryNeighborsArrayOldKey];
                
                NSMutableArray *tmpCountryNeighbors = [[NSMutableArray alloc] init];
                for (NSArray<NSString*> *conCat in tmptmp) {
                    NSString *name1 = conCat[0];
                    NSString *name2 = conCat[1];
                    RKCountry *country1 = countryDictionary[name1];
                    RKCountry *country2 = countryDictionary[name2];
                    [tmpCountryNeighbors addObject:[RKNeighbor riskNeighborWithCountries:country1:country2]];
                }
                countryNeighbors = [tmpCountryNeighbors copy];
            }
            
            if ([aDecoder containsValueForKey:kCardsArrayKey]) {
                cards = [[aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [RKCard class], nil]  forKey:kCardsArrayKey] copy];
            } else {
                NSArray<NSDictionary<NSString*,id>*> *tmptmpCards = [aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [NSDictionary class], [NSString class], [RKCountry class], [NSNumber class], nil]  forKey:kCardsArrayOldKey];
                for (NSDictionary<NSString*,id> *tmpCard in tmptmpCards) {
                    NSString *name1 = tmpCard[kCardCountryName];
                    RKCountry *country1 = countryDictionary[name1];
                    RKCardType cardType = [tmpCard[kCardCardType] intValue];
                    NSString *imageName = tmpCard[kCardImageName];
                    [tmpCards addObject:[RKCard riskCardType:cardType withCountry:country1 imageNamed:imageName]];
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
                [tmpCountryNeighbors addObject:[RKNeighbor riskNeighborWithCountries:country1:country2]];
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
                [tmpCards addObject:[RKCard riskCardType:cardType withCountry:country1 imageNamed:imageName]];
            }
            
            cards = [tmpCards copy];
        }
        [self _connectCountries];
    }
    
    return self;
}

//----------------------------------------------------------------------

+ (BOOL)supportsSecureCoding
{
    return YES;
}

//----------------------------------------------------------------------

- (void) _buildAllCountries
{
    [allCountries removeAllObjects];
    
    for (RKContinent *continent in [continents allValues])
    {
        [allCountries unionSet:continent.countries];
    }
}

//----------------------------------------------------------------------

- (void) _connectCountries
{
    if (countryNeighbors != nil)
    {
        for (RKNeighbor *neighbor in countryNeighbors)
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

- (RKContinent *) continentNamed:(NSString *)continentName
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
    for (RKContinent *continent in continentEnumerator)
    {
        bonus += [continent bonusArmiesForPlayer:number];
    }
    
    return bonus;
}

//----------------------------------------------------------------------

- (NSSet *) countriesForPlayer:(RKPlayer)number
{
    return RKCountriesForPlayerNumber (allCountries, number);
}

@end

//======================================================================
// Some utility functions.
//======================================================================

NSSet<RKCountry*> *RKCountriesForPlayerNumber (NSSet *source, RKPlayer number)
{
    NSMutableSet<RKCountry*> *newSet = [NSMutableSet set];
    
    for (RKCountry *country in source) {
        if (country.playerNumber == number) {
            [newSet addObject:country];
        }
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<RKCountry*> *RKCountriesInContinentNamed (NSSet *source, NSString *continentName)
{
    NSMutableSet<RKCountry*> *newSet = [[NSMutableSet alloc] init];
    
    for (RKCountry *country in source) {
        if ([country.continentName isEqualToString:continentName] == YES) {
            [newSet addObject:country];
        }
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<RKCountry*> *RKCountriesWithArmies (NSSet *source)
{
    NSMutableSet<RKCountry*> *newSet = [[NSMutableSet alloc] init];
    
    for (RKCountry *country in source) {
        if (country.troopCount > 0) {
            [newSet addObject:country];
        }
    }
    
    return [newSet copy];
}

//----------------------------------------------------------------------

NSSet<RKCountry*> *RKNeighborsOfCountries (NSSet<RKCountry*> *source)
{
    NSMutableSet<RKCountry*> *newSet = [NSMutableSet set];
    
    for (RKCountry *country in source) {
        [newSet unionSet:country.neighborCountries];
    }
    
    return [newSet copy];
}
