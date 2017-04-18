//
// $Id: Continent.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

NS_ASSUME_NONNULL_BEGIN

@class Country;
@interface Continent : NSObject <NSCoding>
{
    NSString *continentName;
    NSSet<Country*> *countries;
    int continentBonus;
}

+ (instancetype)continentWithName:(NSString *)aContinentName countries:(NSSet<Country*> *)someCountries bonusValue:(RiskArmyCount)bonus NS_SWIFT_UNAVAILABLE("Use init(name:countries:bonusValue) instead");

- (instancetype)initWithName:(NSString *)aContinentName countries:(NSSet<Country*> *)someCountries bonusValue:(RiskArmyCount)bonus NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, copy) NSString *continentName;
@property (readonly, strong) NSSet<Country*> *countries;
@property (readonly) RiskArmyCount continentBonus;

@property (readonly, copy) NSString *description;

- (RiskArmyCount) bonusArmiesForPlayer:(Player)number;

@property (readonly, copy) NSSet<Country *> *countriesAlongBorder;

@end

NS_ASSUME_NONNULL_END
