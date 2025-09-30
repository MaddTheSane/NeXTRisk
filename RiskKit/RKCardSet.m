//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: CardSet.m,v 1.2 1997/12/15 07:43:42 nygard Exp $");

#import "RKCardSet.h"

#import "RKCountry.h"
#import "RKCard.h"

// Put nils at end of list.  Minimize use of wildcards.

NSComparisonResult RKCompareCardSetValues (id object1, id object2, void *context)
{
    NSComparisonResult result;
    RKPlayer number = (RKPlayer)context;
    RKCardSet *cardSet1 = object1;
    RKCardSet *cardSet2 = object2;
    NSInteger wildcardCount1, wildcardCount2;
    NSInteger countryCount1, countryCount2;
    
    if (cardSet1 == nil && cardSet2 == nil) {
        result = NSOrderedSame;
    } else if (cardSet1 == nil) {
        result = NSOrderedDescending;
    } else if (cardSet2 == nil) {
        result = NSOrderedAscending;
    } else {
        wildcardCount1 = [cardSet1 wildcardCount];
        wildcardCount2 = [cardSet2 wildcardCount];
        
        if (wildcardCount1 == wildcardCount2) {
            // Otherwise, compare number of countries owned by player.
            countryCount1 = [cardSet1 countryCountForPlayerNumber:number];
            countryCount2 = [cardSet2 countryCountForPlayerNumber:number];
            
            if (countryCount1 == countryCount2) {
                result = NSOrderedSame;
            } else {
                result = (countryCount1 < countryCount2) ? NSOrderedAscending : NSOrderedDescending;
            }
        } else {
            // Prefer to use the minimal number of wildcards.
            result = (wildcardCount1 < wildcardCount2) ? NSOrderedAscending : NSOrderedDescending;
        }
    }
    
    return result;
}

#define CardSet_VERSION 1

@implementation RKCardSet
@synthesize card1;
@synthesize card2;
@synthesize card3;

+ (void) initialize
{
    if (self == [RKCardSet class]) {
        [self setVersion:CardSet_VERSION];
    }
}

//----------------------------------------------------------------------

// Valid if they are all the same, or if they are all different, or there
// is at least one wildcard.

+ (BOOL) isValidCardSet:(RKCard *)aCard1 :(RKCard *)aCard2 :(RKCard *)aCard3
{
    BOOL valid;
    
    if (aCard1 == nil || aCard2 == nil || aCard3 == nil) {
        valid = NO;
    } else {
        RKCardType c1 = aCard1.cardType;
        RKCardType c2 = aCard2.cardType;
        RKCardType c3 = aCard3.cardType;
        
        if (c1 == RKCardWildcard || c2 == RKCardWildcard || c3 == RKCardWildcard) {
            valid = YES;
        } else if (c1 == c2 && c1 == c3) {
            valid = YES;
        } else if (c1 != c2 && c1 != c3 && c2 != c3) {
            valid = YES;
        } else {
            valid = NO;
        }
    }
    
    return valid;
}

//----------------------------------------------------------------------

+ (instancetype) cardSet:(RKCard *)aCard1 :(RKCard *)aCard2 :(RKCard *)aCard3
{
    return [[RKCardSet alloc] initCardSet:aCard1:aCard2:aCard3];
}

//----------------------------------------------------------------------

- (instancetype) initCardSet:(RKCard *)aCard1 :(RKCard *)aCard2 :(RKCard *)aCard3
{
    if (self = [super init]) {
        if ([RKCardSet isValidCardSet:aCard1:aCard2:aCard3] == NO) {
            return nil;
        }
        
        card1 = aCard1;
        card2 = aCard2;
        card3 = aCard3;
    }
    
    return self;
}

//----------------------------------------------------------------------

- (NSInteger) wildcardCount
{
    int count = 0;
    
    if (card1.cardType == RKCardWildcard) {
        count++;
    }
    
    if (card2.cardType == RKCardWildcard) {
        count++;
    }
    
    if (card3.cardType == RKCardWildcard) {
        count++;
    }
    
    return count;
}

//----------------------------------------------------------------------

- (NSInteger) countryCountForPlayerNumber:(RKPlayer)number
{
    NSInteger count;
    
    count = 0;
    
    if (card1.country.playerNumber == number) {
        count++;
    }
    
    if (card2.country.playerNumber == number) {
        count++;
    }
    
    if (card3.country.playerNumber == number) {
        count++;
    }
    
    return count;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<CardSet: card1 = %@, card2 = %@, card3 = %@>", card1, card2, card3];
}

@end
