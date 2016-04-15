//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskNeighbor.m,v 1.2 1997/12/15 07:44:08 nygard Exp $");

#import "RiskNeighbor.h"

#import "Country.h"
#import "NSObjectExtensions.h"

//======================================================================
// A RiskNeighbor represents two neighboring countries in a world.
// They are not directly encoded in a stream -- instead, their names
// are stored and then new instances are created after looking up
// the countries based on their names.
//======================================================================

#define RiskNeighbor_VERSION 1

@implementation RiskNeighbor

+ (void) initialize
{
    if (self == [RiskNeighbor class])
    {
        [self setVersion:RiskNeighbor_VERSION];
    }
}

//----------------------------------------------------------------------

+ riskNeighborWithCountries:(Country *)firstCountry:(Country *)secondCountry
{
    return [[[RiskNeighbor alloc] initWithCountries:firstCountry:secondCountry] autorelease];
}

//----------------------------------------------------------------------

- initWithCountries:(Country *)firstCountry:(Country *)secondCountry
{
    if ([super init] == nil)
        return nil;

    country1 = [firstCountry retain];
    country2 = [secondCountry retain];

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (country1);
    SNRelease (country2);

    [super dealloc];
}

//----------------------------------------------------------------------

- (Country *) country1
{
    return country1;
}

//----------------------------------------------------------------------

- (Country *) country2
{
    return country2;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RiskNeighbor: country1 = %@, country2 = %@>", country1, country2];
}

@end
