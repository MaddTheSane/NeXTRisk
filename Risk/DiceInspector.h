//
// $Id: DiceInspector.h,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class Country;

@interface DiceInspector : NSObject
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

+ (void) initialize;
+ (void) loadClassImages;

- init;
- (void) dealloc;

- (void) showPanel;
- (BOOL) isPanelOnScreen;

- (void) setDieImage:(NSImageView *)aView fromInt:(int)value;

- (void) showAttackFromCountry:(Country *)attacker
                     toCountry:(Country *)defender
                      withDice:(DiceRoll)dice;

- (void) waitForContinue;
- (void) continueAction:sender;
- (void) pauseCheckAction:sender;


@end
