//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: BoardSetup.m,v 1.3 1997/12/15 07:43:37 nygard Exp $");

#import "BoardSetup.h"

//======================================================================
// The BoardSetup defines what the main board and the status view will
// look like.
//======================================================================

static BoardSetup *_instance = nil;

// Notifications are sent when the preferences are changed, so that
// objects that use these defaults can be updated.

DEFINE_NSSTRING (RiskBoardSetupChangedNotification);
DEFINE_NSSTRING (RiskBoardSetupPlayerColorsChangedNotification);
DEFINE_NSSTRING (RiskBoardSetupShowCardSetCountsChangedNotification);

void setColorForDefault (NSColor *value, NSString *key)
{
    [[NSUserDefaults standardUserDefaults] setObject:defaultsDataForColor (value) forKey:key];
}

//----------------------------------------------------------------------

NSColor *getColorForDefault (NSString *key)
{
    NSData *data;
    NSColor *color;

    data = [[NSUserDefaults standardUserDefaults] dataForKey:key];
    if (data == nil)
        color = [NSColor blackColor];
    else
        color = [NSUnarchiver unarchiveObjectWithData:data];

    return color;
}

//----------------------------------------------------------------------

NSData *defaultsDataForColor (NSColor *color)
{
    return [NSArchiver archivedDataWithRootObject:color];
}

//======================================================================

#define BoardSetup_VERSION 1

@implementation BoardSetup
@synthesize borderWidth;
@synthesize regularBorderColor;
@synthesize selectedBorderColor;
@synthesize showCardSetCounts;

+ instance
{
    if (_instance == nil)
    {
        _instance = [[BoardSetup alloc] init];
    }

    return _instance;
}

//----------------------------------------------------------------------

+ (void) initialize
{
    NSUserDefaults *defaults;
    NSMutableDictionary *boardDefaults;
    NSColor *color;
    
    // Set up the defaults.
    if (self == [BoardSetup class])
    {
        [self setVersion:BoardSetup_VERSION];
        
        defaults = [NSUserDefaults standardUserDefaults];
        boardDefaults = [NSMutableDictionary dictionary];

        //color = [NSColor colorWithCalibratedRed:0.9  green:0.9  blue:0.9  alpha:1.0];
        color = [NSColor greenColor];
        [boardDefaults setObject:defaultsDataForColor (color) forKey:DK_DefaultPlayer1Color];

        //color = [NSColor colorWithCalibratedRed:0.8  green:0.8  blue:0.8  alpha:1.0];
        color = [NSColor blueColor];
        [boardDefaults setObject:defaultsDataForColor (color) forKey:DK_DefaultPlayer2Color];

        //color = [NSColor colorWithCalibratedRed:0.66 green:0.66 blue:0.66 alpha:1.0];
        color = [NSColor yellowColor];
        [boardDefaults setObject:defaultsDataForColor (color) forKey:DK_DefaultPlayer3Color];

        //color = [NSColor colorWithCalibratedRed:0.33 green:0.33 blue:0.33 alpha:1.0];
        color = [NSColor purpleColor];
        [boardDefaults setObject:defaultsDataForColor (color) forKey:DK_DefaultPlayer4Color];

        //color = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0];
        color = [NSColor cyanColor];
        [boardDefaults setObject:defaultsDataForColor (color) forKey:DK_DefaultPlayer5Color];

        //color = [NSColor colorWithCalibratedRed:0.0  green:0.0  blue:0.0  alpha:1.0];
        color = [NSColor redColor];
        [boardDefaults setObject:defaultsDataForColor (color) forKey:DK_DefaultPlayer6Color];

        [boardDefaults setObject:@"1" forKey:DK_BorderWidth];

        color = [NSColor blackColor];
        [boardDefaults setObject:defaultsDataForColor (color) forKey:DK_RegularBorderColor];

        color = [NSColor whiteColor];
        [boardDefaults setObject:defaultsDataForColor (color) forKey:DK_SelectedBorderColor];

        [boardDefaults setObject:@"YES" forKey:DK_ShowCardSetCounts];

        [defaults registerDefaults:boardDefaults];
    }
}

//----------------------------------------------------------------------

- init
{
    int l;

    if ([super init] == nil)
        return nil;

    borderWidth = 0.15;
    regularBorderColor = [[NSColor blackColor] retain];;
    selectedBorderColor = [[NSColor whiteColor] retain];;

    for (l = 0; l < 7; l++)
        playerColors[l] = nil;

    [self revertAllToDefaults];

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [super dealloc];
}

//----------------------------------------------------------------------

// The defaults are split into two parts since there are two different
// panels to set them, and they should be set independantly.

- (void) writeAllDefaults
{
    [self writePlayerColorDefaults];
    [self writeOtherDefaults];
}

//----------------------------------------------------------------------

- (void) writePlayerColorDefaults
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:defaultsDataForColor (playerColors[1]) forKey:DK_DefaultPlayer1Color];
    [defaults setObject:defaultsDataForColor (playerColors[2]) forKey:DK_DefaultPlayer2Color];
    [defaults setObject:defaultsDataForColor (playerColors[3]) forKey:DK_DefaultPlayer3Color];
    [defaults setObject:defaultsDataForColor (playerColors[4]) forKey:DK_DefaultPlayer4Color];
    [defaults setObject:defaultsDataForColor (playerColors[5]) forKey:DK_DefaultPlayer5Color];
    [defaults setObject:defaultsDataForColor (playerColors[6]) forKey:DK_DefaultPlayer6Color];

    [defaults synchronize];
}

//----------------------------------------------------------------------

- (void) writeOtherDefaults
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:defaultsDataForColor (regularBorderColor) forKey:DK_RegularBorderColor];
    [defaults setObject:defaultsDataForColor (selectedBorderColor) forKey:DK_SelectedBorderColor];

    [defaults setFloat:borderWidth forKey:DK_BorderWidth];
    [defaults setBool:showCardSetCounts forKey:DK_ShowCardSetCounts];

    [defaults synchronize];
}

//----------------------------------------------------------------------

- (void) revertAllToDefaults
{
    [self revertPlayerColorsToDefaults];
    [self revertOtherToDefaults];
}

//----------------------------------------------------------------------

- (void) revertPlayerColorsToDefaults
{
    NSUserDefaults *defaults;
    int l;

    defaults = [NSUserDefaults standardUserDefaults];

    for (l = 1; l < 7; l++)
    {
        SNRelease (playerColors[l]);
    }

    playerColors[1] = [getColorForDefault (DK_DefaultPlayer1Color) retain];
    playerColors[2] = [getColorForDefault (DK_DefaultPlayer2Color) retain];
    playerColors[3] = [getColorForDefault (DK_DefaultPlayer3Color) retain];
    playerColors[4] = [getColorForDefault (DK_DefaultPlayer4Color) retain];
    playerColors[5] = [getColorForDefault (DK_DefaultPlayer5Color) retain];
    playerColors[6] = [getColorForDefault (DK_DefaultPlayer6Color) retain];

    // Notify of updated defaults.
    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupPlayerColorsChangedNotification
                                          object:self];
}

//----------------------------------------------------------------------

- (void) revertOtherToDefaults
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    borderWidth = [defaults floatForKey:DK_BorderWidth];

    SNRelease (regularBorderColor);
    regularBorderColor = [getColorForDefault (DK_RegularBorderColor) retain];

    SNRelease (selectedBorderColor);
    selectedBorderColor = [getColorForDefault (DK_SelectedBorderColor) retain];

    showCardSetCounts = [defaults boolForKey:DK_ShowCardSetCounts];

    // Notify of updated defaults.
    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupChangedNotification
                                          object:self];

    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupShowCardSetCountsChangedNotification
                                          object:self];
}

//----------------------------------------------------------------------

- (void) setBorderWidth:(CGFloat)newWidth
{
    borderWidth = newWidth;

    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupChangedNotification
                                          object:self];
}

//----------------------------------------------------------------------

- (void) setRegularBorderColor:(NSColor *)newColor
{
    if (newColor == regularBorderColor)
        return;

    SNRelease (regularBorderColor);
    regularBorderColor = [newColor retain];

    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupChangedNotification
                                          object:self];
}

//----------------------------------------------------------------------

- (void) setSelectedBorderColor:(NSColor *)newColor
{
    if (newColor == selectedBorderColor)
        return;

    SNRelease (selectedBorderColor);
    selectedBorderColor = [newColor retain];

    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupChangedNotification
                                          object:self];
}

//----------------------------------------------------------------------

- (void) setShowCardSetCounts:(BOOL)newFlag
{
    showCardSetCounts = newFlag;

    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupShowCardSetCountsChangedNotification
                                          object:self];
}

//----------------------------------------------------------------------

- (NSColor *) colorForPlayer:(Player)playerNumber
{
    NSAssert (playerNumber > 0 && playerNumber < 7, @"Player number out of range.");
    
    return playerColors[playerNumber];
}

//----------------------------------------------------------------------

- (void) setColor:(NSColor *)aColor forPlayer:(Player)playerNumber
{
    NSAssert (playerNumber > 0 && playerNumber < 7, @"Player number out of range.");

    SNRelease (playerColors[playerNumber]);
    playerColors[playerNumber] = [aColor retain];

    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupPlayerColorsChangedNotification
                                          object:self];
}

@end
