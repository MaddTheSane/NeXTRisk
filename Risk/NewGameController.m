//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: NewGameController.m,v 1.2 1997/12/15 07:43:57 nygard Exp $");

#import "NewGameController.h"

#import "Brain.h"
#import "RiskGameManager.h"
#import "Human.h"
#import "GameConfiguration.h"
#import "BoardSetup.h"

//======================================================================
// The NewGameController loads the panel, adds loaded computer players
// to the appropriate popup buttons, updates the controls to reflect
// the default values, and creates a new game based on the current
// values.
//
// This also doubles as a preference panel for all of the options.
//======================================================================

#define NewGameController_VERSION 1

@implementation NewGameController
{
    NSArray *nibObjs;
}

+ (void) initialize
{
    if (self == [NewGameController class])
    {
        [self setVersion:NewGameController_VERSION];
    }
}

//----------------------------------------------------------------------

- (void) awakeFromNib
{
    NSArray *riskPlayerBundles;
    NSEnumerator *bundleEnumerator;
    NSBundle *bundle;
    NSMutableArray *playerTypeNames;
    NSString *name;
    
    playerTypeNames = [NSMutableArray array];
    riskPlayerBundles = [brain riskPlayerBundles];
    bundleEnumerator = [riskPlayerBundles objectEnumerator];
    while (bundle = [bundleEnumerator nextObject])
    {
        name = bundle.infoDictionary[@"RKPlayerTypeName"];
        [playerTypeNames addObject:name];
    }
    
    [player1TypePopup addItemsWithTitles:playerTypeNames];
    [player2TypePopup addItemsWithTitles:playerTypeNames];
    [player3TypePopup addItemsWithTitles:playerTypeNames];
    [player4TypePopup addItemsWithTitles:playerTypeNames];
    [player5TypePopup addItemsWithTitles:playerTypeNames];
    [player6TypePopup addItemsWithTitles:playerTypeNames];
    
    [self revertToDefaults];
}

//----------------------------------------------------------------------

- (instancetype)initWithBrain:(Brain *)theBrain
{
    if (self = [super init]) {
        NSArray *tmpArr;
        gameConfiguration = [[GameConfiguration alloc] init];
        boardSetup = [BoardSetup instance];
        
        brain = theBrain;
        
        // -awakeFromNib gets called immediately, so the above stuff must
        // already be set up.
        NSString *nibFile = @"NewGamePanel";
        BOOL loaded = [[NSBundle mainBundle] loadNibNamed:nibFile owner:self topLevelObjects:&tmpArr];
        nibObjs = tmpArr;
        if (loaded == NO)
        {
            NSLog (@"Could not load %@.", nibFile);
            SNRelease (gameConfiguration);
            return nil;
        }
        
        runningAsPreferences = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (boardSetupChanged:)
                                                     name:RiskBoardSetupPlayerColorsChangedNotification
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

- (void) showNewGamePanel
{
    runningAsPreferences = NO;
    newGamePanel.title = @"New Game";
    acceptButton.title = @"Accept";
    cancelButton.title = @"Cancel";
    [newGamePanel makeKeyAndOrderFront:self];
}

//----------------------------------------------------------------------

- (void) showGameSetupPanel
{
    runningAsPreferences = YES;
    newGamePanel.title = @"New Game Setup";
    acceptButton.title = @"Set";
    cancelButton.title = @"Revert";
    [self takePreferencesFromCurrent];
    [newGamePanel makeKeyAndOrderFront:self];
}

//----------------------------------------------------------------------

- (IBAction) aboutAction:(id)sender
{
    NSPopUpButton *thePopup;
    NSInteger tag, itemIndex;
    NSString *rtfPath, *imagePath;
    NSBundle *thisBundle, *playerBundle;
    NSArray *riskPlayerBundles;
    NSDictionary *playerBundleInfo;
    NSImage *image;
    NSString *playerTypeName;
    
    thisBundle = [NSBundle bundleForClass:[self class]];
    NSAssert (thisBundle != nil, @"Could not get this bundle.");
    
    riskPlayerBundles = [brain riskPlayerBundles];
    
    tag = [[sender selectedCell] tag];
    thePopup = nil;
    
    switch (tag)
    {
        case 0:
            thePopup = player1TypePopup;
            break;
            
        case 1:
            thePopup = player2TypePopup;
            break;
            
        case 2:
            thePopup = player3TypePopup;
            break;
            
        case 3:
            thePopup = player4TypePopup;
            break;
            
        case 4:
            thePopup = player5TypePopup;
            break;
            
        case 5:
            thePopup = player6TypePopup;
            break;
            
        default:
            thePopup = nil;
    }
    
    NSAssert (thePopup != nil, @"Bad tag.");
    
    itemIndex = thePopup.indexOfSelectedItem;
    
    switch (itemIndex)
    {
        case 0: // None
            [aboutPlayerImageView setImage:nil];
            aboutPlayerNameTextfield.stringValue = [NSString stringWithFormat:@"%ld. Not Playing", tag + 1];
            rtfPath = [thisBundle pathForResource:@"NotPlaying" ofType:@"rtf"];
            if (rtfPath != nil)
            {
                [aboutPlayerText readRTFDFromFile:rtfPath];
            }
            else
            {
                aboutPlayerText.string = @"";
            }
            break;
            
        case 1: // Human
            image = [NSImage imageNamed:@"Human"];
            aboutPlayerImageView.image = image;
            
            aboutPlayerNameTextfield.stringValue = [NSString stringWithFormat:@"%ld. Human Player", tag + 1];
            rtfPath = [thisBundle pathForResource:@"Human" ofType:@"rtf"];
            if (rtfPath != nil)
            {
                [aboutPlayerText readRTFDFromFile:rtfPath];
            }
            else
            {
                aboutPlayerText.string = @"";
            }
            break;
            
        default: // Computer player
            playerBundle = riskPlayerBundles[itemIndex - 2];
            playerBundleInfo = playerBundle.infoDictionary;
            
            image = [playerBundle imageForResource:playerBundleInfo[@"RKPlayerIcon"]];
            if (!image) {
                image = [NSImage imageNamed:playerBundleInfo[@"RKPlayerIcon"]];
            }
            aboutPlayerImageView.image = image;
            
            playerTypeName = playerBundleInfo[@"RKPlayerTypeName"];
            aboutPlayerNameTextfield.stringValue = [NSString stringWithFormat:@"%ld. %@", tag + 1, playerTypeName];
            
            rtfPath = [playerBundle pathForResource:playerBundleInfo[@"RKAboutPlayerFile"] ofType:nil];
            if (rtfPath != nil)
            {
                [aboutPlayerText readRTFDFromFile:rtfPath];
            }
            else
            {
                aboutPlayerText.string = @"";
            }
            break;
    }
    
    [aboutPlayerWindow makeKeyAndOrderFront:self];
    [NSApp runModalForWindow:aboutPlayerWindow];
    [aboutPlayerWindow orderOut:self];
}

//----------------------------------------------------------------------

- (IBAction) aboutStopAction:(id)sender
{
    [NSApp stopModal];
}

//----------------------------------------------------------------------

- (IBAction) recalculateInitialArmies:(id)sender
{
    int playerCount;
    NSInteger ps[7];
    int l;
    
    ps[1] = player1TypePopup.indexOfSelectedItem;
    ps[2] = player2TypePopup.indexOfSelectedItem;
    ps[3] = player3TypePopup.indexOfSelectedItem;
    ps[4] = player4TypePopup.indexOfSelectedItem;
    ps[5] = player5TypePopup.indexOfSelectedItem;
    ps[6] = player6TypePopup.indexOfSelectedItem;
    
    playerCount = 0;
    for (l = 1; l < 7; l++)
    {
        if (ps[l] != 0)
            playerCount++;
    }
    
    if (playerCount > 1)
    {
        initialArmyCountTextfield.intValue = RiskInitialArmyCountForPlayers (playerCount);
    }
    else
    {
        initialArmyCountTextfield.stringValue = @"--";
    }
}

//----------------------------------------------------------------------

- (IBAction) acceptAction:(id)sender
{
    if (runningAsPreferences == YES)
    {
        //[boardSetup writePlayerColorDefaults];
        [self writeDefaults];
    }
    else
    {
        [self createNewGame];
    }
}

//----------------------------------------------------------------------

- (IBAction) cancelAction:(id)sender
{
    if (runningAsPreferences == YES)
    {
        //[boardSetup revertPlayerColorsToDefaults];
        [self revertToDefaults];
    }
    else
    {
        [newGamePanel orderOut:self];
    }
}

//----------------------------------------------------------------------

// Odd - the "Control" title of the control panel shifts to the right once this method is finished...
// Or, rather, as soon as the window becomes key.  It looks like this is happening because there is
// not a miniaturize button.

// On a related note.  Window w/ mini changed to Panel, attr insp shows no mini, but mini still set.

- (void) createNewGame
{
    RiskGameManager *gameManager;
    NSInteger ps[7];
    int l, playerCount;
    NSArray *riskPlayerBundles;
    NSBundle *playerBundle;
    RiskPlayer *player;
    Class playerClass;
    NSString *name;
    GameConfiguration *thisConfiguration;
    BOOL showPlayerConsole;
    
    gameManager = brain.gameManager;
    
    if ([gameManager gameInProgress] == YES)
    {
        if (NSRunAlertPanel (@"New Game", @"There is already a game starting or in progess.", @"Cancel", @"Start new game", nil) == NSAlertDefaultReturn)
        {
            return;
        }
        
        [gameManager stopGame];
    }
    
    ps[1] = player1TypePopup.indexOfSelectedItem;
    ps[2] = player2TypePopup.indexOfSelectedItem;
    ps[3] = player3TypePopup.indexOfSelectedItem;
    ps[4] = player4TypePopup.indexOfSelectedItem;
    ps[5] = player5TypePopup.indexOfSelectedItem;
    ps[6] = player6TypePopup.indexOfSelectedItem;
    
    playerCount = 0;
    for (l = 1; l < 7; l++)
    {
        if (ps[l] != 0)
            playerCount++;
    }
    
    if (playerCount < 2)
    {
        NSRunAlertPanel (@"New Game", @"At least two players have to play.", @"OK", nil, nil);
        return;
    }
    
    [newGamePanel orderOut:self];
    
    //[self writeDefaults];
    thisConfiguration = [self thisConfiguration];
    //[thisConfiguration writeDefaults];
    [gameManager setGameConfiguration:thisConfiguration];
    [gameManager startNewGame];
    
    riskPlayerBundles = [brain riskPlayerBundles];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (l = 1; l < 7; l++)
    {
        name = [[playerNameForm cellAtIndex:l - 1] stringValue];
        
        player = nil;
        switch (ps[l])
        {
            case 0: // None
                break;
                
            case 1: // Human
                player = [[Human alloc] initWithPlayerName:name number:l gameManager:gameManager];
                //[gameManager addPlayer:player number:l];
                break;
                
            default: // Computer
                playerBundle = riskPlayerBundles[ps[l] - 2];
                playerClass = playerBundle.principalClass;
                //NSAssert ([playerClass isKindOfClass:[RiskPlayer class]] == YES, @"Player class must be a subclass of RiskPlayer.");
                player = [[playerClass alloc] initWithPlayerName:name number:l gameManager:gameManager];
                //[gameManager addPlayer:player number:l];
                break;
        }
        
        if (player != nil)
        {
            [gameManager addPlayer:player number:l];
            showPlayerConsole = [defaults boolForKey:[NSString stringWithFormat:@"ShowPlayer%dConsole", l]];
            if (showPlayerConsole == YES)
                [player showConsolePanel:self];
        }
    }
    
    [gameManager beginGame];
}

//----------------------------------------------------------------------

- (void) writeDefaults
{
    NSUserDefaults *defaults;
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    [boardSetup writePlayerColorDefaults];
    [[self thisConfiguration] writeDefaults];
    
    // And then save the player names and types.
    [defaults setObject:[[playerNameForm cellAtIndex:0] stringValue] forKey:DK_DefaultPlayer1Name];
    [defaults setObject:[[playerNameForm cellAtIndex:1] stringValue] forKey:DK_DefaultPlayer2Name];
    [defaults setObject:[[playerNameForm cellAtIndex:2] stringValue] forKey:DK_DefaultPlayer3Name];
    [defaults setObject:[[playerNameForm cellAtIndex:3] stringValue] forKey:DK_DefaultPlayer4Name];
    [defaults setObject:[[playerNameForm cellAtIndex:4] stringValue] forKey:DK_DefaultPlayer5Name];
    [defaults setObject:[[playerNameForm cellAtIndex:5] stringValue] forKey:DK_DefaultPlayer6Name];
    
    [defaults setObject:player1TypePopup.title forKey:DK_DefaultPlayer1Type];
    [defaults setObject:player2TypePopup.title forKey:DK_DefaultPlayer2Type];
    [defaults setObject:player3TypePopup.title forKey:DK_DefaultPlayer3Type];
    [defaults setObject:player4TypePopup.title forKey:DK_DefaultPlayer4Type];
    [defaults setObject:player5TypePopup.title forKey:DK_DefaultPlayer5Type];
    [defaults setObject:player6TypePopup.title forKey:DK_DefaultPlayer6Type];
    
    [defaults synchronize];
}

//----------------------------------------------------------------------

- (void) revertToDefaults
{
    NSUserDefaults *defaults;
    GameConfiguration *oldConfiguration;
    NSString *tmp;
    int index;
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer1Name];
    [[playerNameForm cellAtIndex:0] setStringValue:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer2Name];
    [[playerNameForm cellAtIndex:1] setStringValue:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer3Name];
    [[playerNameForm cellAtIndex:2] setStringValue:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer4Name];
    [[playerNameForm cellAtIndex:3] setStringValue:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer5Name];
    [[playerNameForm cellAtIndex:4] setStringValue:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer6Name];
    [[playerNameForm cellAtIndex:5] setStringValue:tmp];
    
    //----------------------------------------
    
    tmp = [defaults stringForKey:DK_DefaultPlayer1Type];
    [player1TypePopup selectItemWithTitle:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer2Type];
    [player2TypePopup selectItemWithTitle:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer3Type];
    [player3TypePopup selectItemWithTitle:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer4Type];
    [player4TypePopup selectItemWithTitle:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer5Type];
    [player5TypePopup selectItemWithTitle:tmp];
    
    tmp = [defaults stringForKey:DK_DefaultPlayer6Type];
    [player6TypePopup selectItemWithTitle:tmp];
    
    [boardSetup revertPlayerColorsToDefaults];
    player1ColorWell.color = [boardSetup colorForPlayer:1];
    player2ColorWell.color = [boardSetup colorForPlayer:2];
    player3ColorWell.color = [boardSetup colorForPlayer:3];
    player4ColorWell.color = [boardSetup colorForPlayer:4];
    player5ColorWell.color = [boardSetup colorForPlayer:5];
    player6ColorWell.color = [boardSetup colorForPlayer:6];
    
    //----------------------------------------
    // Now the game configuration rules.
    oldConfiguration = [GameConfiguration defaultConfiguration];
    
    switch (oldConfiguration.initialCountryDistribution)
    {
        case RandomlyChosen:
            index = 1;
            break;
            
        case PlayerChosen:
        default:
            index = 0;
            break;
    }
    
    [initialCountryDistributionMatrix selectCellWithTag:index];
    
    switch (oldConfiguration.initialArmyPlacement)
    {
        case PlaceByThrees:
            index = 1;
            break;
            
        case PlaceByFives:
            index = 2;
            break;
            
        case PlaceByOnes:
        default:
            index = 0;
            break;
    }
    
    [initialArmyPlacementMatrix selectCellWithTag:index];
    
    switch (oldConfiguration.cardSetRedemption)
    {
        case IncreaseByOne:
            index = 1;
            break;
            
        case IncreaseByFive:
            index = 2;
            break;
            
        case RemainConstant:
        default:
            index = 0;
            break;
    }
    
    [cardRedemptionMatrix selectCellWithTag:index];
    
    switch (oldConfiguration.fortifyRule)
    {
        case OneToManyNeighbors:
            index = 1;
            break;
            
        case ManyToManyNeighbors:
            index = 2;
            break;
            
        case ManyToManyConnected:
            index = 3;
            break;
            
        case OneToOneNeighbor:
        default:
            index = 0;
            break;
    }
    
    [fortifyRuleMatrix selectCellWithTag:index];
    
    // And finally update the intial armies textfield
    [self recalculateInitialArmies:self];
}

//----------------------------------------------------------------------

- (GameConfiguration *) thisConfiguration
{
    GameConfiguration *thisConfiguration;
    NSInteger index;
    InitialCountryDistribution distribution[2] = { PlayerChosen, RandomlyChosen };
    InitialArmyPlacement placement[3] = { PlaceByOnes, PlaceByThrees, PlaceByFives };
    CardSetRedemption redemption[3] = { RemainConstant, IncreaseByOne, IncreaseByFive };
    FortifyRule rule[4] = { OneToOneNeighbor, OneToManyNeighbors, ManyToManyNeighbors, ManyToManyConnected };
    
    thisConfiguration = [GameConfiguration defaultConfiguration];
    
    index = initialCountryDistributionMatrix.selectedRow;
    if (index < 0 || index > 1)
        index = 0;
    thisConfiguration.initialCountryDistribution = distribution[index];
    
    index = initialArmyPlacementMatrix.selectedRow;
    if (index < 0 || index > 2)
        index = 0;
    thisConfiguration.initialArmyPlacement = placement[index];
    
    index = cardRedemptionMatrix.selectedRow;
    if (index < 0 || index > 2)
        index = 0;
    thisConfiguration.cardSetRedemption = redemption[index];
    
    index = fortifyRuleMatrix.selectedRow;
    if (index < 0 || index > 3)
        index = 0;
    thisConfiguration.fortifyRule = rule[index];
    
    return thisConfiguration;
}

//----------------------------------------------------------------------

- (void) takePreferencesFromCurrent
{
    player1ColorWell.color = [boardSetup colorForPlayer:1];
    player2ColorWell.color = [boardSetup colorForPlayer:2];
    player3ColorWell.color = [boardSetup colorForPlayer:3];
    player4ColorWell.color = [boardSetup colorForPlayer:4];
    player5ColorWell.color = [boardSetup colorForPlayer:5];
    player6ColorWell.color = [boardSetup colorForPlayer:6];
}

//----------------------------------------------------------------------

- (void) boardSetupChanged:(NSNotification *)aNotification
{
    [self takePreferencesFromCurrent];
}

//----------------------------------------------------------------------

- (IBAction) playerColorAction:(id)sender
{
    if (sender == player1ColorWell)
        [boardSetup setColor:player1ColorWell.color forPlayer:1];
    else if (sender == player2ColorWell)
        [boardSetup setColor:player2ColorWell.color forPlayer:2];
    else if (sender == player3ColorWell)
        [boardSetup setColor:player3ColorWell.color forPlayer:3];
    else if (sender == player4ColorWell)
        [boardSetup setColor:player4ColorWell.color forPlayer:4];
    else if (sender == player5ColorWell)
        [boardSetup setColor:player5ColorWell.color forPlayer:5];
    else if (sender == player6ColorWell)
        [boardSetup setColor:player6ColorWell.color forPlayer:6];
}

@end
