//
// $Id: CardPanelController.h,v 1.2 1997/12/15 07:43:39 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

NS_ASSUME_NONNULL_BEGIN

@class RKCard, RiskPlayer, RiskGameManager;

//! The \c CardPanelController provides interactive Risk players with an
//! interface for reviewing their hand and choosing card sets to turn
//! in.  It will force the player to turn in cards when they are able to
//! and have more than four cards in their hand.
//!
//! The cards are not turned in until all sets have been chosen.  The
//! \c RiskPlayer is notified about the number of extra armies for each
//! set turned in.
@interface CardPanelController : NSObject
{
    // cardPanel outlets
    IBOutlet NSPanel *cardPanel;
    IBOutlet NSButton *doneButton;
    IBOutlet NSButton *cancelButton;
    IBOutlet NSTextField *amassedTextField;

    IBOutlet NSScrollView *handScrollView;
    IBOutlet NSMatrix *handMatrix;
    IBOutlet NSMatrix *handStarMatrix;
    IBOutlet NSMatrix *setMatrix;
    IBOutlet NSMatrix *setStarMatrix;
    IBOutlet NSButton *turnInButton;
    IBOutlet NSTextField *worthTextField;
    IBOutlet NSTextField *forceTextField;

    // card panel internals
    RKCard *currentSet[3];
    int currentIndices[3];
    int setMatrixCount;
    RKPlayer currentPlayerNumber;

    BOOL canTurnInCards;
    RiskGameManager *gameManager;
    NSArray *playerCards;
    RKArmyCount currentCardSetValue;
    NSMutableArray *cardSets;
}

@property (strong) RiskGameManager *gameManager;

+ (void) loadClassImages;

- (instancetype)init;

- (IBAction) handAction:(nullable id)sender;
- (IBAction) setAction:(nullable id)sender;
- (IBAction) doneAction:(nullable id)sender;
- (IBAction) stopAction:(nullable id)sender;
- (IBAction) turnInSetAction:(nullable id)sender;

- (void) enableButtons;

- (void) resetPanel;

- (void) setupPanelForPlayer:(RiskPlayer *)player;
- (void) runCardPanel:(BOOL)canTurnInCardsFlag forPlayer:(RiskPlayer *)player;

@end

NS_ASSUME_NONNULL_END
