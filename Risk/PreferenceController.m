//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: PreferenceController.m,v 1.2 1997/12/15 07:43:59 nygard Exp $");

#import "PreferenceController.h"

#import "BoardSetup.h"
#import "LineView.h"

//======================================================================
// The PreferenceController provides a simple panel for changing some
// of the default appearence values.
//======================================================================

#define PreferenceController_VERSION 1

@implementation PreferenceController

+ (void) initialize
{
    if (self == [PreferenceController class])
    {
        [self setVersion:PreferenceController_VERSION];
    }
}

//----------------------------------------------------------------------

- init
{
    BOOL loaded, okay;
    NSString *nibFile;

    if (self = [super init]) {
    nibFile = @"PreferencePanel.nib";
    loaded = [NSBundle loadNibNamed:nibFile owner:self];
    if (loaded == NO)
    {
        NSLog (@"Could not load %@.", nibFile);
        [super dealloc];
        return nil;
    }

    okay = [preferencePanel setFrameAutosaveName:[preferencePanel title]];
    if (okay == NO)
        NSLog (@"Could not set frame autosave name of Preference panel.");

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector (boardSetupChanged:)
                                          name:RiskBoardSetupChangedNotification
                                          object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector (boardSetupChanged:)
                                          name:RiskBoardSetupShowCardSetCountsChangedNotification
                                          object:nil];
    }

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

//----------------------------------------------------------------------

- (void) showPanel
{
    [self takePreferencesFromBoardSetup];
    [preferencePanel makeKeyAndOrderFront:self];
}

//----------------------------------------------------------------------

- (IBAction) revertAction:(id)sender
{
    [[BoardSetup instance] revertOtherToDefaults];
    [preferencePanel setDocumentEdited:NO];
}

//----------------------------------------------------------------------

- (IBAction) setAction:(id)sender
{
    [[BoardSetup instance] writeAllDefaults];
    [preferencePanel setDocumentEdited:NO];
}

//----------------------------------------------------------------------

- (void) takePreferencesFromBoardSetup
{
    BoardSetup *boardSetup;
    float borderWidth;

    boardSetup = [BoardSetup instance];

    [regularBorderWell setColor:[boardSetup regularBorderColor]];
    [selectedBorderWell setColor:[boardSetup selectedBorderColor]];
    borderWidth = [boardSetup borderWidth];
    [borderWidthSlider setFloatValue:borderWidth];
    [borderWidthTextField setFloatValue:borderWidth];
    [borderWidthLineView setLineWidth:borderWidth];
    [showCardSetsButton setState:[boardSetup showCardSetCounts]];
}

//----------------------------------------------------------------------

- (IBAction) borderWidthAction:(id)sender
{
    float newLineWidth;

    newLineWidth = [sender floatValue];

    if (sender == borderWidthSlider)
    {
        [borderWidthTextField setFloatValue:newLineWidth];
        [borderWidthLineView setLineWidth:newLineWidth];
        [[BoardSetup instance] setBorderWidth:newLineWidth];
        [preferencePanel setDocumentEdited:YES];
    }
    else
    {
        [borderWidthSlider setFloatValue:newLineWidth];
        [borderWidthLineView setLineWidth:newLineWidth];
        [[BoardSetup instance] setBorderWidth:newLineWidth];
        [preferencePanel setDocumentEdited:YES];
    }
}

//----------------------------------------------------------------------

- (IBAction) borderColorAction:(id)sender
{
    if (sender == regularBorderWell)
    {
        [[BoardSetup instance] setRegularBorderColor:[regularBorderWell color]];
        [preferencePanel setDocumentEdited:YES];
    }
    else if (sender == selectedBorderWell)
    {
        [[BoardSetup instance] setSelectedBorderColor:[selectedBorderWell color]];
        [preferencePanel setDocumentEdited:YES];
    }
}

//----------------------------------------------------------------------

- (IBAction) statusCardSetsAction:(id)sender
{
    [[BoardSetup instance] setShowCardSetCounts:[showCardSetsButton state]];
    [preferencePanel setDocumentEdited:YES];
}

//----------------------------------------------------------------------

- (void) boardSetupChanged:(NSNotification *)aNotification
{
    [self takePreferencesFromBoardSetup];
}

@end
