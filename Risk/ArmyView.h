//
// $Id: ArmyView.h,v 1.1.1.1 1997/12/09 07:18:52 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@interface ArmyView : NSView
{
    int armyCount;
}

+ (void) initialize;
+ (void) loadClassImages;

- initWithFrame:(NSRect)frameRect;
- (void) dealloc;

- (int) armyCount;
- (void) setArmyCount:(int)newCount;

- (void) drawRect:(NSRect)rect;

@end
