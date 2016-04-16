//
// $Id: RiskCard.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class Country;

NS_ASSUME_NONNULL_BEGIN

@interface RiskCard : NSObject
{
    Country *country;
    RiskCardType cardType;
    NSString *imageName;
    NSImage *image;
}

+ (instancetype)riskCardType:(RiskCardType)aCardType withCountry:(nullable Country *)aCountry imageNamed:(NSString *)anImageName NS_SWIFT_UNAVAILABLE("Use init(cardType:withCountry:imageNamed:) instead");

// Take card image name from country?
- (instancetype)initCardType:(RiskCardType)aCardType withCountry:(nullable Country *)aCountry imageNamed:(NSString *)anImageName;

@property (readonly, retain, nullable) Country *country;
@property (readonly) RiskCardType cardType;
@property (readonly, copy) NSString *imageName;
@property (readonly, retain) NSImage *image;

@end

NS_ASSUME_NONNULL_END
