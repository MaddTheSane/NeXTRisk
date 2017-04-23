//
// $Id: ArmyView.h,v 1.1.1.1 1997/12/09 07:18:52 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@interface ArmyView : NSView

+ (void) loadClassImages;

- (instancetype)initWithFrame:(NSRect)frameRect;

@property (nonatomic) RiskArmyCount armyCount;

- (void) drawRect:(NSRect)rect;

@end
