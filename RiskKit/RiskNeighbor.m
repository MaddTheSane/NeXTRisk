//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskNeighbor.m,v 1.2 1997/12/15 07:44:08 nygard Exp $");

#import "RiskNeighbor.h"
#import "Country.h"

#define RiskNeighbor_VERSION 1

@implementation RiskNeighbor
@synthesize country1;
@synthesize country2;

+ (void) initialize
{
    if (self == [RiskNeighbor class])
    {
        [self setVersion:RiskNeighbor_VERSION];
    }
}

//----------------------------------------------------------------------

+ (instancetype)riskNeighborWithCountries:(Country *)firstCountry :(Country *)secondCountry
{
    return [[RiskNeighbor alloc] initWithCountries:firstCountry:secondCountry];
}

//----------------------------------------------------------------------

- (instancetype)initWithCountries:(Country *)firstCountry :(Country *)secondCountry
{
    if (self = [super init]) {
        country1 = firstCountry;
        country2 = secondCountry;
    }
    
    return self;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RiskNeighbor: country1 = %@, country2 = %@>", country1, country2];
}

#define RiskNeighbor1 @"firstCountry"
#define RiskNeighbor2 @"secondCountry"

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeConditionalObject:country1 forKey:RiskNeighbor1];
    [coder encodeConditionalObject:country2 forKey:RiskNeighbor2];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(aDecoder.allowsKeyedCoding, @"Expected a decoder class that was keyed coding, got %@", [aDecoder className]);
    if (self = [super init]) {
        country1 = [aDecoder decodeObjectForKey:RiskNeighbor1];
        country2 = [aDecoder decodeObjectForKey:RiskNeighbor2];
    }
    return self;
}

@end
