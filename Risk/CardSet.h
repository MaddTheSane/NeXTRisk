//
// $Id: CardSet.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class RiskCard;

NSComparisonResult compareCardSetValues (id __nonnull object1, id __nonnull object2, void * __nullable context);

@interface CardSet : NSObject

+ (BOOL) isValidCardSet:(nullable RiskCard *)aCard1 :(nullable RiskCard *)aCard2 :(nullable RiskCard *)aCard3 NS_SWIFT_NAME(isValidCardSet(card1:card2:card3:));

+ (nullable instancetype)cardSet:(null_unspecified RiskCard *)aCard1 :(null_unspecified RiskCard *)aCard2 :(null_unspecified RiskCard *)aCard3 NS_SWIFT_UNAVAILABLE("Use init(cardSet:_:_:) instead");

- (nullable instancetype)initCardSet:(null_unspecified RiskCard *)aCard1 :(null_unspecified RiskCard *)aCard2 :(null_unspecified RiskCard *)aCard3 NS_DESIGNATED_INITIALIZER;

@property (readonly, strong, nonnull) RiskCard *card1;
@property (readonly, strong, nonnull) RiskCard *card2;
@property (readonly, strong, nonnull) RiskCard *card3;

@property (readonly) NSInteger wildcardCount;
- (int) countryCountForPlayerNumber:(Player)number;

@end
