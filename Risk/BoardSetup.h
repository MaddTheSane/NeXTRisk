//
// $Id: BoardSetup.h,v 1.1.1.1 1997/12/09 07:18:52 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

void setColorForDefault (NSColor *value, NSString *key);
NSColor *getColorForDefault (NSString *key);
NSData *defaultsDataForColor (NSColor *color);

#define DK_DefaultPlayer1Color @"DefaultPlayer1Color"
#define DK_DefaultPlayer2Color @"DefaultPlayer2Color"
#define DK_DefaultPlayer3Color @"DefaultPlayer3Color"
#define DK_DefaultPlayer4Color @"DefaultPlayer4Color"
#define DK_DefaultPlayer5Color @"DefaultPlayer5Color"
#define DK_DefaultPlayer6Color @"DefaultPlayer6Color"

#define DK_BorderWidth         @"BorderWidth"
#define DK_RegularBorderColor  @"RegularBorderColor"
#define DK_SelectedBorderColor @"SelectedBorderColor"
#define DK_ShowCardSetCounts   @"ShowCardSetCounts"

extern NSString *RiskBoardSetupChangedNotification;
extern NSString *RiskBoardSetupPlayerColorsChangedNotification;
extern NSString *RiskBoardSetupShowCardSetCountsChangedNotification;

@interface BoardSetup : NSObject
{
    float borderWidth;
    NSColor *regularBorderColor;
    NSColor *selectedBorderColor;

    BOOL showCardSetCounts;
    NSColor *playerColors[7];
}

+ instance;

+ (void) initialize;

- init;
- (void) dealloc;

- (void) writeAllDefaults;
- (void) writePlayerColorDefaults;
- (void) writeOtherDefaults;

- (void) revertAllToDefaults;
- (void) revertPlayerColorsToDefaults;
- (void) revertOtherToDefaults;

- (float) borderWidth;
- (void) setBorderWidth:(float)newWidth;

- (NSColor *) regularBorderColor;
- (void) setRegularBorderColor:(NSColor *)newColor;

- (NSColor *) selectedBorderColor;
- (void) setSelectedBorderColor:(NSColor *)newColor;

- (BOOL) showCardSetCounts;
- (void) setShowCardSetCounts:(BOOL)newFlag;

- (NSColor *) colorForPlayer:(Player)playerNumber;
- (void) setColor:(NSColor *)aColor forPlayer:(Player)playerNumber;

@end
