//
// $Id: RiskNeighbor.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

@class Country;

NS_ASSUME_NONNULL_BEGIN

/// A \c RiskNeighbor represents two neighboring countries in a world.
/// They are not directly encoded in a stream -- instead, their names
/// are stored and then new instances are created after looking up
/// the countries based on their names.
@interface RiskNeighbor : NSObject <NSCoding>

+ (instancetype)riskNeighborWithCountries:(Country *)firstCountry :(Country *)secondCountry NS_SWIFT_UNAVAILABLE("Use init(countriesFirst:second:) instead");

- (instancetype)initWithCountries:(Country *)firstCountry :(Country *)secondCountry NS_SWIFT_NAME(init(countriesFirst:second:)) NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, strong) Country *country1;
@property (readonly, strong) Country *country2;

@property (readonly, copy) NSString *description;

@end

NS_ASSUME_NONNULL_END
