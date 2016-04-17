//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: WorldInfoController.m,v 1.1.1.1 1997/12/09 07:18:58 nygard Exp $");

#import "WorldInfoController.h"

#import "RiskWorld.h"
#import "Continent.h"
#import "Country.h"

//======================================================================
// The World Info report shows the name of the world, and the name,
// number of countries, and bonus value for each continent.
//
// Double click on the column titles to sort by that column.
//======================================================================

NSInteger WIOrderContinentsByName (id object1, id object2, void *context)
{
    Continent *continent1, *continent2;
    NSComparisonResult result;

    continent1 = (Continent *)object1;
    continent2 = (Continent *)object2;

    result = [continent1.continentName compare:continent2.continentName];

    return result;
}

//----------------------------------------------------------------------

NSInteger WIOrderContinentsByCountryCount (id object1, id object2, void *context)
{
    Continent *continent1, *continent2;
    NSComparisonResult result;
    NSInteger count1, count2;

    continent1 = (Continent *)object1;
    continent2 = (Continent *)object2;

    count1 = continent1.countries.count;
    count2 = continent2.countries.count;

    if (count1 < count2)
    {
        result = NSOrderedAscending;
    }
    else if (count1 == count2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }

    return result;
}

//----------------------------------------------------------------------

NSInteger WIOrderContinentsByBonusValue (id object1, id object2, void *context)
{
    Continent *continent1, *continent2;
    NSComparisonResult result;
    int count1, count2;

    continent1 = (Continent *)object1;
    continent2 = (Continent *)object2;

    count1 = continent1.continentBonus;
    count2 = continent2.continentBonus;

    if (count1 < count2)
    {
        result = NSOrderedAscending;
    }
    else if (count1 == count2)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedDescending;
    }

    return result;
}

#define WorldInfoController_VERSION 1

@implementation WorldInfoController

+ (void) initialize
{
    if (self == [WorldInfoController class])
    {
        [self setVersion:WorldInfoController_VERSION];
    }
}

//----------------------------------------------------------------------

- (void) awakeFromNib
{
    NSImage *image;

    //imagePath = [[NSBundle mainBundle] pathForImageResource:@"MiniWorldInfo.tiff"];
    //NSAssert (imagePath != nil, @"Couldn't find MiniWorldInfo.tiff");

    image = [NSImage imageNamed:@"MiniWorldInfo"];
    NSAssert (image != nil, @"Couldn't load MiniWorldInfo");

    worldInfoWindow.miniwindowImage = image;
}

//----------------------------------------------------------------------

- (instancetype) init
{
    BOOL loaded, okay;
    NSString *nibFile;

    if (self = [super init]) {
        nibFile = @"WorldInfoPanel.nib";
        loaded = [NSBundle loadNibNamed:nibFile owner:self];
        if (loaded == NO)
        {
            NSLog (@"Could not load %@.", nibFile);
            return nil;
        }

        continentTable.doubleAction = @selector (reorder:);
        continentTable.target = self;

        continents = nil;
        //world = nil;

        okay = [worldInfoWindow setFrameAutosaveName:worldInfoWindow.title];
        if (okay == NO)
            NSLog (@"Could not set frame autosave name of World Info window.");
    }

    return self;
}

//----------------------------------------------------------------------
#if 0
- (RiskWorld *) world
{
    return world;
}
#endif
//----------------------------------------------------------------------

- (void) setWorld:(RiskWorld *)newWorld
{
    SNRelease (continents);
    if (newWorld != nil)
    {
        continents = [newWorld.continents.allValues sortedArrayUsingFunction:WIOrderContinentsByName context:NULL];
    }
#if 0
    SNRelease (world);

    world = [newWorld retain];
#endif
    [continentTable reloadData];
}

//----------------------------------------------------------------------

- (void) showPanel
{
    [worldInfoWindow orderFront:self];
}

//----------------------------------------------------------------------

- (void) orderByName
{
    NSArray *newOrder;

    if (continents != nil)
    {
        newOrder = [continents sortedArrayUsingFunction:WIOrderContinentsByName context:NULL];
        continents = newOrder;
        [continentTable reloadData];
    }
}

//----------------------------------------------------------------------

- (void) orderByCountryCount
{
    NSArray *newOrder;

    if (continents != nil)
    {
        newOrder = [continents sortedArrayUsingFunction:WIOrderContinentsByCountryCount context:NULL];
        continents = newOrder;
        [continentTable reloadData];
    }
}

//----------------------------------------------------------------------

- (void) orderByBonusValue
{
    NSArray *newOrder;

    if (continents != nil)
    {
        newOrder = [continents sortedArrayUsingFunction:WIOrderContinentsByBonusValue context:NULL];
        continents = newOrder;
        [continentTable reloadData];
    }
}

//----------------------------------------------------------------------

- (IBAction) reorder:(id)sender
{
    NSString *identifier;

    identifier = continentTable.tableColumns[continentTable.clickedColumn].identifier;

    if ([identifier isEqualToString:@"ContinentName"])
    {
        [self orderByName];
    }
    else if ([identifier isEqualToString:@"CountryCount"])
    {
        [self orderByCountryCount];
    }
    else if ([identifier isEqualToString:@"BonusValue"])
    {
        [self orderByBonusValue];
    }
}

//======================================================================
// NSTableView data source
//======================================================================

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger count = 0;

    if (continents != nil)
        count = continents.count;

    return count;
}

//----------------------------------------------------------------------

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *identifier;
    Continent *target;
    id value;

    //NSParameterAssert (rowIndex >= 0 && rowIndex < [mes count]);

    value = nil;

    target = continents[rowIndex];
    identifier = aTableColumn.identifier;

    if ([identifier isEqualToString:@"ContinentName"])
    {
        value = target.continentName;
    }
    else if ([identifier isEqualToString:@"CountryCount"])
    {
        value = @(target.countries.count);
    }
    else if ([identifier isEqualToString:@"BonusValue"])
    {
        value = @(target.continentBonus);
    }

    return value;
}

@end
