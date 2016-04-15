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

+ (void) initialize
{
    if (self == [RiskCard class])
    {
        [self setVersion:RiskCard_VERSION];
    }
}

//----------------------------------------------------------------------

+ riskCardType:(RiskCardType)aCardType withCountry:(Country *)aCountry imageNamed:(NSString *)anImageName
{
    return [[[RiskCard alloc] initCardType:aCardType withCountry:aCountry imageNamed:anImageName] autorelease];
}

//----------------------------------------------------------------------

- initCardType:(RiskCardType)aCardType withCountry:(Country *)aCountry imageNamed:(NSString *)anImageName
{
    NSBundle *thisBundle;
    NSString *imagePath;

    if ([super init] == nil)
        return nil;

    country = [aCountry retain]; // Country can be nil.
    cardType = aCardType;
    imageName = [anImageName retain];

    thisBundle = [NSBundle bundleForClass:[self class]];
    NSAssert (thisBundle != nil, @"Could not get this bundle.");
    
    imagePath = [thisBundle pathForImageResource:imageName];
    NSAssert1 (imagePath != nil, @"Could not find image: '%@'", imageName);

    image = [[NSImage alloc] initByReferencingFile:imagePath];
    NSAssert1 (image != nil, @"Couldn't load image: '%@'", imageName);

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (country);
    SNRelease (imageName);
    SNRelease (image);

    [super dealloc];
}

//----------------------------------------------------------------------

- (Country *) country
{
    return country;
}

//----------------------------------------------------------------------

- (RiskCardType) cardType
{
    return cardType;
}

//----------------------------------------------------------------------

- (NSString *) imageName
{
    return imageName;
}

//----------------------------------------------------------------------

- (NSImage *) image
{
    return image;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RiskCard: country = %@, cardType = %@, imageName = %@>",
                     [country countryName], NSStringFromRiskCardType (cardType), imageName];
}

@end
