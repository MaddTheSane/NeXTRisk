//
// $Id: StatusView.h,v 1.2 1997/12/15 07:44:21 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import <RiskKit/Risk.h>

@class RiskGameManager;

//! The \c StatusView shows the color of each player (in the order of play)
//! and, optionally, the number of cards in their hand.  This number is
//! highlighted if the player has a valid card set.
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
