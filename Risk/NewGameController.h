//
// $Id: NewGameController.h,v 1.1.1.1 1997/12/09 07:18:54 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class Brain, GameConfiguration, BoardSetup;

@interface NewGameController : NSObject
{
    IBOutlet NSWindow *newGamePanel;

    IBOutlet NSForm *playerNameForm;

    IBOutlet NSColorWell *player1ColorWell;
    IBOutlet NSColorWell *player2ColorWell;
    IBOutlet NSColorWell *player3ColorWell;
    IBOutlet NSColorWell *player4ColorWell;
    IBOutlet NSColorWell *player5ColorWell;
    IBOutlet NSColorWell *player6ColorWell;

    IBOutlet NSPopUpButton *player1TypePopup;
    IBOutlet NSPopUpButton *player2TypePopup;
    IBOutlet NSPopUpButton *player3TypePopup;
    IBOutlet NSPopUpButton *player4TypePopup;
    IBOutlet NSPopUpButton *player5TypePopup;
    IBOutlet NSPopUpButton *player6TypePopup;

    IBOutlet NSMatrix *initialCountryDistributionMatrix;
    IBOutlet NSMatrix *initialArmyPlacementMatrix;
    IBOutlet NSMatrix *cardRedemptionMatrix;
    IBOutlet NSMatrix *fortifyRuleMatrix;

    IBOutlet NSTextField *initialArmyCountTextfield;

    IBOutlet Brain *brain;

    // About player panel:
    IBOutlet NSWindow *aboutPlayerWindow;
    IBOutlet NSImageView *aboutPlayerImageView;
    IBOutlet NSTextField *aboutPlayerNameTextfield;
    IBOutlet NSTextView *aboutPlayerText;

    IBOutlet NSButton *acceptButton;
    IBOutlet NSButton *cancelButton;

    // Data
    GameConfiguration *gameConfiguration;
    BoardSetup *boardSetup;

    BOOL runningAsPreferences;
}

+ (void) initialize;

- (void) awakeFromNib;

- initWithBrain:(Brain *)theBrain;
- (void) dealloc;

- (void) showNewGamePanel;
- (void) showGameSetupPanel;

- (void) aboutAction:sender;
- (void) aboutStopAction:sender;

- (void) recalculateInitialArmies:sender;

- (void) acceptAction:sender;
- (void) cancelAction:sender;

- (void) createNewGame;

- (void) writeDefaults;
- (void) revertToDefaults;

- (GameConfiguration *) thisConfiguration;

- (void) takePreferencesFromCurrent;

- (void) boardSetupChanged:(NSNotification *)aNotification;

- (void) playerColorAction:sender;

@end
