//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: CardSet.m,v 1.2 1997/12/15 07:43:42 nygard Exp $");

#import "CardSet.h"

#import "Country.h"
#import "RiskCard.h"

//======================================================================
// A CardSet represents a *valid* set of three cards.  There is one
// class method to verify a set of cards.  The initializer will return
// nil if the cards are not a valid set.
//======================================================================

// Put nils at end of list.  Minimize use of wildcards.

NSComparisonResult compareCardSetValues (id object1, id object2, void *context)
{
    NSComparisonResult result;
    Player number;
    CardSet *cardSet1, *cardSet2;
    int wildcardCount1, wildcardCount2;
    int countryCount1, countryCount2;

    number = (Player)context;
    cardSet1 = object1;
    cardSet2 = object2;

    if (cardSet1 == nil && cardSet2 == nil)
    {
        result = NSOrderedSame;
    }
    else if (cardSet1 == nil)
    {
        result = NSOrderedDescending;
    }
    else if (cardSet2 == nil)
    {
        result = NSOrderedAscending;
    }
    else
    {
        wildcardCount1 = [cardSet1 wildcardCount];
        wildcardCount2 = [cardSet2 wildcardCount];

        if (wildcardCount1 == wildcardCount2)
        {
            // Otherwise, compare number of countries owned by player.
            countryCount1 = [cardSet1 countryCountForPlayerNumber:number];
            countryCount2 = [cardSet2 countryCountForPlayerNumber:number];

            if (countryCount1 == countryCount2)
            {
                result = NSOrderedSame;
            }
            else
            {
                result = (countryCount1 < countryCount2) ? NSOrderedAscending : NSOrderedDescending;
            }
        }
        else
        {
            // Prefer to use the minimal number of wildcards.
            result = (wildcardCount1 < wildcardCount2) ? NSOrderedAscending : NSOrderedDescending;
        }
    }

    return result;
}

#define CardSet_VERSION 1

@implementation CardSet
@synthesize card1;
@synthesize card2;
@synthesize card3;

+ (void) initialize
{
    if (self == [CardSet class])
    {
        [self setVersion:CardSet_VERSION];
    }
}

//----------------------------------------------------------------------

// Valid if they are all the same, or if they are all different, or there
// is at least one wildcard.

+ (BOOL) isValidCardSet:(RiskCard *)aCard1 :(RiskCard *)aCard2 :(RiskCard *)aCard3
{
    RiskCardType c1, c2, c3;
    BOOL valid;

    if (aCard1 == nil || aCard2 == nil || aCard3 == nil)
    {
        valid = NO;
    }
    else
    {
        c1 = [aCard1 cardType];
        c2 = [aCard2 cardType];
        c3 = [aCard3 cardType];

        if (c1 == Wildcard || c2 == Wildcard || c3 == Wildcard)
        {
            valid = YES;
        }
        else if (c1 == c2 && c1 == c3)
        {
            valid = YES;
        }
        else if (c1 != c2 && c1 != c3 && c2 != c3)
        {
            valid = YES;
        }
        else
        {
            valid = NO;
        }
    }

    return valid;
}

//----------------------------------------------------------------------

+ cardSet:(RiskCard *)aCard1 :(RiskCard *)aCard2 :(RiskCard *)aCard3
{
    return [[[CardSet alloc] initCardSet:aCard1:aCard2:aCard3] autorelease];
}

//----------------------------------------------------------------------

- initCardSet:(RiskCard *)aCard1 :(RiskCard *)aCard2 :(RiskCard *)aCard3
{
    if (self = [super init]) {
        if ([CardSet isValidCardSet:aCard1:aCard2:aCard3] == NO)
        {
            [self dealloc];
            return nil;
        }

        card1 = [aCard1 retain];
        card2 = [aCard2 retain];
        card3 = [aCard3 retain];
    }

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (card1);
    SNRelease (card2);
    SNRelease (card3);
    
    [super dealloc];
}

//----------------------------------------------------------------------

- (int) wildcardCount
{
    int count;

    count = 0;

    if ([card1 cardType] == Wildcard)
        count++;

    if ([card2 cardType] == Wildcard)
        count++;

    if ([card3 cardType] == Wildcard)
        count++;

    return count;
}

//----------------------------------------------------------------------

- (int) countryCountForPlayerNumber:(Player)number
{
    int count;

    count = 0;

    if ([[card1 country] playerNumber] == number)
        count++;

    if ([[card2 country] playerNumber] == number)
        count++;

    if ([[card3 country] playerNumber] == number)
        count++;

    return count;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<CardSet: card1 = %@, card2 = %@, card3 = %@>", card1, card2, card3];
}

@end
