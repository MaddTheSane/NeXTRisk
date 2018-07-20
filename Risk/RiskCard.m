//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskCard.m,v 1.2 1997/12/15 07:44:02 nygard Exp $");

#import "RiskCard.h"

#import "Country.h"

extern NSBundle *currentBundle;

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
    return [self initWithCardType:aCardType withCountry:aCountry imageNamed:anImageName bundle:currentBundle ?: [NSBundle bundleForClass:[self class]]];
}

- (instancetype)initWithCardType:(RiskCardType)aCardType withCountry:(nullable Country *)aCountry imageNamed:(NSString *)anImageName bundle:(NSBundle*)thisBundle
{
    if (self = [super init]) {
        country = aCountry; // Country can be nil.
        cardType = aCardType;
        imageName = [anImageName copy];
        
        //thisBundle = [NSBundle bundleForClass:[self class]];
        NSAssert (thisBundle != nil, @"Could not get this bundle.");
        if (imageName.pathExtension) {
            imageName = imageName.stringByDeletingPathExtension;
        }
        
        image = [thisBundle imageForResource:imageName];
        if (!image) {
            image = [NSImage imageNamed:imageName];
        }
        
        if (!image && ![imageName hasPrefix:@"Cards/"]) {
            imageName = [@"Cards/" stringByAppendingPathComponent:imageName];
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

#define RKCountryKey @"RKCountry"
#define RKCardTypeKey @"RKCardType"
#define RKImageNameKey @"RKImageName"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeConditionalObject:country forKey:RKCountryKey];
    [aCoder encodeObject:imageName forKey:RKImageNameKey];
    [aCoder encodeInt:cardType forKey:RKCardTypeKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(aDecoder.allowsKeyedCoding, @"Expected a decoder class that was keyed coding, got %@", [aDecoder className]);
    Country *tmpCountry = [aDecoder decodeObjectForKey:RKCountryKey];
    NSString *imgNam = [aDecoder decodeObjectForKey:RKImageNameKey];
    RiskCardType ct = [aDecoder decodeIntForKey:RKCardTypeKey];
    
    return [self initCardType:ct withCountry:tmpCountry imageNamed:imgNam];
}

@end
