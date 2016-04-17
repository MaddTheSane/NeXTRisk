//
// $Id: RiskCard.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class Country;

NS_ASSUME_NONNULL_BEGIN

@interface RiskCard : NSObject

+ (instancetype)riskCardType:(RiskCardType)aCardType withCountry:(nullable Country *)aCountry imageNamed:(NSString *)anImageName NS_SWIFT_UNAVAILABLE("Use init(cardType:withCountry:imageNamed:) instead");

// Take card image name from country?
- (instancetype)initCardType:(RiskCardType)aCardType withCountry:(nullable Country *)aCountry imageNamed:(NSString *)anImageName NS_DESIGNATED_INITIALIZER;

@property (readonly, strong, nullable) Country *country;
@property (readonly) RiskCardType cardType;
@property (readonly, copy) NSString *imageName;
@property (readonly, strong) NSImage *image;

@end

NS_ASSUME_NONNULL_END
