//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: BoardSetup.m,v 1.3 1997/12/15 07:43:37 nygard Exp $");

#import "BoardSetup.h"

#import <Cocoa/Cocoa.h>

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
    if (self == [BoardSetup class])
    {
        [self setVersion:BoardSetup_VERSION];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults;
        NSMutableDictionary *boardDefaults;
        NSColor *color;
        
        // Set up the defaults.
        defaults = [NSUserDefaults standardUserDefaults];
        boardDefaults = [[NSMutableDictionary alloc] init];
        
        //color = [NSColor colorWithCalibratedRed:0.9  green:0.9  blue:0.9  alpha:1.0];
        color = [NSColor greenColor];
        boardDefaults[DK_DefaultPlayer1Color] = defaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.8  green:0.8  blue:0.8  alpha:1.0];
        color = [NSColor blueColor];
        boardDefaults[DK_DefaultPlayer2Color] = defaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.66 green:0.66 blue:0.66 alpha:1.0];
        color = [NSColor yellowColor];
        boardDefaults[DK_DefaultPlayer3Color] = defaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.33 green:0.33 blue:0.33 alpha:1.0];
        color = [NSColor purpleColor];
        boardDefaults[DK_DefaultPlayer4Color] = defaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0];
        color = [NSColor cyanColor];
        boardDefaults[DK_DefaultPlayer5Color] = defaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.0  green:0.0  blue:0.0  alpha:1.0];
        color = [NSColor redColor];
        boardDefaults[DK_DefaultPlayer6Color] = defaultsDataForColor (color);
        
        boardDefaults[DK_BorderWidth] = @1;
        
        color = [NSColor blackColor];
        boardDefaults[DK_RegularBorderColor] = defaultsDataForColor (color);
        
        color = [NSColor whiteColor];
        boardDefaults[DK_SelectedBorderColor] = defaultsDataForColor (color);
        
        boardDefaults[DK_ShowCardSetCounts] = @YES;
        
        [defaults registerDefaults:boardDefaults];
    });
}

//----------------------------------------------------------------------

- (instancetype)init
{
    int l;
    
    if (self = [super init]) {
        borderWidth = 0.15;
        regularBorderColor = [NSColor blackColor];
        selectedBorderColor = [NSColor whiteColor];
        
        for (l = 0; l < 7; l++)
            playerColors[l] = nil;
        
        [self revertAllToDefaults];
    }
    
    return self;
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
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (int l = 1; l < 7; l++)
    {
        SNRelease (playerColors[l]);
    }
    
    playerColors[1] = getColorForDefault (DK_DefaultPlayer1Color);
    playerColors[2] = getColorForDefault (DK_DefaultPlayer2Color);
    playerColors[3] = getColorForDefault (DK_DefaultPlayer3Color);
    playerColors[4] = getColorForDefault (DK_DefaultPlayer4Color);
    playerColors[5] = getColorForDefault (DK_DefaultPlayer5Color);
    playerColors[6] = getColorForDefault (DK_DefaultPlayer6Color);
    
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
    
    regularBorderColor = getColorForDefault (DK_RegularBorderColor);
    
    selectedBorderColor = getColorForDefault (DK_SelectedBorderColor);
    
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
    
    regularBorderColor = newColor;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupChangedNotification
                                                        object:self];
}

//----------------------------------------------------------------------

- (void) setSelectedBorderColor:(NSColor *)newColor
{
    if (newColor == selectedBorderColor)
        return;
    
    selectedBorderColor = newColor;
    
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
    
    playerColors[playerNumber] = aColor;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RiskBoardSetupPlayerColorsChangedNotification
                                                        object:self];
}

@end
