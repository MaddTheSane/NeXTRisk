//
// $Id: RiskCard.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/NSObject.h>
#import <AppKit/NSImage.h>

#import <RiskKit/Risk.h>

@class RKCountry;
@class NSImage;

NS_ASSUME_NONNULL_BEGIN

//! A \c RiskCard represents the country, type, image, and image name of
//! a card in the game.  If multiple <code>RiskWorld</code>s are allowed, then
//! different cards will be required for each world.
@interface RKCard : NSObject <NSCoding>

+ (instancetype)riskCardType:(RKCardType)aCardType withCountry:(nullable RKCountry *)aCountry imageNamed:(NSImageName)anImageName NS_SWIFT_UNAVAILABLE("Use init(cardType:with:imageNamed:) instead");

// Take card image name from country?
- (instancetype)initCardType:(RKCardType)aCardType withCountry:(nullable RKCountry *)aCountry imageNamed:(NSImageName)anImageName NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, strong, nullable) RKCountry *country;
@property (readonly) RKCardType cardType;
@property (readonly, copy) NSString *imageName;
@property (readonly, strong) NSImage *image;

@end

NS_ASSUME_NONNULL_END
