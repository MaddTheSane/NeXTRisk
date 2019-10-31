//
// $Id: Continent.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import <RiskKit/Risk.h>

NS_ASSUME_NONNULL_BEGIN

@class RKCountry;
@interface RKContinent : NSObject <NSSecureCoding>
{
    NSString *continentName;
    NSSet<RKCountry*> *countries;
    RKArmyCount continentBonus;
}

+ (instancetype)continentWithName:(NSString *)aContinentName countries:(NSSet<RKCountry*> *)someCountries bonusValue:(RKArmyCount)bonus NS_SWIFT_UNAVAILABLE("Use init(name:countries:bonusValue) instead");

- (instancetype)initWithName:(NSString *)aContinentName countries:(NSSet<RKCountry*> *)someCountries bonusValue:(RKArmyCount)bonus NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, copy) NSString *continentName;
@property (readonly, strong) NSSet<RKCountry*> *countries;
@property (readonly) RKArmyCount continentBonus;

@property (readonly, copy) NSString *description;

- (RKArmyCount) bonusArmiesForPlayer:(RKPlayer)number;

@property (readonly, copy) NSSet<RKCountry *> *countriesAlongBorder;

@end

NS_ASSUME_NONNULL_END
