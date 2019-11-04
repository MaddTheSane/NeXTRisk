//
// $Id: NewGameController.h,v 1.1.1.1 1997/12/09 07:18:54 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Cocoa/Cocoa.h>

@class Brain, RKGameConfiguration, RKBoardSetup;

//! The \c NewGameController loads the panel, adds loaded computer players
//! to the appropriate popup buttons, updates the controls to reflect
//! the default values, and creates a new game based on the current
//! values.
//!
//! This also doubles as a preference panel for all of the options.
@interface NewGameController : NSObject
{
    IBOutlet NSWindow *newGamePanel;

    IBOutlet NSTextField *player1NameField;
    IBOutlet NSTextField *player2NameField;
    IBOutlet NSTextField *player3NameField;
    IBOutlet NSTextField *player4NameField;
    IBOutlet NSTextField *player5NameField;
    IBOutlet NSTextField *player6NameField;

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

    IBOutlet NSButton *initialCountryDistributionPlayerChoice;
    IBOutlet NSButton *initialCountryDistributionRandom;
    
    IBOutlet NSButton *initialArmyPlacementByOnes;
    IBOutlet NSButton *initialArmyPlacementByThrees;
    IBOutlet NSButton *initialArmyPlacementByFives;
    
    IBOutlet NSButton *cardRedemptionButton1;
    IBOutlet NSButton *cardRedemptionButton2;
    IBOutlet NSButton *cardRedemptionButton3;

    IBOutlet NSButton *fortifyRuleButton1;
    IBOutlet NSButton *fortifyRuleButton2;
    IBOutlet NSButton *fortifyRuleButton3;
    IBOutlet NSButton *fortifyRuleButton4;

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
    RKGameConfiguration *gameConfiguration;
    RKBoardSetup *boardSetup;

    BOOL runningAsPreferences;
}

- (instancetype)initWithBrain:(Brain *)theBrain NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void) showNewGamePanel;
- (void) showGameSetupPanel;

- (IBAction) aboutAction:(id)sender;
- (IBAction) aboutStopAction:(id)sender;

- (IBAction) recalculateInitialArmies:(id)sender;

- (IBAction) acceptAction:(id)sender;
- (IBAction) cancelAction:(id)sender;

- (IBAction)dummyChangeInitialCountryDistribution:(id)sender;
- (IBAction)dummyChangeInitialArmyPlacement:(id)sender;
- (IBAction)dummyChangeCardSetRedemption:(id)sender;
- (IBAction)dummyChangeFortifyRules:(id)sender;

- (void) createNewGame;

- (void) writeDefaults;
- (void) revertToDefaults;

@property (readonly, strong) RKGameConfiguration *thisConfiguration;

- (void) takePreferencesFromCurrent;

- (void) boardSetupChanged:(NSNotification *)aNotification;

- (IBAction) playerColorAction:(id)sender;

@end
