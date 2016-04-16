//
// $Id: Brain.h,v 1.1.1.1 1997/12/09 07:18:52 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class RiskMapView, Country, RiskGameManager, NewGameController;
@class PreferenceController;

#define DK_DMakeActive @"DMakeActive"

#define DK_DefaultPlayer1Type @"DefaultPlayer1Type"
#define DK_DefaultPlayer2Type @"DefaultPlayer2Type"
#define DK_DefaultPlayer3Type @"DefaultPlayer3Type"
#define DK_DefaultPlayer4Type @"DefaultPlayer4Type"
#define DK_DefaultPlayer5Type @"DefaultPlayer5Type"
#define DK_DefaultPlayer6Type @"DefaultPlayer6Type"
           
#define DK_DefaultPlayer1Name @"DefaultPlayer1Name"
#define DK_DefaultPlayer2Name @"DefaultPlayer2Name"
#define DK_DefaultPlayer3Name @"DefaultPlayer3Name"
#define DK_DefaultPlayer4Name @"DefaultPlayer4Name"
#define DK_DefaultPlayer5Name @"DefaultPlayer5Name"
#define DK_DefaultPlayer6Name @"DefaultPlayer6Name"
           
#define DK_ShowPlayer1Console @"ShowPlayer1Console"
#define DK_ShowPlayer2Console @"ShowPlayer2Console"
#define DK_ShowPlayer3Console @"ShowPlayer3Console"
#define DK_ShowPlayer4Console @"ShowPlayer4Console"
#define DK_ShowPlayer5Console @"ShowPlayer5Console"
#define DK_ShowPlayer6Console @"ShowPlayer6Console"

@interface Brain : NSObject <NSApplicationDelegate>
{
    IBOutlet NSWindow *infoPanel;
    IBOutlet NSTextField *versionTextField;

    RiskGameManager *gameManager;
    NewGameController *newGameController;
    PreferenceController *preferenceController;

    NSMutableArray<NSBundle*> *riskPlayerBundles;
}

- (instancetype)init;

- (IBAction) showNewGamePanel:(id)sender;
- (IBAction) showGameSetupPanel:(id)sender;
- (IBAction) info:(id)sender;
- (IBAction) showPreferencePanel:(id)sender;

- (void) loadRiskPlayerBundles;
- (NSArray<NSBundle*> *) riskPlayerBundles;

@property (readonly, retain) RiskGameManager *gameManager;

@end
