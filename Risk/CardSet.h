//
// $Id: CardSet.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

#import "Risk.h"

@class RiskCard;

NSComparisonResult compareCardSetValues (id object1, id object2, void *context);

@interface CardSet : NSObject
{
    RiskCard *card1, *card2, *card3;
}

+ (void) initialize;

+ (BOOL) isValidCardSet:(RiskCard *)aCard1:(RiskCard *)aCard2:(RiskCard *)aCard3;

+ cardSet:(RiskCard *)aCard1:(RiskCard *)aCard2:(RiskCard *)aCard3;

- initCardSet:(RiskCard *)aCard1:(RiskCard *)aCard2:(RiskCard *)aCard3;
- (void) dealloc;

- (RiskCard *) card1;
- (RiskCard *) card2;
- (RiskCard *) card3;

- (int) wildcardCount;
- (int) countryCountForPlayerNumber:(Player)number;

- (NSString *) description;

@end
