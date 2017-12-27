//
// $Id: RiskCard.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/NSObject.h>
#import <AppKit/NSImage.h>

#import "Risk.h"

@class Country;
@class NSImage;

NS_ASSUME_NONNULL_BEGIN

@interface RiskCard : NSObject <NSCoding>

+ (instancetype)riskCardType:(RiskCardType)aCardType withCountry:(nullable Country *)aCountry imageNamed:(NSString *)anImageName NS_SWIFT_UNAVAILABLE("Use init(cardType:with:imageNamed:) instead");

// Take card image name from country?
- (instancetype)initCardType:(RiskCardType)aCardType withCountry:(nullable Country *)aCountry imageNamed:(NSImageName)anImageName NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, strong, nullable) Country *country;
@property (readonly) RiskCardType cardType;
@property (readonly, copy) NSString *imageName;
@property (readonly, strong) NSImage *image;

@end

NS_ASSUME_NONNULL_END
