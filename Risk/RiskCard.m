//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskCard.m,v 1.2 1997/12/15 07:44:02 nygard Exp $");

#import "RiskCard.h"

#import "Country.h"

//======================================================================
// A RiskCard represents the country, type, image, and image name of
// a card in the game.  If multiple RiskWorlds are allowed, then
// different cards will be required for each world.
//======================================================================

#define RiskCard_VERSION 1

@implementation RiskCard
@synthesize country;
@synthesize cardType;
@synthesize image;
@synthesize imageName;

+ (void) initialize
{
    if (self == [RiskCard class])
    {
        [self setVersion:RiskCard_VERSION];
    }
}

//----------------------------------------------------------------------

+ (instancetype) riskCardType:(RiskCardType)aCardType withCountry:(Country *)aCountry imageNamed:(NSString *)anImageName
{
    return [[RiskCard alloc] initCardType:aCardType withCountry:aCountry imageNamed:anImageName];
}

//----------------------------------------------------------------------

- (instancetype) initCardType:(RiskCardType)aCardType withCountry:(Country *)aCountry imageNamed:(NSString *)anImageName
{
    NSBundle *thisBundle;

    if (self = [super init]) {
        country = aCountry; // Country can be nil.
        cardType = aCardType;
        imageName = [anImageName copy];

        thisBundle = [NSBundle bundleForClass:[self class]];
        NSAssert (thisBundle != nil, @"Could not get this bundle.");
        if (imageName.pathExtension) {
            imageName = imageName.stringByDeletingPathExtension;
        }

        image = [thisBundle imageForResource:imageName];
        if (!image) {
            image = [NSImage imageNamed:imageName];
        }
        NSAssert1 (image != nil, @"Couldn't load image: '%@'", imageName);
    }

    return self;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RiskCard: country = %@, cardType = %@, imageName = %@>",
                     country.countryName, NSStringFromRiskCardType (cardType), imageName];
}

@end
