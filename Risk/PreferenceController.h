//
// $Id: PreferenceController.h,v 1.1.1.1 1997/12/09 07:18:59 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class LineView;

//! The \c PreferenceController provides a simple panel for changing some
//! of the default appearence values.
@interface PreferenceController : NSObject
{
    IBOutlet NSWindow *preferencePanel;

    IBOutlet NSColorWell *regularBorderWell;
    IBOutlet NSColorWell *selectedBorderWell;
    IBOutlet NSSlider *borderWidthSlider;
    IBOutlet NSTextField *borderWidthTextField;

    IBOutlet LineView *borderWidthLineView;
    IBOutlet NSButton *showCardSetsButton;
}

- (instancetype)init;

- (void) showPanel;

- (IBAction) revertAction:(id)sender;
- (IBAction) setAction:(id)sender;

- (void) takePreferencesFromBoardSetup;

- (IBAction) borderWidthAction:(id)sender;
- (IBAction) borderColorAction:(id)sender;
- (IBAction) statusCardSetsAction:(id)sender;

- (void) boardSetupChanged:(NSNotification *)aNotification;

@end
