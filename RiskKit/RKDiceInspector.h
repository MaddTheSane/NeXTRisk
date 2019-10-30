//
// $Id: DiceInspector.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import <RiskKit/Risk.h>

NS_ASSUME_NONNULL_BEGIN

@class RKCountry;

//! The \c DiceInspector shows the dice as they are rolled, and optionally
//! pauses between rolls so that you can see what is going happening.
@interface RKDiceInspector : NSObject
{
    IBOutlet NSPanel *dicePanel;

    IBOutlet NSImageView *attackerDie1;
    IBOutlet NSImageView *attackerDie2;
    IBOutlet NSImageView *attackerDie3;

    IBOutlet NSImageView *defenderDie1;
    IBOutlet NSImageView *defenderDie2;

    IBOutlet NSTextField *attackerCountryName;
    IBOutlet NSTextField *attackerArmyCount;
    IBOutlet NSTextField *attackerUsingDieCount;
    IBOutlet NSTextField *attackerRollingCount;

    IBOutlet NSTextField *defenderCountryName;
    IBOutlet NSTextField *defenderArmyCount;
    IBOutlet NSTextField *defenderUsingDieCount;
    IBOutlet NSTextField *defenderRollingCount;

    IBOutlet NSButton *continueButton;
    IBOutlet NSButton *pauseCheckBox;
}

+ (void) loadClassImages;

- (instancetype)init;

- (void) showPanel;
@property (readonly, getter=isPanelOnScreen) BOOL panelOnScreen;

- (void) setDieImage:(NSImageView *)aView fromInt:(int)value;

- (void) showAttackFromCountry:(RKCountry *)attacker
                     toCountry:(RKCountry *)defender
                      withDice:(RKDiceRoll)dice;

- (void) waitForContinue;
- (IBAction) continueAction:(nullable id)sender;
- (IBAction) pauseCheckAction:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
