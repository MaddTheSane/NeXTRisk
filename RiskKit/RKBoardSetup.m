//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: BoardSetup.m,v 1.3 1997/12/15 07:43:37 nygard Exp $");

#import "RKBoardSetup.h"

#import <Cocoa/Cocoa.h>

static RKBoardSetup *_instance = nil;

// Notifications are sent when the preferences are changed, so that
// objects that use these defaults can be updated.

NSString *const RKBoardSetupChangedNotification = @"RiskBoardSetupChangedNotification";
NSString *const RKBoardSetupPlayerColorsChangedNotification = @"RiskBoardSetupPlayerColorsChangedNotification";
NSString *const RKBoardSetupShowCardSetCountsChangedNotification = @"RiskBoardSetupShowCardSetCountsChangedNotification";

void RKSetColorForDefault (NSColor *value, NSString *key)
{
    [[NSUserDefaults standardUserDefaults] setObject:RKDefaultsDataForColor (value) forKey:key];
}

//----------------------------------------------------------------------

NSColor *RKGetColorForDefault (NSString *key)
{
    NSColor *color;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:key];
    if (data == nil) {
        color = [NSColor blackColor];
    } else {
        color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (!color) {
            color = [NSUnarchiver unarchiveObjectWithData:data];
        }
    }
    
    return color;
}

//----------------------------------------------------------------------

NSData *RKDefaultsDataForColor (NSColor *color)
{
    return [NSKeyedArchiver archivedDataWithRootObject:color];
}

//======================================================================

#define BoardSetup_VERSION 1

@implementation RKBoardSetup
@synthesize borderWidth;
@synthesize regularBorderColor;
@synthesize selectedBorderColor;
@synthesize showCardSetCounts;

+ (id)instance
{
    if (_instance == nil)
    {
        _instance = [[RKBoardSetup alloc] init];
    }
    
    return _instance;
}

//----------------------------------------------------------------------

+ (void) initialize
{
    if (self == [RKBoardSetup class])
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
        boardDefaults[DK_DefaultPlayer1Color] = RKDefaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.8  green:0.8  blue:0.8  alpha:1.0];
        color = [NSColor blueColor];
        boardDefaults[DK_DefaultPlayer2Color] = RKDefaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.66 green:0.66 blue:0.66 alpha:1.0];
        color = [NSColor yellowColor];
        boardDefaults[DK_DefaultPlayer3Color] = RKDefaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.33 green:0.33 blue:0.33 alpha:1.0];
        color = [NSColor purpleColor];
        boardDefaults[DK_DefaultPlayer4Color] = RKDefaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0];
        color = [NSColor cyanColor];
        boardDefaults[DK_DefaultPlayer5Color] = RKDefaultsDataForColor (color);
        
        //color = [NSColor colorWithCalibratedRed:0.0  green:0.0  blue:0.0  alpha:1.0];
        color = [NSColor redColor];
        boardDefaults[DK_DefaultPlayer6Color] = RKDefaultsDataForColor (color);
        
        boardDefaults[DK_BorderWidth] = @1.0;
        
        color = [NSColor blackColor];
        boardDefaults[DK_RegularBorderColor] = RKDefaultsDataForColor (color);
        
        color = [NSColor whiteColor];
        boardDefaults[DK_SelectedBorderColor] = RKDefaultsDataForColor (color);
        
        boardDefaults[DK_ShowCardSetCounts] = @YES;
        
        [defaults registerDefaults:boardDefaults];
    });
}

//----------------------------------------------------------------------

- (instancetype)init
{
    if (self = [super init]) {
        borderWidth = 0.15;
        regularBorderColor = [NSColor blackColor];
        selectedBorderColor = [NSColor whiteColor];
        
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:RKDefaultsDataForColor (playerColors[1]) forKey:DK_DefaultPlayer1Color];
    [defaults setObject:RKDefaultsDataForColor (playerColors[2]) forKey:DK_DefaultPlayer2Color];
    [defaults setObject:RKDefaultsDataForColor (playerColors[3]) forKey:DK_DefaultPlayer3Color];
    [defaults setObject:RKDefaultsDataForColor (playerColors[4]) forKey:DK_DefaultPlayer4Color];
    [defaults setObject:RKDefaultsDataForColor (playerColors[5]) forKey:DK_DefaultPlayer5Color];
    [defaults setObject:RKDefaultsDataForColor (playerColors[6]) forKey:DK_DefaultPlayer6Color];
    
    [defaults synchronize];
}

//----------------------------------------------------------------------

- (void) writeOtherDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:RKDefaultsDataForColor (regularBorderColor) forKey:DK_RegularBorderColor];
    [defaults setObject:RKDefaultsDataForColor (selectedBorderColor) forKey:DK_SelectedBorderColor];
    
    [defaults setDouble:borderWidth forKey:DK_BorderWidth];
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
    
    playerColors[1] = RKGetColorForDefault (DK_DefaultPlayer1Color);
    playerColors[2] = RKGetColorForDefault (DK_DefaultPlayer2Color);
    playerColors[3] = RKGetColorForDefault (DK_DefaultPlayer3Color);
    playerColors[4] = RKGetColorForDefault (DK_DefaultPlayer4Color);
    playerColors[5] = RKGetColorForDefault (DK_DefaultPlayer5Color);
    playerColors[6] = RKGetColorForDefault (DK_DefaultPlayer6Color);
    
    // Notify of updated defaults.
    [[NSNotificationCenter defaultCenter] postNotificationName:RKBoardSetupPlayerColorsChangedNotification
                                                        object:self];
}

//----------------------------------------------------------------------

- (void) revertOtherToDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    borderWidth = [defaults doubleForKey:DK_BorderWidth];
    
    regularBorderColor = RKGetColorForDefault (DK_RegularBorderColor);
    
    selectedBorderColor = RKGetColorForDefault (DK_SelectedBorderColor);
    
    showCardSetCounts = [defaults boolForKey:DK_ShowCardSetCounts];
    
    // Notify of updated defaults.
    [[NSNotificationCenter defaultCenter] postNotificationName:RKBoardSetupChangedNotification
                                                        object:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RKBoardSetupShowCardSetCountsChangedNotification
                                                        object:self];
}

//----------------------------------------------------------------------

- (void) setBorderWidth:(CGFloat)newWidth
{
    borderWidth = newWidth;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RKBoardSetupChangedNotification
                                                        object:self];
}

//----------------------------------------------------------------------

- (void) setRegularBorderColor:(NSColor *)newColor
{
    if ([newColor isEqual:regularBorderColor])
        return;
    
    regularBorderColor = newColor;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RKBoardSetupChangedNotification
                                                        object:self];
}

//----------------------------------------------------------------------

- (void) setSelectedBorderColor:(NSColor *)newColor
{
    if ([newColor isEqual:selectedBorderColor])
        return;
    
    selectedBorderColor = newColor;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RKBoardSetupChangedNotification
                                                        object:self];
}

//----------------------------------------------------------------------

- (void) setShowCardSetCounts:(BOOL)newFlag
{
    showCardSetCounts = newFlag;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RKBoardSetupShowCardSetCountsChangedNotification
                                                        object:self];
}

//----------------------------------------------------------------------

- (NSColor *) colorForPlayer:(RKPlayer)playerNumber
{
    NSAssert (playerNumber > 0 && playerNumber < 7, @"Player number out of range.");
    
    return playerColors[playerNumber];
}

//----------------------------------------------------------------------

- (void) setColor:(NSColor *)aColor forPlayer:(RKPlayer)playerNumber
{
    NSAssert (playerNumber > 0 && playerNumber < 7, @"Player number out of range.");
    
    playerColors[playerNumber] = aColor;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RKBoardSetupPlayerColorsChangedNotification
                                                        object:self];
}

@end
