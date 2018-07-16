//
// $Id: BoardSetup.h,v 1.1.1.1 1997/12/09 07:18:52 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

#import "Risk.h"

@class NSColor;

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

extern NSNotificationName const RiskBoardSetupChangedNotification;
extern NSNotificationName const RiskBoardSetupPlayerColorsChangedNotification;
extern NSNotificationName const RiskBoardSetupShowCardSetCountsChangedNotification;

//! The \c BoardSetup defines what the main board and the status view will
//! look like.
@interface BoardSetup : NSObject
{
    CGFloat borderWidth;
    NSColor *regularBorderColor;
    NSColor *selectedBorderColor;

    BOOL showCardSetCounts;
    NSColor *playerColors[7];
}

+ (BoardSetup*)instance;
@property (class, readonly, strong) BoardSetup *instance;

- (instancetype)init;

- (void) writeAllDefaults;
- (void) writePlayerColorDefaults;
- (void) writeOtherDefaults;

- (void) revertAllToDefaults;
- (void) revertPlayerColorsToDefaults;
- (void) revertOtherToDefaults;

@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, strong) NSColor *regularBorderColor;
@property (nonatomic, strong) NSColor *selectedBorderColor;
@property (nonatomic) BOOL showCardSetCounts;

- (NSColor *) colorForPlayer:(Player)playerNumber;
- (void) setColor:(NSColor *)aColor forPlayer:(Player)playerNumber;

@end
