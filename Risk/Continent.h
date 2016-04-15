//
// $Id: Continent.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@interface Continent : NSObject
{
    NSString *continentName;
    NSSet *countries;
    int continentBonus;
}

+ (void) initialize;

+ continentWithName:(NSString *)aContinentName countries:(NSSet *)someCountries bonusValue:(int)bonus;

- initWithName:(NSString *)aContinentName countries:(NSSet *)someCountries bonusValue:(int)bonus;
- (void) dealloc;

- (void) encodeWithCoder:(NSCoder *)aCoder;
- initWithCoder:(NSCoder *)aDecoder;

- (NSString *) continentName;
- (NSSet *) countries;
- (int) continentBonus;

- (NSString *) description;

- (int) bonusArmiesForPlayer:(Player)number;

- (NSSet *) countriesAlongBorder;

@end
