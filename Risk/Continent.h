//
// $Id: Continent.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class Country;
@interface Continent : NSObject <NSCoding>
{
    NSString *continentName;
    NSSet *countries;
    int continentBonus;
}

+ (void) initialize;

+ (instancetype)continentWithName:(NSString *)aContinentName countries:(NSSet *)someCountries bonusValue:(int)bonus;

- (instancetype)initWithName:(NSString *)aContinentName countries:(NSSet *)someCountries bonusValue:(int)bonus NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSString *continentName;
@property (readonly, retain) NSSet<Country*> *countries;
@property (readonly) int continentBonus;

- (NSString *) description;

- (int) bonusArmiesForPlayer:(Player)number;

- (NSSet<Country*> *) countriesAlongBorder;

@end
