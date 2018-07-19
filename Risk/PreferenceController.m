//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: PreferenceController.m,v 1.2 1997/12/15 07:43:59 nygard Exp $");

#import "PreferenceController.h"

#import <RiskKit/RKBoardSetup.h>
#import "LineView.h"

#define PreferenceController_VERSION 1

@implementation PreferenceController
{
    NSArray *nibObjs;
}

+ (void) initialize
{
    if (self == [PreferenceController class])
    {
        [self setVersion:PreferenceController_VERSION];
    }
}

//----------------------------------------------------------------------

- (instancetype)init
{
    BOOL loaded, okay;
    NSString *nibFile;
    
    if (self = [super init]) {
        NSArray *tmpBundle;
        nibFile = @"PreferencePanel";
        loaded = [[NSBundle mainBundle] loadNibNamed:nibFile owner:self topLevelObjects:&tmpBundle];
        nibObjs = tmpBundle;
        if (loaded == NO)
        {
            NSLog (@"Could not load %@.", nibFile);
            return nil;
        }
        
        okay = [preferencePanel setFrameAutosaveName:preferencePanel.title];
        if (okay == NO)
            NSLog (@"Could not set frame autosave name of Preference panel.");
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (boardSetupChanged:)
                                                     name:RKBoardSetupChangedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (boardSetupChanged:)
                                                     name:RKBoardSetupShowCardSetCountsChangedNotification
                                                   object:nil];
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [[RKBoardSetup instance] revertOtherToDefaults];
    [preferencePanel setDocumentEdited:NO];
}

//----------------------------------------------------------------------

- (IBAction) setAction:(id)sender
{
    [[RKBoardSetup instance] writeAllDefaults];
    [preferencePanel setDocumentEdited:NO];
}

//----------------------------------------------------------------------

- (void) takePreferencesFromBoardSetup
{
    RKBoardSetup *boardSetup;
    float borderWidth;
    
    boardSetup = [RKBoardSetup instance];
    
    regularBorderWell.color = boardSetup.regularBorderColor;
    selectedBorderWell.color = boardSetup.selectedBorderColor;
    borderWidth = boardSetup.borderWidth;
    borderWidthSlider.floatValue = borderWidth;
    borderWidthTextField.floatValue = borderWidth;
    borderWidthLineView.lineWidth = borderWidth;
    showCardSetsButton.state = boardSetup.showCardSetCounts;
}

//----------------------------------------------------------------------

- (IBAction) borderWidthAction:(id)sender
{
    CGFloat newLineWidth;
    
    newLineWidth = [sender floatValue];
    
    if (sender == borderWidthSlider)
    {
        borderWidthTextField.floatValue = newLineWidth;
        borderWidthLineView.lineWidth = newLineWidth;
        [RKBoardSetup instance].borderWidth = newLineWidth;
        [preferencePanel setDocumentEdited:YES];
    }
    else
    {
        borderWidthSlider.floatValue = newLineWidth;
        borderWidthLineView.lineWidth = newLineWidth;
        [RKBoardSetup instance].borderWidth = newLineWidth;
        [preferencePanel setDocumentEdited:YES];
    }
}

//----------------------------------------------------------------------

- (IBAction) borderColorAction:(id)sender
{
    if (sender == regularBorderWell)
    {
        [RKBoardSetup instance].regularBorderColor = regularBorderWell.color;
        [preferencePanel setDocumentEdited:YES];
    }
    else if (sender == selectedBorderWell)
    {
        [RKBoardSetup instance].selectedBorderColor = selectedBorderWell.color;
        [preferencePanel setDocumentEdited:YES];
    }
}

//----------------------------------------------------------------------

- (IBAction) statusCardSetsAction:(id)sender
{
    [RKBoardSetup instance].showCardSetCounts = showCardSetsButton.state;
    [preferencePanel setDocumentEdited:YES];
}

//----------------------------------------------------------------------

- (void) boardSetupChanged:(NSNotification *)aNotification
{
    [self takePreferencesFromBoardSetup];
}

@end
