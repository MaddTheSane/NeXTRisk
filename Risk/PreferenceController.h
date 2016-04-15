//
// $Id: PreferenceController.h,v 1.1.1.1 1997/12/09 07:18:59 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class LineView;

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

+ (void) initialize;

- init;
- (void) dealloc;

- (void) showPanel;

- (void) revertAction:sender;
- (void) setAction:sender;

- (void) takePreferencesFromBoardSetup;

- (void) borderWidthAction:sender;
- (void) borderColorAction:sender;
- (void) statusCardSetsAction:sender;

- (void) boardSetupChanged:(NSNotification *)aNotification;

@end
