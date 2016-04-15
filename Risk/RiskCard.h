//
// $Id: RiskCard.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class Country;

@interface RiskCard : NSObject
{
    Country *country;
    RiskCardType cardType;
    NSString *imageName;
    NSImage *image;
}

+ (void) initialize;

+ riskCardType:(RiskCardType)aCardType withCountry:(Country *)aCountry imageNamed:(NSString *)anImageName;

// Take card image name from country?
- initCardType:(RiskCardType)aCardType withCountry:(Country *)aCountry imageNamed:(NSString *)anImageName;
- (void) dealloc;

- (Country *) country;
- (RiskCardType) cardType;
- (NSString *) imageName;
- (NSImage *) image;

- (NSString *) description;

@end
