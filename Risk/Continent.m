//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: Continent.m,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $");

#import "Continent.h"

#import "Country.h"

#define Continent_VERSION 1

@implementation Continent
@synthesize continentName;

+ (void) initialize
{
    if (self == [Continent class])
    {
        [self setVersion:Continent_VERSION];
    }
}

//----------------------------------------------------------------------

+ continentWithName:(NSString *)aContinentName countries:(NSSet *)someCountries bonusValue:(int)bonus
{
    return [[[Continent alloc] initWithName:aContinentName countries:someCountries bonusValue:bonus] autorelease];
}

//----------------------------------------------------------------------

- initWithName:(NSString *)aContinentName countries:(NSSet *)someCountries bonusValue:(int)bonus
{
    if ([super init] == nil)
        return nil;

    continentName = [aContinentName copy];
    countries = [someCountries retain];
    continentBonus = bonus;

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (continentName);
    SNRelease (countries);

    [super dealloc];
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
    if ([super init] == nil)
        return nil;

	if ([aDecoder allowsKeyedCoding]) {
		continentName = [[aDecoder decodeObjectForKey:kContinentNameKey] copy];
		countries = [[aDecoder decodeObjectForKey:kCountriesKey] retain];
		continentBonus = [aDecoder decodeIntForKey:kContinentBonusKey];
	} else {
		continentName = [[aDecoder decodeObject] copy];
		countries = [[aDecoder decodeObject] retain];
		[aDecoder decodeValueOfObjCType:@encode (int) at:&continentBonus];
	}

    return self;
}

//----------------------------------------------------------------------

- (NSString *) continentName
{
    return continentName;
}

//----------------------------------------------------------------------

- (NSSet *) countries
{
    return countries;
}

//----------------------------------------------------------------------

- (int) continentBonus
{
    return continentBonus;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<Continent: name = %@, bonus = %d, countries = %@",
                     continentName, continentBonus, countries];
}

//----------------------------------------------------------------------

- (int) bonusArmiesForPlayer:(Player)number
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL flag;
    int bonus;

    flag = YES;
    countryEnumerator = [countries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if ([country playerNumber] != number)
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
    NSEnumerator *countryEnumerator;
    NSMutableSet *resultingSet;
    Country *country;

    resultingSet = [NSMutableSet set];

    countryEnumerator = [countries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        if ([country bordersAnotherContinent] == YES)
            [resultingSet addObject:country];
    }

    return resultingSet;
}

@end
