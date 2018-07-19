//
// $Id: RKCardSet.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class RiskCard;

NSComparisonResult compareCardSetValues (id __nullable object1, id __nullable object2, void * __nullable context);

//! A \c RKCardSet represents a *valid* set of three cards.  There is one
//! class method to verify a set of cards.  The initializer will return
//! \c nil if the cards are not a valid set.
@interface RKCardSet : NSObject

+ (BOOL) isValidCardSet:(nullable RiskCard *)aCard1 :(nullable RiskCard *)aCard2 :(nullable RiskCard *)aCard3 NS_SWIFT_NAME(isValidCardSet(card1:card2:card3:));

+ (nullable instancetype)cardSet:(null_unspecified RiskCard *)aCard1 :(null_unspecified RiskCard *)aCard2 :(null_unspecified RiskCard *)aCard3 NS_SWIFT_UNAVAILABLE("Use init(cardSet:_:_:) instead");

- (nullable instancetype)initCardSet:(null_unspecified RiskCard *)aCard1 :(null_unspecified RiskCard *)aCard2 :(null_unspecified RiskCard *)aCard3 NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, strong, nonnull) RiskCard *card1;
@property (readonly, strong, nonnull) RiskCard *card2;
@property (readonly, strong, nonnull) RiskCard *card3;

@property (readonly) NSInteger wildcardCount;
- (NSInteger) countryCountForPlayerNumber:(RKPlayer)number;

@end
