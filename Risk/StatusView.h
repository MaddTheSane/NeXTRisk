//
// $Id: StatusView.h,v 1.2 1997/12/15 07:44:21 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class RiskGameManager;

@interface StatusView : NSView
{
    IBOutlet RiskGameManager *gameManager;
    BOOL showCardSetCounts;
}

- (instancetype)initWithFrame:(NSRect)frameRect;

@property (getter=isFlipped, readonly) BOOL flipped;

- (void) drawRect:(NSRect)rect;

- (void) defaultsChanged:(NSNotification *)aNotification;

@end
