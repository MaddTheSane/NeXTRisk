//
// $Id: RiskNeighbor.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

@class Country;

@interface RiskNeighbor : NSObject
{
    Country *country1;
    Country *country2;
}

+ (instancetype)riskNeighborWithCountries:(Country *)firstCountry :(Country *)secondCountry;

- (instancetype)initWithCountries:(Country *)firstCountry :(Country *)secondCountry;

@property (readonly, retain) Country *country1;
@property (readonly, retain) Country *country2;

- (NSString *) description;

@end