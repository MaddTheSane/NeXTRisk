//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: RiskUtility.m,v 1.2 1997/12/09 08:10:23 nygard Exp $");

#import "RiskUtility.h"

#import <RiskKit/RKCountry.h>
#import "CountryShape.h"
#import "CountryShapeGenerator.h"
#import "RiskMapView.h"
#import <RiskKit/RKNeighbor.h>
#import <RiskKit/RiskKit-Swift.h>
#import "RiskWorld.h"
#import <RiskKit/RKContinent.h>
#import <RiskKit/RKCard.h>
#import "RiskUtil-Swift.h"

@implementation RiskUtility

//
// Interesting -- The old version of Risk that I have compiled has
// Greenland in three regions and Quebec in one.  However, the data
// structures from the RiskUtil that generated it has Quebec with
// 3 regions, and Greenland with one.
//
// I'm going with Quebec with three.
//

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SNUserPath setUpVersions];
        [RiskPoint setUpVersions];
    });
}

//----------------------------------------------------------------------

- (void) applicationDidFinishLaunching:(NSNotification *)aNotificaiton
{
    NSMutableDictionary *continentBonuses;
    NSSet *continentNames;
    NSArray *countryArray;
    NSView *tmp1, *tmp2;
    
    // Make sure map view is below all other views.
    tmp1 = [riskMapView superview];
    tmp2 = riskMapView;
    [tmp2 removeFromSuperview];
    [tmp1 addSubview:tmp2 positioned:NSWindowBelow relativeTo:nil];
    
    continentBonuses = [[RiskUtility readContinentTextfile] mutableCopy];
    
    continentNames = [NSSet setWithArray:[continentBonuses allKeys]];
    
    // 1. read country data
    countryArray = [RiskUtility readCountryTextfile:continentNames];
    //NSLog (@"country array: %@", countryArray);
    
    // Create Continents
    continents = [RiskUtility buildContinents:continentBonuses fromCountries:countryArray];
    
    // 2. read country connections
    countryNeighbors = [RiskUtility readCountryNeighborsTextfile:countryArray];
    //NSLog (@"country neighbors: %@", countryNeighbors);
    
    [neighborTableView reloadData];
    [riskMapView setCountryArray:countryArray];
    //[riskMapView setNeedsDisplay:YES];
    
    // 3. Create cards.
    cards = [RiskUtility readCardTextfile:countryArray];
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
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.nameFieldStringValue = @"RiskWorld.data";
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSData *fileData;
            @autoreleasepool {
                fileData = [NSKeyedArchiver archivedDataWithRootObject:riskWorld];
            }
            if (!fileData) {
                NSBeep();
                
                return;
            }
            NSError *err = nil;
            if (![fileData writeToURL:[panel URL] options:NSDataWritingAtomic error:&err]) {
                [NSApp presentError:err];
            }
        }
    }];
}

//----------------------------------------------------------------------

+ (NSDictionary<NSString*,NSNumber*> *) readContinentTextfile
{
    NSBundle *mainBundle;
    NSMutableDictionary *dict;
    NSURL *path;
    NSString *fileContents;
    NSScanner *scanner;
    int value;
    
    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");
    
    dict = [NSMutableDictionary dictionary];
    
    path = [mainBundle URLForResource:@"ContinentData" withExtension:@"txt"];
    NSLog (@"path: %@", path.path);
    
    fileContents = [[NSString alloc] initWithContentsOfURL:path usedEncoding:NULL error:NULL];
    if (!fileContents)
        fileContents = [[NSString alloc] initWithContentsOfURL:path
                                                      encoding:NSASCIIStringEncoding
                                                         error:NULL];
    
    scanner = [NSScanner scannerWithString:fileContents];
    
    @try {
        while ([scanner scanString:@"Continent" intoString:NULL] == YES) {
            NSString *name = [scanner scanQuotedString];
            [scanner scanInt:&value];
            [dict setObject:@(value) forKey:name];
        }
    } @catch (NSException *localException) {
        NSLog (@"Exception %@: %@", [localException name], [localException reason]);
    }
    
    return dict;
}

//----------------------------------------------------------------------

+ (NSArray *) readCountryTextfile:(NSSet *)continentNames
{
    NSMutableArray *array;
    NSBundle *mainBundle;
    NSURL *path;
    NSString *fileContents;
    NSScanner *scanner;
    RKCountry *country;
    
    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");
    
    array = [NSMutableArray array];
    
    path = [mainBundle URLForResource:@"CountryData" withExtension:@"txt"];
    NSLog (@"path: %@", path.path);
    
    fileContents = [[NSString alloc] initWithContentsOfURL:path usedEncoding:NULL error:NULL];
    if (!fileContents)
        fileContents = [[NSString alloc] initWithContentsOfURL:path
                                                      encoding:NSASCIIStringEncoding
                                                         error:NULL];
    
    scanner = [NSScanner scannerWithString:fileContents];
    
    while ((country = [RiskUtility scanCountry:scanner validContinents:continentNames]))
    {
        [array addObject:country];
    }
    
    return array;
}

//----------------------------------------------------------------------

+ (NSMutableArray *) readCountryNeighborsTextfile:(NSArray<RKCountry*> *)countries
{
    NSMutableArray<RKNeighbor*> *array;
    NSBundle *mainBundle;
    NSURL *path;
    NSString *fileContents;
    NSScanner *scanner;
    RKNeighbor *riskNeighbor;
    NSMutableDictionary *countryDictionary;
    RKCountry *country;
    
    mainBundle = [NSBundle mainBundle];
    NSAssert (mainBundle != nil, @"main bundle nil");
    
    array = [[NSMutableArray alloc] init];
    
    // Set up country dictionary keyed on name
    countryDictionary = [NSMutableDictionary dictionary];
    for (country in countries)
    {
        [countryDictionary setObject:country forKey:[country countryName]];
    }
    
    path = [mainBundle URLForResource:@"CountryNeighbors" withExtension:@"txt"];
    NSLog (@"path: %@", path);
    
    fileContents = [[NSString alloc] initWithContentsOfURL:path usedEncoding:NULL error:NULL];
    if (!fileContents)
        fileContents = [[NSString alloc] initWithContentsOfURL:path
                                                      encoding:NSASCIIStringEncoding
                                                         error:NULL];
    
    scanner = [NSScanner scannerWithString:fileContents];
    
    while ((riskNeighbor = [RiskUtility scanRiskNeighbor:scanner usingCountries:countryDictionary]))
    {
        [array addObject:riskNeighbor];
    }
    
    return array;
}

//----------------------------------------------------------------------

+ (NSArray<RKCard*> *) readCardTextfile:(NSArray<RKCountry*> *)countryArray
{
    NSMutableArray<RKCard*> *array;
    NSBundle *mainBundle;
    NSURL *path;
    NSString *fileContents;
    NSScanner *scanner;
    RKCard *riskCard;
    NSMutableDictionary *countryDictionary;
    NSEnumerator<RKCountry *> *countryEnumerator;
    RKCountry *country;
    
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
    
    path = [mainBundle URLForResource:@"CardData" withExtension:@"txt"];
    NSLog (@"path: %@", path.path);
    
    fileContents = [[NSString alloc] initWithContentsOfURL:path usedEncoding:NULL error:NULL];
    if (!fileContents)
        fileContents = [[NSString alloc] initWithContentsOfURL:path
                                                      encoding:NSASCIIStringEncoding
                                                         error: NULL];
    
    scanner = [NSScanner scannerWithString:fileContents];
    
    while ((riskCard = [RiskUtility scanRiskCard:scanner usingCountries:countryDictionary]))
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
    NSMutableString *str;
    
    str = [[NSMutableString alloc] init];
    for (RKNeighbor *riskNeighbor in neighbors)
    {
        [str appendFormat:@"Adjacent\t\"%@\"\t\"%@\"\n",
         [[riskNeighbor country1] countryName],
         [[riskNeighbor country2] countryName]];
    }
    
    return [str copy];
}

//----------------------------------------------------------------------

+ (NSDictionary<NSString*,RKContinent*> *) buildContinents:(NSDictionary<NSString*,NSNumber*> *)continentBonuses fromCountries:(NSArray<RKCountry*> *)countries
{
    NSMutableDictionary *theContinents;
    NSMutableDictionary<NSString*,NSMutableSet*> *setDict;
    RKCountry *country;
    NSMutableSet *tmp;
    
    // 1. Build mutable arrays for continents
    
    setDict = [NSMutableDictionary dictionary];
    
    for (NSString *name in continentBonuses)
    {
        [setDict setObject:[NSMutableSet set] forKey:name];
    }
    
    for (country in countries)
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
    
    theContinents = [[NSMutableDictionary alloc] init];
    
    for (NSString *name in continentBonuses)
    {
        [theContinents setObject:[RKContinent continentWithName:name
                                                      countries:[setDict objectForKey:name]
                                                     bonusValue:[[continentBonuses objectForKey:name] intValue]]
                          forKey:name];
    }
    
    return theContinents;
}

//----------------------------------------------------------------------

- (id)init
{
    if (self = [super init]) {
        fromCountry = nil;
        toCountry = nil;
        
        continents = nil;
        countryNeighbors = nil;
        cards = nil;
    }
    
    return self;
}

//----------------------------------------------------------------------

+ (RKCountry *) scanCountry:(NSScanner *)scanner validContinents:(NSSet *)continentNames
{
    RKCountry *country;
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
    
    @try {
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
        while ([scanner scanString:@"Region" intoString:NULL] == YES) {
            [generator defineNewRegion];
            [scanner scanPoint:&aPoint];
            [generator addPoint:aPoint];
            while ([scanner scanString:@"," intoString:NULL] == YES) {
                [scanner scanPoint:&aPoint];
                [generator addPoint:aPoint];
            }
            [generator closeRegion];
        }
        shape = [generator generateCountryShapeWithArmyCellPoint:textFieldPoint];
        [scanner expect:@"End"];
        if ([continentNames containsObject:continentName] == NO) {
            NSLog (@"Continent %@ not found.", continentName);
        }
        
        country = [[RKCountry alloc] initWithCountryName:name
                                           continentName:continentName
                                                   shape:shape
                                               continent:continent];
        NSLog (@"=== Defined country: '%@'", name);
    } @catch (NSException *localException) {
        NSLog (@"Exception %@: %@", [localException name], [localException reason]);
    }
    
    return country;
}

//----------------------------------------------------------------------

+ (RKNeighbor *) scanRiskNeighbor:(NSScanner *)scanner usingCountries:(NSDictionary *)countries
{
    NSString *first;
    NSString *second;
    RKCountry *country1, *country2;
    
    RKNeighbor *riskNeighbor = nil;
    
    @try {
        [scanner expect:@"Adjacent"];
        first = [scanner scanQuotedString];
        second = [scanner scanQuotedString];
        
        country1 = [countries objectForKey:first];
        country2 = [countries objectForKey:second];
        riskNeighbor = [RKNeighbor riskNeighborWithCountries:country1:country2];
    } @catch (NSException *localException) {
        NSLog (@"Exception %@: %@", [localException name], [localException reason]);
    }
    
    return riskNeighbor;
}

//----------------------------------------------------------------------

+ (RiskContinent) continentFromString:(NSString *)str
{
    RiskContinent continent;
    
    if ([str isEqualToString:@"SouthAmerica"] == YES)
    {
        continent = RiskContinentSouthAmerica;
    }
    else if ([str isEqualToString:@"NorthAmerica"] == YES)
    {
        continent = RiskContinentNorthAmerica;
    }
    else if ([str isEqualToString:@"Europe"] == YES)
    {
        continent = RiskContinentEurope;
    }
    else if ([str isEqualToString:@"Africa"] == YES)
    {
        continent = RiskContinentAfrica;
    }
    else if ([str isEqualToString:@"Asia"] == YES)
    {
        continent = RiskContinentAsia;
    }
    else if ([str isEqualToString:@"Australia"] == YES)
    {
        continent = RiskContinentAustralia;
    }
    else
    {
        continent = RiskContinentUnknown;
    }
    
    return continent;
}

//----------------------------------------------------------------------

+ (RKCard *) scanRiskCard:(NSScanner *)scanner usingCountries:(NSDictionary *)countries
{
    RKCard *card = nil;
    NSString *countryName;
    NSString *cardType;
    NSString *imageName;
    RKCountry *country;
    
    @try {
        [scanner expect:@"Card"];
        countryName = [scanner scanQuotedString];
        cardType = [scanner scanString];
        imageName = [scanner scanQuotedString];
        
        country = [countries objectForKey:countryName];
        card = [[RKCard alloc] initCardType:[RiskUtility riskCardTypeFromString:cardType]
                                withCountry:country imageNamed:imageName];
    } @catch (NSException *localException) {
        NSLog (@"Exception %@: %@", [localException name], [localException reason]);
    }
    
    return card;
}

//----------------------------------------------------------------------

+ (RKCardType) riskCardTypeFromString:(NSString *)str
{
    RKCardType cardType;
    
    if ([str isEqualToString:@"Wildcard"] == YES)
    {
        cardType = RKCardWildcard;
    }
    else if ([str isEqualToString:@"Soldier"] == YES)
    {
        cardType = RKCardSoldier;
    }
    else if ([str isEqualToString:@"Cannon"] == YES)
    {
        cardType = RKCardCannon;
    }
    else if ([str isEqualToString:@"Cavalry"] == YES)
    {
        cardType = RKCardCavalry;
    }
    else
    {
        NSLog (@"Unknown card type: %@", str);
        cardType = RKCardSoldier;
    }
    
    return cardType;
}

//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry
{
    fromCountry = aCountry;
    [fromTextfield setStringValue:[aCountry countryName]];
}

//----------------------------------------------------------------------

- (void) mouseUp:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry
{
    NSInteger count;
    
    toCountry = aCountry;
    [toTextfield setStringValue:[aCountry countryName]];
    
    if (fromCountry != nil && toCountry != nil)
    {
        [countryNeighbors addObject:[RKNeighbor riskNeighborWithCountries:fromCountry:toCountry]];
        [neighborTableView reloadData];
        count = [countryNeighbors count];
        [neighborTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:count - 1] byExtendingSelection:NO];
        [neighborTableView scrollRowToVisible:count - 1];
        [riskMapView setNeedsDisplay:YES];
        // Otherwise the textfields will be obscured by the map view.
        [[riskMapView superview] setNeedsDisplay:YES];
    }
}

//----------------------------------------------------------------------

- (IBAction) removeNeighbor:(id)sender
{
    NSInteger index;
    
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
    NSString *neighborString = [RiskUtility neighborString:countryNeighbors];
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.nameFieldStringValue = @"CountryNeighbors.txt";
    panel.allowedFileTypes = @[@"txt"];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSError *err;
            
            if (![neighborString writeToURL:[panel URL] atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
                [[NSAlert alertWithError:err] runModal];
            }
        }
    }];
    
    NSLog (@"text file: %@", neighborString);
}

//----------------------------------------------------------------------

- (NSArray<RKNeighbor*> *) riskNeighbors
{
    return [countryNeighbors copy];
}

//======================================================================
// NSTableDataSource
//======================================================================

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger count;
    
    count = [countryNeighbors count];
    
    return count;
}

//----------------------------------------------------------------------

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *identifier;
    RKNeighbor *target;
    id value;
    
    NSParameterAssert (rowIndex >= 0 && rowIndex < [countryNeighbors count]);
    
    value = nil;
    
    target = [countryNeighbors objectAtIndex:rowIndex];
    identifier = [aTableColumn identifier];
    
    if ([identifier isEqualToString:@"Index"])
    {
        value = @(rowIndex + 1);
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
