//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskUtility.m,v 1.2 1997/12/09 08:10:23 nygard Exp $");

#import "RiskUtility.h"

#import "Country.h"
#import "CountryShape.h"
#import "CountryShapeGenerator.h"
#import "RiskMapView.h"
#import "RiskNeighbor.h"
#import "RiskWorld.h"
#import "Continent.h"
#import "RiskCard.h"

@implementation RiskUtility

//
// Interesting -- The old version of Risk that I have compiled has
// Greenland in three regions and Quebec in one.  However, the data
// structures from the RiskUtil that generated it has Quebec with
// 3 regions, and Greenland with one.
//
// I'm going with Quebec with three.
//

//----------------------------------------------------------------------

- (void) applicationDidFinishLaunching:(NSNotification *)aNotificaiton
{
    NSMutableDictionary *continentBonuses;
    NSSet *continentNames;
    NSArray *countryArray;
    NSView *tmp1, *tmp2;

    // Make sure map view is below all other views.
    tmp1 = [riskMapView superview];
    tmp2 = [riskMapView retain];
    [tmp2 removeFromSuperview];
    [tmp1 addSubview:tmp2 positioned:NSWindowBelow relativeTo:nil];
    [tmp2 release];

    continentBonuses = [[RiskUtility readContinentTextfile] mutableCopy];

    continentNames = [NSSet setWithArray:[continentBonuses allKeys]];

    // 1. read country data
    countryArray = [[RiskUtility readCountryTextfile:continentNames] retain];
    //NSLog (@"country array: %@", countryArray);

    // Create Continents
    continents = [[RiskUtility buildContinents:continentBonuses fromCountries:countryArray] retain];

    // 2. read country connections
    countryNeighbors = [[RiskUtility readCountryNeighborsTextfile:countryArray] retain];
    //NSLog (@"country neighbors: %@", countryNeighbors);

    [neighborTableView reloadData];
    [riskMapView setCountryArray:countryArray];
    //[riskMapView setNeedsDisplay:YES];

    // 3. Create cards.
    cards = [[RiskUtility readCardTextfile:countryArray] retain];
}

//----------------------------------------------------------------------

- (IBAction) saveWorld:(id)sender
{
    RiskWorld *riskWorld;

    riskWorld = [RiskWorld riskWorldWithContinents:continents countryNeighbors:countryNeighbors cards:cards];

    [self writeRiskWorld:riskWorld];
}

//----------------------------------------------------------------------

- (void) writeRiskWorld:(RiskWorld *)riskWorld
{
    NSBundle *mainBundle;
    NSString *path;
    NSString *targetFile;
    BOOL rflag;

    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");

    path = [mainBundle bundlePath];
    targetFile = [path stringByAppendingPathComponent:@"RiskWorld.data"];
    NSLog (@"target file: %@", targetFile);

    rflag = [NSArchiver archiveRootObject:riskWorld toFile:targetFile];
    NSAssert1 (rflag == YES, @"could not archive risk world to file: '%@'", targetFile);
}

//----------------------------------------------------------------------

+ (NSDictionary *) readContinentTextfile
{
    NSBundle *mainBundle;
    NSMutableDictionary *dict;
    NSString *path;
    NSString *fileContents;
    NSScanner *scanner;
    NSString *name;
    int value;

    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");

    dict = [NSMutableDictionary dictionary];

    path = [mainBundle pathForResource:@"ContinentData" ofType:@"txt"];
    NSLog (@"path: %@", path);

    fileContents = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path]
                                      encoding:NSASCIIStringEncoding] autorelease];

    scanner = [NSScanner scannerWithString:fileContents];

    NS_DURING
        {
            while ([scanner scanString:@"Continent" intoString:NULL] == YES)
            {
                name = [scanner scanQuotedString];
                [scanner scanInt:&value];
                [dict setObject:[NSNumber numberWithInt:value] forKey:name];
            }
        }
    NS_HANDLER
        {
            NSLog (@"Exception %@: %@", [localException name], [localException reason]);
        }
    NS_ENDHANDLER;

    return dict;
}

//----------------------------------------------------------------------

+ (NSArray *) readCountryTextfile:(NSSet *)continentNames
{
    NSMutableArray *array;
    NSBundle *mainBundle;
    NSString *path;
    NSString *fileContents;
    NSScanner *scanner;
    Country *country;

    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");

    array = [NSMutableArray array];

    path = [mainBundle pathForResource:@"CountryData" ofType:@"txt"];
    NSLog (@"path: %@", path);

    fileContents = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path]
                                      encoding:NSASCIIStringEncoding] autorelease];

    scanner = [NSScanner scannerWithString:fileContents];

    while (country = [RiskUtility scanCountry:scanner validContinents:continentNames])
    {
        [array addObject:country];
    }

    return array;
}

//----------------------------------------------------------------------

+ (NSMutableArray *) readCountryNeighborsTextfile:(NSArray *)countries
{
    NSMutableArray *array;
    NSBundle *mainBundle;
    NSString *path;
    NSString *fileContents;
    NSScanner *scanner;
    RiskNeighbor *riskNeighbor;
    NSMutableDictionary *countryDictionary;
    NSEnumerator *countryEnumerator;
    Country *country;

    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");

    array = [NSMutableArray array];

    // Set up country dictionary keyed on name
    countryDictionary = [NSMutableDictionary dictionary];
    countryEnumerator = [countries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        [countryDictionary setObject:country forKey:[country countryName]];
    }

    path = [mainBundle pathForResource:@"CountryNeighbors" ofType:@"txt"];
    NSLog (@"path: %@", path);

    fileContents = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path]
                                      encoding:NSASCIIStringEncoding] autorelease];

    scanner = [NSScanner scannerWithString:fileContents];

    while (riskNeighbor = [RiskUtility scanRiskNeighbor:scanner usingCountries:countryDictionary])
    {
        [array addObject:riskNeighbor];
    }

    return array;
}

//----------------------------------------------------------------------

+ (NSArray *) readCardTextfile:(NSArray *)countryArray
{
    NSMutableArray *array;
    NSBundle *mainBundle;
    NSString *path;
    NSString *fileContents;
    NSScanner *scanner;
    RiskCard *riskCard;
    NSMutableDictionary *countryDictionary;
    NSEnumerator *countryEnumerator;
    Country *country;

    DSTART;

    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");

    array = [NSMutableArray array];

    // Set up country dictionary keyed on name
    countryDictionary = [NSMutableDictionary dictionary];
    countryEnumerator = [countryArray objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        [countryDictionary setObject:country forKey:[country countryName]];
    }

    path = [mainBundle pathForResource:@"CardData" ofType:@"txt"];
    NSLog (@"path: %@", path);

    fileContents = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path]
                                      encoding:NSASCIIStringEncoding] autorelease];

    scanner = [NSScanner scannerWithString:fileContents];

    while (riskCard = [RiskUtility scanRiskCard:scanner usingCountries:countryDictionary])
    {
        [array addObject:riskCard];
    }

    NSLog (@"array: %@", array);

    DEND;

    return array;
}

//----------------------------------------------------------------------

+ (NSString *) neighborString:(NSArray *)neighbors
{
    NSEnumerator *neighborEnumerator;
    RiskNeighbor *riskNeighbor;
    NSMutableString *str;

    str = [NSMutableString string];
    neighborEnumerator = [neighbors objectEnumerator];
    while (riskNeighbor = [neighborEnumerator nextObject])
    {
        [str appendFormat:@"Adjacent\t\"%@\"\t\"%@\"\n",
             [[riskNeighbor country1] countryName],
             [[riskNeighbor country2] countryName]];
    }

    return str;
}

//----------------------------------------------------------------------

+ (NSDictionary *) buildContinents:(NSDictionary *)continentBonuses fromCountries:(NSArray *)countries
{
    NSMutableDictionary *theContinents;
    NSMutableDictionary *setDict;
    NSEnumerator *continentNameEnumerator, *countryEnumerator;
    NSString *name;
    Country *country;
    NSMutableArray *tmp;

    // 1. Build mutable arrays for continents

    setDict = [NSMutableDictionary dictionary];

    continentNameEnumerator = [[continentBonuses allKeys] objectEnumerator];
    while (name = [continentNameEnumerator nextObject])
    {
        [setDict setObject:[NSMutableSet set] forKey:name];
    }

    countryEnumerator = [countries objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        tmp = [setDict objectForKey:[country continentName]];
        if (tmp == nil)
        {
            NSLog (@"Could not find continent for country: %@", country);
        }
        else
        {
            [tmp addObject:country];
        }
    }

    theContinents = [NSMutableDictionary dictionary];

    continentNameEnumerator = [[continentBonuses allKeys] objectEnumerator];
    while (name = [continentNameEnumerator nextObject])
    {
        [theContinents setObject:[Continent continentWithName:name
                                            countries:[setDict objectForKey:name]
                                            bonusValue:[[continentBonuses objectForKey:name] intValue]]
                       forKey:name];
    }

    return theContinents;
}

//----------------------------------------------------------------------

- init
{
    [super init];

    fromCountry = nil;
    toCountry = nil;

    continents = nil;
    countryNeighbors = nil;
    cards = nil;

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (continents);
    SNRelease (countryNeighbors);
    SNRelease (cards);

    [super dealloc];
}

//----------------------------------------------------------------------

+ (Country *) scanCountry:(NSScanner *)scanner validContinents:(NSSet *)continentNames
{
    Country *country;
    CountryShape *shape;
    NSString *name;
    NSPoint aPoint;
    RiskContinent continent;
    NSPoint textFieldPoint;
    NSString *continentName;

    CountryShapeGenerator *generator;
    
    country = nil;
    shape = nil;
    name = nil;

    NS_DURING
        {
            [scanner expect:@"Country"];
            name = [scanner scanQuotedString];
            [scanner expect:@"Tag"];
            [scanner scanString];
            [scanner expect:@"Continent"];
            continentName = [scanner scanQuotedString];
            continent = [self continentFromString:continentName];
            [scanner expect:@"ArmyTFLoc"];
            [scanner scanPoint:&textFieldPoint];
            generator = [CountryShapeGenerator countryShapeGenerator];
            while ([scanner scanString:@"Region" intoString:NULL] == YES)
            {
                [generator defineNewRegion];
                [scanner scanPoint:&aPoint];
                [generator addPoint:aPoint];
                while ([scanner scanString:@"," intoString:NULL] == YES)
                {
                    [scanner scanPoint:&aPoint];
                    [generator addPoint:aPoint];
                }
                [generator closeRegion];
            }
            shape = [generator generateCountryShapeWithArmyCellPoint:textFieldPoint];
            [scanner expect:@"End"];
            if ([continentNames containsObject:continentName] == NO)
            {
                NSLog (@"Continent %@ not found.", continentName);
            }
            
            country = [[[Country alloc] initWithCountryName:name
                                        continentName:continentName
                                        shape:shape
                                        continent:continent] autorelease];
            NSLog (@"=== Defined country: '%@'", name);
        }
    NS_HANDLER
        {
            NSLog (@"Exception %@: %@", [localException name], [localException reason]);
        }
    NS_ENDHANDLER;

    return country;
}

//----------------------------------------------------------------------

+ (RiskNeighbor *) scanRiskNeighbor:(NSScanner *)scanner usingCountries:(NSDictionary *)countries
{
    NSString *first;
    NSString *second;
    Country *country1, *country2;
    
    RiskNeighbor *riskNeighbor;

    riskNeighbor = nil;

    NS_DURING
        {
            [scanner expect:@"Adjacent"];
            first = [scanner scanQuotedString];
            second = [scanner scanQuotedString];

            country1 = [countries objectForKey:first];
            country2 = [countries objectForKey:second];
            riskNeighbor = [RiskNeighbor riskNeighborWithCountries:country1:country2];
        }
    NS_HANDLER
        {
            NSLog (@"Exception %@: %@", [localException name], [localException reason]);
        }
    NS_ENDHANDLER;

    return riskNeighbor;
}

//----------------------------------------------------------------------

+ (RiskContinent) continentFromString:(NSString *)str
{
    RiskContinent continent;

    if ([str isEqualToString:@"SouthAmerica"] == YES)
    {
        continent = SouthAmerica;
    }
    else if ([str isEqualToString:@"NorthAmerica"] == YES)
    {
        continent = NorthAmerica;
    }
    else if ([str isEqualToString:@"Europe"] == YES)
    {
        continent = Europe;
    }
    else if ([str isEqualToString:@"Africa"] == YES)
    {
        continent = Africa;
    }
    else if ([str isEqualToString:@"Asia"] == YES)
    {
        continent = Asia;
    }
    else if ([str isEqualToString:@"Australia"] == YES)
    {
        continent = Australia;
    }
    else
    {
        continent = Unknown;
    }

    return continent;
}

//----------------------------------------------------------------------

+ (RiskCard *) scanRiskCard:(NSScanner *)scanner usingCountries:(NSDictionary *)countries
{
    RiskCard *card;
    NSString *countryName;
    NSString *cardType;
    NSString *imageName;
    Country *country;
    
    card = nil;

    NS_DURING
        {
            [scanner expect:@"Card"];
            countryName = [scanner scanQuotedString];
            cardType = [scanner scanString];
            imageName = [scanner scanQuotedString];

            country = [countries objectForKey:countryName];
            card = [[[RiskCard alloc] initCardType:[RiskUtility riskCardTypeFromString:cardType]
                                      withCountry:country imageNamed:imageName] autorelease];
        }
    NS_HANDLER
        {
            NSLog (@"Exception %@: %@", [localException name], [localException reason]);
        }
    NS_ENDHANDLER;

    return card;
}

//----------------------------------------------------------------------

+ (RiskCardType) riskCardTypeFromString:(NSString *)str
{
    RiskCardType cardType;

    if ([str isEqualToString:@"Wildcard"] == YES)
    {
        cardType = Wildcard;
    }
    else if ([str isEqualToString:@"Soldier"] == YES)
    {
        cardType = Soldier;
    }
    else if ([str isEqualToString:@"Cannon"] == YES)
    {
        cardType = Cannon;
    }
    else if ([str isEqualToString:@"Cavalry"] == YES)
    {
        cardType = Cavalry;
    }
    else
    {
        NSLog (@"Unknown card type: %@", str);
        cardType = Soldier;
    }

    return cardType;
}

//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry
{
    fromCountry = aCountry;
    [fromTextfield setStringValue:[aCountry countryName]];
}

//----------------------------------------------------------------------

- (void) mouseUp:(NSEvent *)theEvent inCountry:(Country *)aCountry
{
    int count;

    toCountry = aCountry;
    [toTextfield setStringValue:[aCountry countryName]];

    if (fromCountry != nil && toCountry != nil)
    {
        [countryNeighbors addObject:[RiskNeighbor riskNeighborWithCountries:fromCountry:toCountry]];
        [neighborTableView reloadData];
        count = [countryNeighbors count];
        [neighborTableView selectRow:count - 1 byExtendingSelection:NO];
        [neighborTableView scrollRowToVisible:count - 1];
        [riskMapView setNeedsDisplay:YES];
        // Otherwise the textfields will be obscured by the map view.
        [[riskMapView superview] setNeedsDisplay:YES];
    }
}

//----------------------------------------------------------------------

- (IBAction) removeNeighbor:(id)sender
{
    int index;
    
    index = [neighborTableView selectedRow];
    if (index >= 0)
    {
        [countryNeighbors removeObjectAtIndex:index];
        [neighborTableView reloadData];
        [riskMapView setNeedsDisplay:YES];
        // Otherwise the textfields will be obscured by the map view.
        [[riskMapView superview] setNeedsDisplay:YES];
    }
}

//----------------------------------------------------------------------

- (IBAction) writeNeighborTextFile:(id)sender
{
    NSBundle *mainBundle;
    NSString *path;
    NSString *neighborString;
    NSFileHandle *fileHandle;

    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");

    path = [mainBundle pathForResource:@"CountryNeighbors" ofType:@"txt"];
    NSAssert (path != nil, @"path nil");

    neighborString = [RiskUtility neighborString:countryNeighbors];

    fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    NSAssert (fileHandle != nil, @"file handle nil");

    [fileHandle writeData:[neighborString dataUsingEncoding:NSASCIIStringEncoding]];

    // The NSFileHandle class is so non-functional that it is almost completely devoid of use.
    // Nevertheless...
    [fileHandle truncateFileAtOffset:[fileHandle offsetInFile]];

    [fileHandle closeFile];

    NSLog (@"text file: %@", neighborString);
}

//----------------------------------------------------------------------

- (NSArray *) riskNeighbors
{
    return countryNeighbors;
}

//======================================================================
// NSTableDataSource
//======================================================================

- (int) numberOfRowsInTableView:(NSTableView *)aTableView
{
    int count;

    count = [countryNeighbors count];

    return count;
}

//----------------------------------------------------------------------

- tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSString *identifier;
    RiskNeighbor *target;
    id value;

    NSParameterAssert (rowIndex >= 0 && rowIndex < [countryNeighbors count]);

    value = nil;

    target = [countryNeighbors objectAtIndex:rowIndex];
    identifier = [aTableColumn identifier];

    if ([identifier isEqualToString:@"Index"])
    {
        value = [NSNumber numberWithInt:rowIndex + 1];
    }
    else if ([identifier isEqualToString:@"Country1"])
    {
        value = [[target country1] countryName];
    }
    else if ([identifier isEqualToString:@"Country2"])
    {
        value = [[target country2] countryName];
    }

    return value;
}

@end
