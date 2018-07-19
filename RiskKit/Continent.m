//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: Continent.m,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $");

#import "Continent.h"

#import "RKCountry.h"

#define Continent_VERSION 1

@implementation Continent
@synthesize continentName;
@synthesize continentBonus;
@synthesize countries = countries;

+ (void) initialize
{
    if (self == [Continent class])
    {
        [self setVersion:Continent_VERSION];
    }
}

//----------------------------------------------------------------------

+ (instancetype) continentWithName:(NSString *)aContinentName countries:(NSSet *)someCountries bonusValue:(int)bonus
{
    return [[Continent alloc] initWithName:aContinentName countries:someCountries bonusValue:bonus];
}

//----------------------------------------------------------------------

- (instancetype) initWithName:(NSString *)aContinentName countries:(NSSet *)someCountries bonusValue:(int)bonus
{
    if (self = [super init]) {
        continentName = [aContinentName copy];
        countries = someCountries;
        continentBonus = bonus;
    }
    
    return self;
}

#define kContinentNameKey @"ContinentName"
#define kCountriesKey @"Countries"
#define kContinentBonusKey @"ContinentBonus"

//----------------------------------------------------------------------

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:continentName forKey:kContinentNameKey];
    [aCoder encodeObject:countries forKey:kCountriesKey];
    [aCoder encodeInt:continentBonus forKey:kContinentBonusKey];
}

//----------------------------------------------------------------------

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        if (aDecoder.allowsKeyedCoding && [aDecoder containsValueForKey:kContinentNameKey]) {
            continentName = [[aDecoder decodeObjectForKey:kContinentNameKey] copy];
            countries = [[aDecoder decodeObjectForKey:kCountriesKey] copy];
            continentBonus = [aDecoder decodeIntForKey:kContinentBonusKey];
        } else {
            continentName = [[aDecoder decodeObject] copy];
            countries = [[aDecoder decodeObject] copy];
            [aDecoder decodeValueOfObjCType:@encode (int) at:&continentBonus];
        }
    }
    
    return self;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<Continent: name = %@, bonus = %d, countries = %@",
            continentName, continentBonus, countries];
}

//----------------------------------------------------------------------

- (int) bonusArmiesForPlayer:(RKPlayer)number
{
    int bonus;
    
    BOOL flag = YES;
    for (RKCountry *country in countries)
    {
        if (country.playerNumber != number)
        {
            flag = NO;
            break;
        }
    }
    
    bonus = (flag == YES) ? continentBonus : 0;
    
    return bonus;
}

//----------------------------------------------------------------------

- (NSSet *) countriesAlongBorder
{
    NSMutableSet *resultingSet = [[NSMutableSet alloc] init];
    
    for (RKCountry *country in countries)
    {
        if ([country bordersAnotherContinent] == YES)
            [resultingSet addObject:country];
    }
    
    return resultingSet;
}

@end
