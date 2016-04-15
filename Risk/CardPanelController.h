//
// $Id: CardPanelController.h,v 1.2 1997/12/15 07:43:39 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class RiskCard, RiskPlayer, RiskGameManager;

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
    RiskCard *currentSet[3];
    int currentIndices[3];
    int setMatrixCount;
    Player currentPlayerNumber;

    BOOL canTurnInCards;
    RiskGameManager *gameManager;
    NSArray *playerCards;
    int currentCardSetValue;
    NSMutableArray *cardSets;
}

+ (void) loadClassImages;

- (instancetype)init;

- (IBAction) handAction:sender;
- (IBAction) setAction:sender;
- (IBAction) doneAction:sender;
- (IBAction) stopAction:sender;
- (IBAction) turnInSetAction:sender;

- (void) enableButtons;

- (void) resetPanel;

- (void) setupPanelForPlayer:(RiskPlayer *)player;
- (void) runCardPanel:(BOOL)canTurnInCardsFlag forPlayer:(RiskPlayer *)player;

- (void) setGameManager:(RiskGameManager *)newGameManager;

@end
