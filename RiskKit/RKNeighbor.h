//
// $Id: RiskNeighbor.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

@class RKCountry;

NS_ASSUME_NONNULL_BEGIN

/// An \c RKNeighbor represents two neighboring countries in a world.
/// They are not directly encoded in a stream -- instead, their names
/// are stored and then new instances are created after looking up
/// the countries based on their names.
@interface RKNeighbor : NSObject <NSCoding>

+ (instancetype)riskNeighborWithCountries:(RKCountry *)firstCountry :(RKCountry *)secondCountry NS_SWIFT_UNAVAILABLE("Use init(countriesFirst:second:) instead");

- (instancetype)initWithCountries:(RKCountry *)firstCountry :(RKCountry *)secondCountry NS_SWIFT_NAME(init(countriesFirst:second:)) NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, strong) RKCountry *country1;
@property (readonly, strong) RKCountry *country2;

@property (readonly, copy) NSString *description;

@end

NS_ASSUME_NONNULL_END
