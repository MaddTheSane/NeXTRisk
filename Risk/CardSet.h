//
// $Id: CardSet.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class RiskCard;

NSComparisonResult compareCardSetValues (id object1, id object2, void *context);

@interface CardSet : NSObject

+ (BOOL) isValidCardSet:(RiskCard *)aCard1 :(RiskCard *)aCard2 :(RiskCard *)aCard3;

+ (instancetype)cardSet:(RiskCard *)aCard1 :(RiskCard *)aCard2 :(RiskCard *)aCard3 NS_SWIFT_UNAVAILABLE("Use init(cardSet:_:_:) instead");

- (instancetype)initCardSet:(RiskCard *)aCard1 :(RiskCard *)aCard2 :(RiskCard *)aCard3;

@property (readonly, retain) RiskCard *card1;
@property (readonly, retain) RiskCard *card2;
@property (readonly, retain) RiskCard *card3;

- (int) wildcardCount;
- (int) countryCountForPlayerNumber:(Player)number;

@end
