//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: RiskCard.m,v 1.2 1997/12/15 07:44:02 nygard Exp $");

#import <RiskKit/RKCard.h>

#import "RKCountry.h"

#define RiskCard_VERSION 1

@implementation RKCard
@synthesize country;
@synthesize cardType;
@synthesize image;
@synthesize imageName;

+ (void) initialize
{
    if (self == [RKCard class]) {
        [self setVersion:RiskCard_VERSION];
    }
}

//----------------------------------------------------------------------

+ (instancetype) riskCardType:(RKCardType)aCardType withCountry:(RKCountry *)aCountry imageNamed:(NSString *)anImageName
{
    return [[self alloc] initCardType:aCardType withCountry:aCountry imageNamed:anImageName];
}

//----------------------------------------------------------------------

- (instancetype) initCardType:(RKCardType)aCardType withCountry:(RKCountry *)aCountry imageNamed:(NSString *)anImageName
{
    if (self = [super init]) {
        country = aCountry; // Country can be nil.
        cardType = aCardType;
        if (![anImageName.pathExtension isEqualToString:@""]) {
            imageName = anImageName.stringByDeletingPathExtension;
        } else {
            imageName = [anImageName copy];
        }
        
        NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
        NSAssert (thisBundle != nil, @"Could not get this bundle.");
        
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
    RKCountry *tmpCountry = [aDecoder decodeObjectOfClass:[RKCountry class] forKey:RKCountryKey];
    NSString *imgNam = [aDecoder decodeObjectOfClass:[NSString class] forKey:RKImageNameKey];
    RKCardType ct = [aDecoder decodeIntForKey:RKCardTypeKey];
    
    return [self initCardType:ct withCountry:tmpCountry imageNamed:imgNam];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
