//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: RiskGameManager.m,v 1.7 1997/12/18 21:03:46 nygard Exp $");

#import "RiskGameManager.h"

#import "RKArmyPlacementValidator.h"
#import "RKArmyView.h"
#import "RKBoardSetup.h"
#import "RKCardPanelController.h"
#import "RKCardSet.h"
#import "RKCountry.h"
#import "RKDiceInspector.h"
#import "RKGameConfiguration.h"
#import "RKCard.h"
#import "RiskMapView.h"
#import "RiskPlayer.h"
#import "RiskWorld.h"
#import "SNRandom.h"
#import "StatusView.h"
#import "RKWorldInfoController.h"

NSString *const RKGameOverNotification = @"RGMGameOverNotification";

#define AGSReason(state1) [NSString stringWithFormat:@"Current game state is (Player %ld, %@).  Expected game state to be %@.", (long)currentPlayerNumber, NSStringFromGameState (gameState), NSStringFromGameState (state1)]

#define AGSReason2(state1, state2) [NSString stringWithFormat:@"Current game state is (Player %ld, %@).  Expected game state to be %@ or %@.", (long)currentPlayerNumber, NSStringFromGameState (gameState), NSStringFromGameState (state1), NSStringFromGameState (state2)]

#define AGSReason3(state1, state2, state3) [NSString stringWithFormat:@"Current game state is (Player %ld, %@).  Expected game state to be %@, %@ or %@.", (long)currentPlayerNumber, NSStringFromGameState (gameState), NSStringFromGameState (state1), NSStringFromGameState (state2), NSStringFromGameState (state3)]

#define AGSReason4(state1, state2, state3, state4) [NSString stringWithFormat:@"Current game state is (Player %ld, %@).  Expected game state to be %@, %@, %@ or %@.", (long)currentPlayerNumber, NSStringFromGameState (gameState), NSStringFromGameState (state1), NSStringFromGameState (state2), NSStringFromGameState (state3), NSStringFromGameState (state4)]

#define AssertGameState(state1) NSAssert1 (gameState == state1, @"%@", AGSReason (state1))
#define AssertGameState2(state1, state2) NSAssert1 (gameState == state1 || gameState == state2, @"%@", AGSReason2 (state1, state2))
#define AssertGameState3(state1, state2, state3) NSAssert1 (gameState == state1 || gameState == state2 || gameState == state3, @"%@", AGSReason3 (state1, state2, state3))
#define AssertGameState4(state1, state2, state3, state4) NSAssert1 (gameState == state1 || gameState == state2 || gameState == state3 || gameState == state4, @"%@", AGSReason4 (state1, state2, state3, state4))

#define RiskGameManager_VERSION 1

@implementation RiskGameManager
{
    NSArray *nibObjs;
}
@synthesize gameConfiguration = configuration;
@synthesize world;
@synthesize gameState;
@synthesize currentPlayerNumber;
@synthesize activePlayerCount;
@synthesize phaseComputerMove;
@synthesize phasePlaceArmies;
@synthesize phaseAttack;
@synthesize phaseFortify;
@synthesize phaseChooseCountries;

+ (void) initialize
{
    if (self == [RiskGameManager class])
    {
        [self setVersion:RiskGameManager_VERSION];
    }
}

//----------------------------------------------------------------------

- (instancetype)init
{
    if (self = [super init]) {
        NSArray *tmpArr;
        world = nil;
        mapView = nil;
        
        phaseComputerMove = nil;
        phasePlaceArmies = nil;
        phaseAttack = nil;
        phaseFortify = nil;
        phaseChooseCountries = nil;
        currentPhaseView = nil;
        
        rng = [SNRandom instance];
        
        NSString *nibFile = @"GameBoard";
        BOOL loaded = [[NSBundle mainBundle] loadNibNamed:nibFile owner:self topLevelObjects:&tmpArr];
        nibObjs = tmpArr;
        if (loaded == NO)
        {
            NSLog (@"Could not load %@.", nibFile);
            return nil;
        }
        
        configuration = [[RKGameConfiguration alloc] init];;
        
        activePlayerCount = 0;
        
        for (int l = 0; l < MAX_PLAYERS; l++)
        {
            players[l] = nil;
            playersActive[l] = NO;
        }
        
        initialArmyCount = 0;
        gameState = RKGameStateNone;
        currentPlayerNumber = 0;
        
        cardPanelController = nil;
        cardDeck = nil;
        discardDeck = [[NSMutableArray alloc] init];
        
        playerHasConqueredCountry = NO;
        
        armyPlacementValidator = nil;
        nextCardSetValue = 4;
        
        diceInspector = nil;
        worldInfoController = nil;
        
        toolMenu = [NSApp.mainMenu itemWithTitle:@"Tools"].target;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (defaultsChanged:)
                                                     name:RKBoardSetupPlayerColorsChangedNotification
                                                   object:nil];
    }
    
    return self;
}

//----------------------------------------------------------------------

// Never really gets dealloc'd
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self stopGame];
}

//----------------------------------------------------------------------

- (void) awakeFromNib
{
    [super awakeFromNib];
    NSView *tmp1, *tmp2;
    
    // The windows should not be visible at launch time, so we can
    // move them to the default locations.
    
    [mapWindow setFrameAutosaveName:mapWindow.title];
    [mapWindow orderFront:self];
    
    [controlPanel setFrameAutosaveName:controlPanel.title];
    [controlPanel orderFront:self];
    
    [phaseComputerMove removeFromSuperview];
    [phasePlaceArmies removeFromSuperview];
    [phaseAttack removeFromSuperview];
    [phaseFortify removeFromSuperview];
    [phaseChooseCountries removeFromSuperview];
    
    // Try to make sure the map view doesn't obscure any peer
    // views when it redraws.  It must also set it's superview
    // to need display whenever it needs display.
    tmp1 = mapView.superview;
    tmp2 = mapView;
    [tmp2 removeFromSuperview];
    [tmp1 addSubview:tmp2 positioned:NSWindowBelow relativeTo:nil];
    
    // We don't want to have to validate the items like we do menu items.
    [attackMethodPopup setAutoenablesItems:NO];
}

//----------------------------------------------------------------------

- (void) _logGameState
{
    NSString *str;
    
    switch (gameState)
    {
        case RKGameStateNone:
            str = @"No game";
            break;
            
        case RKGameStateEstablishingGame:
            str = @"Establishing game.";
            break;
            
        case RKGameStateChoosingCountries:
            str = [NSString stringWithFormat:@"Choose countries -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case RKGameStatePlaceInitialArmies:
            str = [NSString stringWithFormat:@"Place initial armies -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case RKGameStatePlaceArmies:
            str = [NSString stringWithFormat:@"Place armies -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case RKGameStateAttack:
            str = [NSString stringWithFormat:@"Attack -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case RKGameStateMoveAttackingArmies:
            str = [NSString stringWithFormat:@"Move attacking armies -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case RKGameStateFortify:
            str = [NSString stringWithFormat:@"Fortify -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case RKGameStatePlaceFortifyingArmies:
            str = [NSString stringWithFormat:@"Place fortifying armies -- player %ld.", (long)currentPlayerNumber];
            break;
            
        default:
            str = @"<Unknown>.";
            break;
    }
    
    NSLog (@"-- Game state: %@.", str);
}

//----------------------------------------------------------------------

- (IBAction) showControlPanel:(id)sender
{
    [controlPanel orderFront:nil];
}

//----------------------------------------------------------------------

- (IBAction) showDiceInspector:(id)sender
{
    if (diceInspector == nil)
    {
        diceInspector = [[RKDiceInspector alloc] init];
    }
    
    [diceInspector showPanel];
}

//----------------------------------------------------------------------

- (IBAction) showWorldInfoPanel:(id)sender
{
    if (worldInfoController == nil)
    {
        worldInfoController = [[RKWorldInfoController alloc] init];
        [worldInfoController setWorld:world];
    }
    
    [worldInfoController showPanel];
}

//----------------------------------------------------------------------

- (BOOL) validateMenuItem:(NSMenuItem *)menuCell
{
    SEL action = menuCell.action;
    BOOL valid = NO;
    NSInteger tag = menuCell.tag;
    
    if (action == @selector (showPlayerConsole:))
    {
        NSAssert (tag > 0 && tag < MAX_PLAYERS, @"Tag for player number out of range.");
        
        if (players[tag] != nil)
            valid = YES;
    }
    else if (action == @selector (showControlPanel:)
             || action == @selector (showDiceInspector:)
             || action == @selector (showWorldInfoPanel:))
    {
        valid = YES;
    }
    
    return valid;
}

//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry
{
    countryNameTextField.stringValue = aCountry.countryName;
    
    if (players[currentPlayerNumber] != nil)
        [players[currentPlayerNumber] mouseDown:theEvent inCountry:aCountry];
}

//======================================================================
// General access to world data
//======================================================================

//----------------------------------------------------------------------

// Set the world to be used for the game.

- (void) setWorld:(RiskWorld *)newWorld
{
    // Can't change world while game is in progress.
    AssertGameState (RKGameStateNone);
    
    world = newWorld;
    
    mapView.countryArray = world.allCountries.allObjects;
    
    armyPlacementValidator = [[RKArmyPlacementValidator alloc] initWithRiskWorld:world];
}

//----------------------------------------------------------------------

- (void) setGameConfiguration:(RKGameConfiguration *)newGameConfiguration
{
    // Can't change the rules of a game in progress.
    AssertGameState (RKGameStateNone);
    
    configuration = newGameConfiguration;
}

//======================================================================
// For status view.
//======================================================================

- (BOOL) isPlayerActive:(RKPlayer)number
{
    NSAssert (number > 0 && number < MAX_PLAYERS, @"Player number out of range.");
    
    return playersActive[number];
}

//----------------------------------------------------------------------

- (RiskPlayer *) playerNumber:(RKPlayer)number
{
    NSAssert (number > 0 && number < MAX_PLAYERS, @"Player number out of range.");
    
    return players[number];
}

//======================================================================
// Player menu support
//======================================================================

- (IBAction) showPlayerConsole:(id)sender
{
    NSInteger tag;
    
    tag = [sender tag];
    NSAssert (tag > 0 && tag < MAX_PLAYERS, @"Tag for player number out of range.");
    
    if (players[tag] != nil)
        [players[tag] showConsolePanel:self];
}

//======================================================================
// Establish Game
//======================================================================

- (void) startNewGame
{
    NSAssert ([self gameInProgress] == NO, @"Game already in progress.");
    
    [mapView.window disableFlushWindow];
    for (RKCountry *country in world.allCountries)
    {
        country.playerNumber = 0;
    }
    //[mapView display]; // This is because drawCountry: doesn't draw the background... and it probably should.
    [mapView.window enableFlushWindow];
    
    gameState = RKGameStateEstablishingGame;
    
    // Set up card and discard decks.
    cardDeck = [world.cards mutableCopy];
    discardDeck = [[NSMutableArray alloc] init];
    
    nextCardSetValue = 4;
}

//----------------------------------------------------------------------

- (BOOL) addPlayer:(RiskPlayer *)aPlayer number:(RKPlayer)number
{
    // Can only add players while establishing a new game.
    AssertGameState (RKGameStateEstablishingGame);
    
    NSAssert (players[number] == nil, @"Already have a player in that slot.");
    //NSAssert ([type isKindOfClass:[RiskPlayer class]] == YES, @"Player class must be a subclass of RiskPlayer.");
    
    players[number] = aPlayer;
    playersActive[number] = YES;
    activePlayerCount++;
    
    players[number].playerToolMenu = [toolMenu itemWithTitle:[NSString stringWithFormat:@"Player %ld", (long)number]].target;
    
    return YES;
}

//----------------------------------------------------------------------

- (void) beginGame
{
    // Can't begin a game that hasn't been established
    AssertGameState (RKGameStateEstablishingGame);
    
    // Calculate initial army count
    initialArmyCount = RKInitialArmyCountForPlayers (activePlayerCount);
    
    [self tryToStart];
}

//----------------------------------------------------------------------

- (void) tryToStart
{
    // Turn done...
    [self endTurn];
}

//----------------------------------------------------------------------

- (void) stopGame
{
    int l;
    
    gameState = RKGameStateNone;
    
    for (l = 1; l < MAX_PLAYERS; l++)
    {
        [self deactivatePlayerNumber:l];
    }
    
    activePlayerCount = 0;
    currentPlayerNumber = 0;
    
    // cardDeck will be a mutable copy of the world cards.
    SNRelease (cardDeck);
    [discardDeck removeAllObjects];
    
    if (currentPhaseView != nil)
    {
        [currentPhaseView removeFromSuperview];
        currentPhaseView = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RKGameOverNotification
                                                        object:self];
}

//======================================================================
// Game State
//======================================================================

- (BOOL) gameInProgress
{
    return gameState != RKGameStateNone;
}

//----------------------------------------------------------------------

- (void) enteringChooseCountriesPhase
{
    currentPlayerNumber = 0;
    while ([self nextActivePlayer] == NO)
    {
        [players[currentPlayerNumber] willBeginChoosingCountries];
    }
}

//----------------------------------------------------------------------

- (void) leavingChooseCountriesPhase
{
    currentPlayerNumber = 0;
    while ([self nextActivePlayer] == NO)
    {
        [players[currentPlayerNumber] willEndChoosingCountries];
    }
}

//----------------------------------------------------------------------

- (void) enteringInitialArmyPlacementPhase
{
    currentPlayerNumber = 0;
    while ([self nextActivePlayer] == NO)
    {
        [players[currentPlayerNumber] willBeginPlacingInitialArmies];
    }
}

//----------------------------------------------------------------------

- (void) leavingInitialArmyPlacementPhase
{
    currentPlayerNumber = 0;
    while ([self nextActivePlayer] == NO)
    {
        [players[currentPlayerNumber] willEndPlacingInitialArmies];
    }
}

//----------------------------------------------------------------------
// This method changes the game state to the next state, and sets up the
// user interface elements for that state.  The normal
// state progression is:
//
//   No Game -> Establishing Game -> Choose Countries -> Place Initial Armies
//   -> Place Armies -> Attack -> Fortify
//   -> Place Armies -> Attack -> Fortify
//   -> Place Armies -> Attack -> Fortify ...
//
//
// In addition, there are special methods to enter other game states.
//----------------------------------------------------------------------

// Option to skip fortify phase?
- (void) endTurn
{
    BOOL isInteractivePlayer;
    NSView *newPhaseView;
    RKFortifyRule fortifyRule;
    int count, tmp;
    
    NSAssert (gameState != RKGameStateNone /*&& gameState != RKGameStateEstablishingGame*/, @"No game in progess.");
    
    //[self _logGameState];
    
    // 1. Determine next phase.
    // 2. Setup UI elements for that phase (switched view).
    // 3. Initiate the phase.
    
    // Determine next phase.
    switch (gameState)
    {
        case RKGameStateEstablishingGame:
            gameState = RKGameStateChoosingCountries;
            if (configuration.initialCountryDistribution == RKInitialCountryDistributionRandomlyChosen)
            {
                [self randomlyChooseCountriesForActivePlayers];
                gameState = RKGameStatePlaceInitialArmies;
                [self enteringInitialArmyPlacementPhase];
            }
            else
            {
                [self enteringChooseCountriesPhase];
            }
            
            currentPlayerNumber = 0;
            [self nextActivePlayer];
            break;
            
        case RKGameStateChoosingCountries:
            if ([self unoccupiedCountries].count > 0)
            {
                [mapView selectCountry:nil];
                [self nextActivePlayer];
            }
            else
            {
                [self leavingChooseCountriesPhase];
                gameState = RKGameStatePlaceInitialArmies;
                [self enteringInitialArmyPlacementPhase];
                currentPlayerNumber = 0;
                [self nextActivePlayer];
            }
            
            break;
            
        case RKGameStatePlaceInitialArmies:
            [mapView selectCountry:nil];
            if ([self nextActivePlayer] == YES)
            {
                initialArmyCount -= configuration.armyPlacementCount;
            }
            //NSLog (@"initial army count: %d", initialArmyCount);
            if (initialArmyCount < 1)
            {
                [self leavingInitialArmyPlacementPhase];
                gameState = RKGameStatePlaceArmies;
                currentPlayerNumber = 0;
                [self nextActivePlayer];
                [players[currentPlayerNumber] willBeginTurn];
                [self setArmiesLeftToPlace:[self earnedArmyCountForPlayer:currentPlayerNumber]];
            }
            break;
            
        case RKGameStatePlaceArmies:
            if (armiesLeftToPlace > 0)
            {
                NSLog (@"Player %ld has %d unplaced armies.", (long)currentPlayerNumber, armiesLeftToPlace);
            }
            gameState = RKGameStateAttack;
            break;
            
        case RKGameStateAttack:
            if (playerHasConqueredCountry == YES)
            {
                // Deal a card to the player.
                [self dealCardToPlayerNumber:currentPlayerNumber];
            }
            gameState = RKGameStateFortify;
            armiesBefore = [self totalTroopsForPlayerNumber:currentPlayerNumber];
            //NSLog (@"Attack->Fortify, player %d, armies: %d", currentPlayerNumber, armiesBefore);
            break;
            
        case RKGameStateMoveAttackingArmies:
            // Go back to the attack phase:
            if (players[currentPlayerNumber].playerCards.count > 4)
            {
                // Force the player to turn in cards.
                gameState = RKGameStatePlaceArmies;
                [self setArmiesLeftToPlace:0];
            }
            else
            {
                gameState = RKGameStateAttack;
            }
            break;
            
        case RKGameStateFortify:
            tmp = [self totalTroopsForPlayerNumber:currentPlayerNumber];
            //NSLog (@"Fortify->next, Player %d: armies before = %d, armies now = %d", currentPlayerNumber, armiesBefore, tmp);
            if (armiesBefore != tmp)
            {
                NSLog (@"!!Player %ld: armies before = %d, armies now = %d", (long)currentPlayerNumber, armiesBefore, tmp);
            }
            [players[currentPlayerNumber] willEndTurn];
            gameState = RKGameStatePlaceArmies;
            [self nextActivePlayer];
            [players[currentPlayerNumber] willBeginTurn];
            [self setArmiesLeftToPlace:[self earnedArmyCountForPlayer:currentPlayerNumber]];
            break;
            
        case RKGameStatePlaceFortifyingArmies:
            fortifyRule = configuration.fortifyRule;
            if (fortifyRule == RKFortifyRuleOneToOneNeighbor || fortifyRule == RKFortifyRuleOneToManyNeighbors)
            {
                tmp = [self totalTroopsForPlayerNumber:currentPlayerNumber];
                //NSLog (@"PlaceFortify->next, Player %d: armies before = %d, armies now = %d",currentPlayerNumber, armiesBefore, tmp);
                if (armiesBefore != tmp)
                {
                    NSLog (@"!!Player %ld: armies before = %d, armies now = %d", (long)currentPlayerNumber, armiesBefore, tmp);
                }
                [players[currentPlayerNumber] willEndTurn];
                gameState = RKGameStatePlaceArmies;
                [self nextActivePlayer];
                [players[currentPlayerNumber] willBeginTurn];
                [self setArmiesLeftToPlace:[self earnedArmyCountForPlayer:currentPlayerNumber]];
            }
            else
            {
                gameState = RKGameStateFortify;
            }
            break;
            
        default:
            NSLog (@"Invalid game state.");
    }
    
    //[self _logGameState];
    //NSLog (@"active player count: %d", activePlayerCount);
    
    //------------------------------------------------------------
    //if (currentPhaseView != nil)
    //{
    //    [currentPhaseView removeFromSuperview];
    //    currentPhaseView = nil;
    //}
    
    if (activePlayerCount < 2)
    {
        //NSLog (@"Will not continue with game...");
        return;
    }
    
    isInteractivePlayer = players[currentPlayerNumber].interactive;
    newPhaseView = nil;
    
    //[controlPanel makeMainWindow];
    
    if (players[currentPlayerNumber].interactive == YES)
    {
        [mapView.window makeKeyWindow];
    }
    
    // Update phase controls for this new phase:
    switch (gameState)
    {
        case RKGameStateChoosingCountries:
            newPhaseView = (isInteractivePlayer == YES) ? phaseChooseCountries : phaseComputerMove;
            break;
            
        case RKGameStatePlaceInitialArmies:
            newPhaseView = (isInteractivePlayer == YES) ? phasePlaceArmies : phaseComputerMove;
            
            // Do this here to avoid a little bit of flicker.
            initialArmiesLeftTextField.intValue = initialArmyCount;
            
            count = configuration.armyPlacementCount;
            if (initialArmyCount < count)
                count = initialArmyCount;
            [self setArmiesLeftToPlace:count];
            
            [armyPlacementValidator placeInAnyCountryForPlayerNumber:currentPlayerNumber];
            
            // You can always review your cards, even if you have none.
            if ([players[currentPlayerNumber] canTurnInCardSet] == YES)
                [turnInCardsButton setEnabled:YES];
            else
                [turnInCardsButton setEnabled:NO];
            
            break;
            
        case RKGameStatePlaceArmies:
            [mapView selectCountry:nil];
            newPhaseView = (isInteractivePlayer == YES) ? phasePlaceArmies : phaseComputerMove;
            
            initialArmiesLeftTextField.stringValue = @"--";
            [armyPlacementValidator placeInAnyCountryForPlayerNumber:currentPlayerNumber];
            
            // You can always review your cards, even if you have none.
            if ([players[currentPlayerNumber] canTurnInCardSet] == YES)
                [turnInCardsButton setEnabled:YES];
            else
                [turnInCardsButton setEnabled:NO];
            break;
            
        case RKGameStateAttack:
            newPhaseView = (isInteractivePlayer == YES) ? phaseAttack : phaseComputerMove;
            [self takeAttackMethodFromPlayerNumber:currentPlayerNumber];
            attackingFromTextField.stringValue = @"";
            break;
            
        case RKGameStateFortify:
            newPhaseView = (isInteractivePlayer == YES) ? phaseFortify : phaseComputerMove;
            break;
            
        case RKGameStateMoveAttackingArmies:
        case RKGameStatePlaceFortifyingArmies:
            // These states are entered in a different manner.
        default:
            NSLog (@"Invalid game state.");
    }
    
    // Now set up player stuff in "Turn Phase" box:
    nameTextField.stringValue = players[currentPlayerNumber].playerName;
    playerColorWell.color = [[RKBoardSetup instance] colorForPlayer:currentPlayerNumber];
    
    [self updatePhaseBox];
    
    if (newPhaseView != nil)
    {
        if (!currentPhaseView) {
            [controlPanel.contentView addSubview:newPhaseView];
            [newPhaseView setFrameOrigin:NSMakePoint (281, 8)];
        } else {
            [controlPanel.contentView replaceSubview:currentPhaseView with:newPhaseView];
        }
        [newPhaseView setFrameOrigin:NSMakePoint (281, 8)];
        currentPhaseView = newPhaseView;
        // Show updated panel immediately.
        //[newPhaseView display];
        [newPhaseView setNeedsDisplay:YES];
        [statusView setNeedsDisplay:YES];
        //[controlPanel display]; // And this in turn will redisplay the status view.
    }
    else
    {
        [self _logGameState];
    }
    
    if (activePlayerCount > 1)
    {
        // Prevent deep recursion:
        [self performSelector:@selector (executeCurrentPhase:) withObject:self afterDelay:0];
    }
    else
    {
        //NSLog (@"The game should be over...");
    }
}

//----------------------------------------------------------------------

- (IBAction) executeCurrentPhase:(id)sender
{
    //NSLog (@"active player count: %d", activePlayerCount);
    //[self _logGameState];
    
    // Initiate next phase
    switch (gameState)
    {
        case RKGameStateChoosingCountries:
            [players[currentPlayerNumber] chooseCountry];
            break;
            
        case RKGameStatePlaceInitialArmies:
            [players[currentPlayerNumber] placeInitialArmies:armiesLeftToPlace];
            break;
            
        case RKGameStatePlaceArmies:
            [self resetMovableArmiesForPlayerNumber:currentPlayerNumber];
            //NSLog (@"current player: %d, count: %d", currentPlayerNumber, [[players[currentPlayerNumber] playerCards] count]);
            if (players[currentPlayerNumber].playerCards.count > 4)
            {
                [players[currentPlayerNumber] mustTurnInCards];
                [self automaticallyTurnInCardsForPlayerNumber:currentPlayerNumber];
            }
            else
            {
                [players[currentPlayerNumber] mayTurnInCards];
            }
            [players[currentPlayerNumber] placeArmies:armiesLeftToPlace];
            break;
            
        case RKGameStateAttack:
            [players[currentPlayerNumber] attackPhase];
            break;
            
        case RKGameStateMoveAttackingArmies:
            //NSLog (@"player #%d", currentPlayerNumber);
            [players[currentPlayerNumber] moveAttackingArmies:armiesLeftToPlace
                                                      between:[armyPlacementValidator sourceCountry]:[armyPlacementValidator destinationCountry]];
            break;
            
        case RKGameStateFortify:
            [players[currentPlayerNumber] fortifyPhase:configuration.fortifyRule];
            break;
            
        case RKGameStatePlaceFortifyingArmies:
            //NSLog (@"Fortifying %d armies from: %@", armiesLeftToPlace, sourceCountry);
            [players[currentPlayerNumber] placeFortifyingArmies:armiesLeftToPlace
                                                    fromCountry:[armyPlacementValidator sourceCountry]];
            break;
            
        default:
            NSLog (@"Invalid game state.");
    }
}

//----------------------------------------------------------------------
// Advance to next active player (regardless of current phase)
// Returns whether it wrapped.
//----------------------------------------------------------------------

- (BOOL) nextActivePlayer
{
    BOOL wrappedFlag;
    int limit;
    //int l;
    
    wrappedFlag = NO;
    limit = MAX_PLAYERS;
    // 0 1 2 3 4 5 6
#if 0
    for (l = 0; l < MAX_PLAYERS; l++)
    {
        NSLog (@"[%d]: %@ %@", l, (playersActive[l] == YES) ? @"Y" : @"N", players[l]);
    }
    NSLog (@"currentPlayerNumber: %d", currentPlayerNumber);
#endif
    do
    {
        currentPlayerNumber = (currentPlayerNumber + 1) % MAX_PLAYERS;
        if (currentPlayerNumber == 0)
            wrappedFlag = YES;
    }
    while (--limit > 0 && playersActive[currentPlayerNumber] == NO);
    
    //NSLog (@"limit: %d", limit);
    NSAssert (limit != 0, @"No active players.");
    
    playerHasConqueredCountry = NO;
    
    return wrappedFlag;
}

//----------------------------------------------------------------------

- (IBAction) fortify:(id)sender
{
    // Fortify action should only be executed during the attack phase.
    AssertGameState (RKGameStateAttack);
    
    [self endTurn];
}

//----------------------------------------------------------------------

// End turn for interactive player.  May skip over fortify phase.
- (IBAction) endTurn:(id)sender
{
    // End turn action should only be executed in either the attack or fortify phase.
    AssertGameState2 (RKGameStateAttack, RKGameStateFortify);
    
    [self endTurn];
    if (gameState == RKGameStateFortify)
        [self endTurn];
}

//----------------------------------------------------------------------

- (void) moveAttackingArmies:(int)minimum between:(RKCountry *)source :(RKCountry *)destination
{
    BOOL isInteractivePlayer;
    NSView *newPhaseView;
    int count;
    
    AssertGameState (RKGameStateAttack);
    
    // Allow the movement of the remaining armies into either source or destination.
    
    destination.troopCount = minimum;
    
    count = source.troopCount - minimum;
    
    //NSLog (@"minimum: %d, armiesLeftToPlace: %d", minimum, count);
    
    gameState = RKGameStateMoveAttackingArmies;
    
    // What if armiesLeftToPlace == 0?
    [armyPlacementValidator placeInEitherCountry:source orCountry:destination forPlayerNumber:currentPlayerNumber];
    source.troopCount = 0;
    [mapView drawCountry:source];
    
    if (currentPhaseView != nil)
    {
        [currentPhaseView removeFromSuperview];
        currentPhaseView = nil;
    }
    
    isInteractivePlayer = players[currentPlayerNumber].interactive;
    newPhaseView = (isInteractivePlayer == YES) ? phasePlaceArmies : phaseComputerMove;
    
    [self updatePhaseBox];
    
    // From above:
    initialArmiesLeftTextField.stringValue = @"--";
    
    [self setArmiesLeftToPlace:count];
    
    // You can always review your cards, even if you have none.
    if ([players[currentPlayerNumber] canTurnInCardSet] == YES)
        [turnInCardsButton setEnabled:YES];
    else
        [turnInCardsButton setEnabled:NO];
    
    [controlPanel.contentView addSubview:newPhaseView];
    [newPhaseView setFrameOrigin:NSMakePoint (281, 8)];
    currentPhaseView = newPhaseView;
    [newPhaseView setNeedsDisplay:YES];
    
    // Break the recursion:
    [self performSelector:@selector (executeCurrentPhase:) withObject:self afterDelay:0];
}

//----------------------------------------------------------------------

- (void) fortifyArmiesFrom:(RKCountry *)source
{
    BOOL isInteractivePlayer;
    NSView *newPhaseView;
    
    //NSLog (@"source: %@", source);
    
    AssertGameState (RKGameStateFortify);
    int count = source.movableTroopCount;
    
    if (count < 1)
        return;
    
    gameState = RKGameStatePlaceFortifyingArmies;
    
    // Need to base this on current fortify rule
    
    RKFortifyRule fortifyRule = configuration.fortifyRule;
    switch (fortifyRule)
    {
        case RKFortifyRuleOneToOneNeighbor:
            //NSLog (@"1:1");
            [armyPlacementValidator placeInOneNeighborOfCountry:source forPlayerNumber:currentPlayerNumber];
            break;
            
        case RKFortifyRuleOneToManyNeighbors:
            //NSLog (@"1:N");
            [armyPlacementValidator placeInAnyNeighborOfCountry:source forPlayerNumber:currentPlayerNumber];
            break;
            
        case RKFortifyRuleManyToManyNeighbors:
            //NSLog (@"N:M");
            [armyPlacementValidator placeInAnyNeighborOfCountry:source forPlayerNumber:currentPlayerNumber];
            break;
            
        case RKFortifyRuleManyToManyConnected:
            //NSLog (@"N:M*");
            [armyPlacementValidator placeInConnectedCountries:source forPlayerNumber:currentPlayerNumber];
            break;
            
        default:
            [armyPlacementValidator placeInOneNeighborOfCountry:source forPlayerNumber:currentPlayerNumber];
            NSLog (@"Unknown fortify rule: %d", fortifyRule);
    }
    
    source.troopCount = source.unmovableTroopCount;
    [mapView drawCountry:source];
    
    if (currentPhaseView != nil)
    {
        [currentPhaseView removeFromSuperview];
        currentPhaseView = nil;
    }
    
    isInteractivePlayer = players[currentPlayerNumber].interactive;
    newPhaseView = (isInteractivePlayer == YES) ? phasePlaceArmies : phaseComputerMove;
    
    [self updatePhaseBox];
    
    // From above:
    initialArmiesLeftTextField.stringValue = @"--";
    [self setArmiesLeftToPlace:count];
    
    [turnInCardsButton setEnabled:NO];
    
    [controlPanel.contentView addSubview:newPhaseView];
    [newPhaseView setFrameOrigin:NSMakePoint (281, 8)];
    currentPhaseView = newPhaseView;
    [newPhaseView setNeedsDisplay:YES];
    
    // Prevent deep recursion:
    [self performSelector:@selector (executeCurrentPhase:) withObject:self afterDelay:0];
}

//----------------------------------------------------------------------

- (void) forceCurrentPlayerToTurnInCards
{
    BOOL isInteractivePlayer;
    NSView *newPhaseView;
    
    AssertGameState (RKGameStateAttack);
    
    isInteractivePlayer = players[currentPlayerNumber].interactive;
    
    gameState = RKGameStatePlaceArmies;
    [self setArmiesLeftToPlace:0];
    
    [mapView selectCountry:nil];
    newPhaseView = (isInteractivePlayer == YES) ? phasePlaceArmies : phaseComputerMove;
    
    initialArmiesLeftTextField.stringValue = @"--";
    [armyPlacementValidator placeInAnyCountryForPlayerNumber:currentPlayerNumber];
    
    [turnInCardsButton setEnabled:YES];
    
    [controlPanel.contentView addSubview:newPhaseView];
    [newPhaseView setFrameOrigin:NSMakePoint (281, 8)];
    currentPhaseView = newPhaseView;
    
    // Show updated panel immediately.
    [newPhaseView setNeedsDisplay:YES];
    [statusView setNeedsDisplay:YES];
    
    // Prevent deep recursion:
    [self performSelector:@selector (executeCurrentPhase:) withObject:self afterDelay:0];
}

//----------------------------------------------------------------------

- (void) resetMovableArmiesForPlayerNumber:(RKPlayer)number
{
    NSSet *countries;
    
    countries = [world countriesForPlayer:number];
    
    for (RKCountry *country in countries)
    {
        [country resetUnmovableTroops];
    }
}

//======================================================================
// Choose countries
//======================================================================

- (BOOL) player:(RiskPlayer *)aPlayer choseCountry:(RKCountry *)country
{
    RKPlayer number;
    BOOL valid;
    
    AssertGameState (RKGameStateChoosingCountries);
    
    number = aPlayer.playerNumber;
    NSAssert (currentPlayerNumber == number, @"Not your turn.");
    
    valid = NO;
    
    if (country.playerNumber == 0)
    {
        country.playerNumber = number;
        valid = YES;
    }
    
    return valid;
}

//----------------------------------------------------------------------

// unoccupied means playerNumber == 0 (not troopCounty == 0)
- (NSArray *) unoccupiedCountries
{
    NSMutableArray *array;
    
    array = [NSMutableArray array];
    for (RKCountry *country in world.allCountries)
    {
        if (country.playerNumber == 0)
            [array addObject:country];
    }
    
    return array;
}

//----------------------------------------------------------------------

- (void) randomlyChooseCountriesForActivePlayers
{
    NSMutableArray *array;
    RKCountry *country;
    NSInteger count, index;
    
    AssertGameState (RKGameStateChoosingCountries);
    
    currentPlayerNumber = 0;
    array = [NSMutableArray arrayWithArray:world.allCountries.allObjects];
    count = array.count;
    while (count > 0)
    {
        [self nextActivePlayer];
        index = [rng randomNumberModulo:count];
        country = array[index];
        country.playerNumber = currentPlayerNumber;
        [array removeObjectAtIndex:index];
        count--;
    }
}

//======================================================================
// Place Armies
//======================================================================

- (BOOL) player:(RiskPlayer *)aPlayer placesArmies:(int)count inCountry:(RKCountry *)country
{
    BOOL okay;
    
    AssertGameState4 (RKGameStatePlaceArmies, RKGameStatePlaceInitialArmies, RKGameStateMoveAttackingArmies, RKGameStatePlaceFortifyingArmies);
    NSAssert2 (count <= armiesLeftToPlace, @"Tried to place too many(%d) armies.  max: %d ", count, armiesLeftToPlace);
    
    okay = [armyPlacementValidator validatePlacement:country];
    if (okay == YES)
    {
        [armyPlacementValidator placeArmies:count inCountry:country];
        if (gameState == RKGameStatePlaceFortifyingArmies)
        {
            [country addUnmovableTroopCount:count];
        }
        armiesLeftToPlace -= count;
        if (gameState == RKGameStatePlaceInitialArmies)
            initialArmiesLeftTextField.intValue = initialArmiesLeftTextField.intValue - count;
        [self setArmiesLeftToPlace:armiesLeftToPlace];
    }
    
    [country update];
    
    return okay;
}

//======================================================================
// Attacking
//======================================================================

- (RKAttackResult) attackUntilUnableToContinueFromCountry:(RKCountry *)attacker
                                                toCountry:(RKCountry *)defender
                                 moveAllArmiesUponVictory:(BOOL)moveFlag
{
    RKAttackResult attackResult;
    
    attackResult.conqueredCountry = NO;
    
    while (attackResult.conqueredCountry == NO && attacker.troopCount > 0)
    {
        attackResult = [self attackOnceFromCountry:attacker toCountry:defender moveAllArmiesUponVictory:moveFlag];
    }
    
    return attackResult;
}

//----------------------------------------------------------------------

- (RKAttackResult) attackMultipleTimes:(int)count
                           fromCountry:(RKCountry *)attacker
                             toCountry:(RKCountry *)defender
              moveAllArmiesUponVictory:(BOOL)moveFlag
{
    RKAttackResult attackResult;
    
    attackResult.conqueredCountry = NO;
    
    while (count-- > 0 && attackResult.conqueredCountry == NO && attacker.troopCount > 0)
    {
        attackResult = [self attackOnceFromCountry:attacker toCountry:defender moveAllArmiesUponVictory:moveFlag];
    }
    
    return attackResult;
}

//----------------------------------------------------------------------

- (RKAttackResult) attackFromCountry:(RKCountry *)attacker
                           toCountry:(RKCountry *)defender
                   untilArmiesRemain:(int)count
            moveAllArmiesUponVictory:(BOOL)moveFlag
{
    RKAttackResult attackResult;
    
    attackResult.conqueredCountry = NO;
    
    count = MAX (count, 0);
    
    while (attackResult.conqueredCountry == NO && attacker.troopCount > count)
    {
        attackResult = [self attackOnceFromCountry:attacker toCountry:defender moveAllArmiesUponVictory:moveFlag];
    }
    
    return attackResult;
}

//----------------------------------------------------------------------
// Specify move flag to avoid distracting switch of phase view for
// interactive players.
//
// When moveFlag == YES, we don't re-enter the attack phase, and
// therefore are not forced to turn in card sets when we have > 4
// cards.
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// 1. Figure out how many dice to roll.
// 2. Get numbers for the dice. The arrays come back sorted.
// 3. Show the dice if needed.
// 4. Figure out how many countries each side loses.
//    - Notify the computer player that it has been attacked so that
//      it can retaliate later.
// 5. Now see if the defender lost.
//    - If the country is conquered, notify the computer player that
//      it has lost a country so that it can retaliate later.
//----------------------------------------------------------------------

- (RKAttackResult) attackOnceFromCountry:(RKCountry *)attacker
                               toCountry:(RKCountry *)defender
                moveAllArmiesUponVictory:(BOOL)moveFlag
{
    RKAttackResult attackResult;
    RKDiceRoll diceRoll;
    int compareCount;
    int l;
    int attackerLosses, defenderLosses;
    RKPlayer attackingPlayerNumber, defendingPlayerNumber;
    RKGameState initialGameState;
    BOOL isGameOver;
    
    NSAssert ([defender isAdjacentToCountry:attacker] == YES, @"The countries are not neighbors.");
    
    initialGameState = gameState;
    
    attackResult.conqueredCountry = NO;
    isGameOver = NO;
    
    attackingPlayerNumber = attacker.playerNumber;
    defendingPlayerNumber = defender.playerNumber;
    
    diceRoll = [self rollDiceWithAttackerArmies:attacker.troopCount defenderArmies:defender.troopCount];
    // return YES if we won -- enter GameStateMoveAttackingArmies state
    
    if (diceInspector != nil && diceInspector.panelOnScreen == YES)
    {
        [diceInspector showAttackFromCountry:attacker
                                   toCountry:defender
                                    withDice:diceRoll];
    }
    
    compareCount = MIN (diceRoll.attackerDieCount, diceRoll.defenderDieCount);
    attackerLosses = 0;
    defenderLosses = 0;
    for (l = 0; l < compareCount; l++)
    {
        if (diceRoll.attackerDice[l] > diceRoll.defenderDice[l])
            defenderLosses++;
        else
            attackerLosses++;
    }
    
    if (attackerLosses > 0)
    {
        [attacker addTroops:-attackerLosses];
        [mapView drawCountry:attacker];
    }
    
    [players[defendingPlayerNumber] playerNumber:attackingPlayerNumber attackedCountry:defender];
    
    if (defenderLosses > 0)
    {
        [defender addTroops:-defenderLosses];
        [mapView drawCountry:defender];
        
        // Still have to work out precise details...  Old version always has 1 army in each country.
        // How do we adjust for same effect, since we allow countries with troopCount == 0?
        
        // Defender doesn't lose until troopCount < 0...
        if (defender.troopCount < 0)
        {
            [players[defendingPlayerNumber] playerNumber:attackingPlayerNumber capturedCountry:defender];
            defender.playerNumber = attackingPlayerNumber;
            defender.troopCount = 0;
            [mapView drawCountry:defender];
            attackResult.conqueredCountry = YES;
            
            // Now, check to see if that was the last country of the defender.
            if ([world countriesForPlayer:defendingPlayerNumber].count == 0)
            {
                [self transferCardsFromPlayer:players[defendingPlayerNumber] toPlayer:players[attackingPlayerNumber]];
                isGameOver = [self checkForEndOfPlayerNumber:defendingPlayerNumber];
                // And, check to see if activePlayerCount == 1
                // Perhaps delay until after armies moved...
            }
            
            if (isGameOver == NO)
            {
                if (moveFlag == YES)
                {
                    defender.troopCount = attacker.troopCount;
                    attacker.troopCount = 0;
                    [mapView drawCountry:attacker]; // May no longer need with removal of ARMY class...
                    [mapView drawCountry:defender];
                    
                    if (players[attackingPlayerNumber].playerCards.count > 4)
                    {
                        // And make sure we're back in the place armies phase...
                        [self forceCurrentPlayerToTurnInCards];
                    }
                }
                else
                {
                    [self moveAttackingArmies:diceRoll.attackerDieCount between:attacker:defender];
                }
            }
            
            playerHasConqueredCountry = YES;
        }
    }
    
    // If the phase has changed, the player should return immediately.  If it has not changed,
    // the player may end the turn to enter the fortify phase.
    attackResult.phaseChanged = initialGameState != gameState;
    
    return attackResult;
}

//======================================================================
// Game Manager calculations
//======================================================================

- (int) earnedArmyCountForPlayer:(RKPlayer)number
{
    NSInteger count;
    
    // Calculated the number of armies earned at the beginning of a turn,
    // based on the number of countries/continents controller by that
    // player.
    
    count = ([world countriesForPlayer:number].count / 3) + [world continentBonusArmiesForPlayer:number];
    
    if (count < 3)
        count = 3;
    
    return (int)count;
}

//----------------------------------------------------------------------
// Roll dice based on number of attacking/defending armies.  Figures out
// proper number of dice to use, and returns sorted results.
//----------------------------------------------------------------------

- (RKDiceRoll) rollDiceWithAttackerArmies:(int)attackerArmies defenderArmies:(int)defenderArmies
{
    RKDiceRoll diceRoll;
    int l;
    int temp1, temp2, temp3;
    
    NSAssert (attackerArmies >= 0, @"Attacker army count must be positive.");
    NSAssert (defenderArmies >= 0, @"Defender army count must be positive.");
    
    temp1 = temp2 = temp3 = 0;
    
    // Calculate number of dice to use for attacker and defender
    diceRoll.attackerDieCount = (attackerArmies > 3) ? 3 : attackerArmies;
    diceRoll.defenderDieCount = (defenderArmies == 0) ? 1 : 2;
    
    // Roll dice and fill unused dice with 0 so that we can sort them.
    for (l = 0; l < diceRoll.attackerDieCount; l++)
        diceRoll.attackerDice[l] = (int)[rng rollDieWithSides:6];
    for (l = diceRoll.attackerDieCount; l < 3; l++)
        diceRoll.attackerDice[l] = 0;
    
    for (l = 0; l < diceRoll.defenderDieCount; l++)
        diceRoll.defenderDice[l] = (int)[rng rollDieWithSides:6];
    for (l = diceRoll.defenderDieCount; l < 2; l++)
        diceRoll.defenderDice[l] = 0;
    
    // sort the arrays
    if ((diceRoll.attackerDice[0] >= diceRoll.attackerDice[1]) && (diceRoll.attackerDice[0] >= diceRoll.attackerDice[2]))
    {
        temp1 = diceRoll.attackerDice[0];
        if (diceRoll.attackerDice[1] >= diceRoll.attackerDice[2])
        {
            temp2 = diceRoll.attackerDice[1];
            temp3 = diceRoll.attackerDice[2];
        }
        else
        {
            temp2 = diceRoll.attackerDice[2];
            temp3 = diceRoll.attackerDice[1];
        }
    }
    else if ((diceRoll.attackerDice[1] >= diceRoll.attackerDice[0]) && (diceRoll.attackerDice[1] >= diceRoll.attackerDice[2]))
    {
        temp1 = diceRoll.attackerDice[1];
        if (diceRoll.attackerDice[0] >= diceRoll.attackerDice[2])
        {
            temp2 = diceRoll.attackerDice[0];
            temp3 = diceRoll.attackerDice[2];
        }
        else
        {
            temp2 = diceRoll.attackerDice[2];
            temp3 = diceRoll.attackerDice[0];
        }
    }
    else if ((diceRoll.attackerDice[2] >= diceRoll.attackerDice[0]) && (diceRoll.attackerDice[2] >= diceRoll.attackerDice[1]))
    {
        temp1 = diceRoll.attackerDice[2];
        if (diceRoll.attackerDice[0] >= diceRoll.attackerDice[1])
        {
            temp2 = diceRoll.attackerDice[0];
            temp3 = diceRoll.attackerDice[1];
        }
        else
        {
            temp2 = diceRoll.attackerDice[1];
            temp3 = diceRoll.attackerDice[0];
        }
    }
    diceRoll.attackerDice[0] = temp1;
    diceRoll.attackerDice[1] = temp2;
    diceRoll.attackerDice[2] = temp3;
    if (diceRoll.defenderDice[1] > diceRoll.defenderDice[0])
    {
        temp1 = diceRoll.defenderDice[1];
        diceRoll.defenderDice[1] = diceRoll.defenderDice[0];
        diceRoll.defenderDice[0] = temp1;
    }
    
    return diceRoll;
}

//======================================================================
// General player interaction
//======================================================================

- (void) selectCountry:(RKCountry *)aCountry
{
    [mapView selectCountry:aCountry];
}

//----------------------------------------------------------------------

- (void) takeAttackMethodFromPlayerNumber:(RKPlayer)number
{
    RKAttackMethod attackMethod;
    int attackMethodValue;
    int index;
    
    attackMethod = players[number].attackMethod;
    attackMethodValue = players[number].attackMethodValue;
    
    switch (attackMethod)
    {
        case RKAttackMethodMultipleTimes:
            index = 1;
            break;
            
        case RKAttackMethodUntilArmiesRemain:
            index = 2;
            break;
            
        case RKAttackMethodUntilUnableToContinue:
            index = 3;
            break;
            
        case RKAttackMethodOnce:
        default:
            index = 0;
            break;
    }
    
    [attackMethodPopup selectItemAtIndex:index];
    
    methodCountSlider.intValue = attackMethodValue;
}

//----------------------------------------------------------------------

- (void) setAttackMethodForPlayerNumber:(RKPlayer)number
{
    NSInteger index;
    
    RKAttackMethod attackMethods[] = { RKAttackMethodOnce, RKAttackMethodMultipleTimes, RKAttackMethodUntilArmiesRemain, RKAttackMethodUntilUnableToContinue };
    
    index = attackMethodPopup.indexOfSelectedItem;
    if (index < 0 || index > 3)
        index = 0;
    
    players[number].attackMethod = attackMethods[index];
    players[number].attackMethodValue = methodCountSlider.intValue;
}

//----------------------------------------------------------------------

// Can't add ...Field, because, of course, then it will be used to set
// the connection.

- (void) setAttackingFromCountryName:(NSString *)string
{
    attackingFromTextField.stringValue = string;
}

//----------------------------------------------------------------------

- (IBAction) attackMethodAction:(id)sender
{
    if (sender == methodCountSlider)
    {
        [methodCountTextField takeIntValueFrom:sender];
    }
    else if (sender == methodCountTextField)
    {
        [methodCountSlider takeIntValueFrom:sender];
    }
    
    [self setAttackMethodForPlayerNumber:currentPlayerNumber];
}

//----------------------------------------------------------------------

- (void) setArmiesLeftToPlace:(int)count
{
    armiesLeftToPlace = count;
    armyView.armyCount = armiesLeftToPlace;
    armiesLeftToPlaceTextField.intValue = armiesLeftToPlace;
}

//======================================================================
// Card management
//======================================================================

- (void) _recycleDiscardedCards
{
    [cardDeck addObjectsFromArray:discardDeck];
    [discardDeck removeAllObjects];
}

//----------------------------------------------------------------------
// We don't shuffle the deck -- instead, we just choose a random card.
// This is fine as long as we don't want a deck inspector for debugging.
// It may also be an issue for saved games -- loading the same saved
// game multiple times will result in different ordering of the cards.
//----------------------------------------------------------------------

- (void) dealCardToPlayerNumber:(RKPlayer)number
{
    RKCard *card;
    NSInteger index, count;
    
    count = cardDeck.count;
    if (count == 0)
    {
        [self _recycleDiscardedCards];
        count = cardDeck.count;
    }
    
    if (count == 0)
        return;
    //NSAssert (count != 0, @"Ran out of cards!");
    
    index = [rng randomNumberModulo:count];
    card = cardDeck[index];
    [players[number] addCardToHand:card];
    [cardDeck removeObjectAtIndex:index];
    
    [statusView setNeedsDisplay:YES];
}

//----------------------------------------------------------------------

- (int) _valueOfNextCardSet:(int)currentValue
{
    RKCardSetRedemption cardSetRedemption;
    int nextValue;
    
    cardSetRedemption = configuration.cardSetRedemption;
    switch (cardSetRedemption)
    {
        case RKCardSetRedemptionIncreaseByOne:
            nextValue = currentValue + 1;
            break;
            
        case RKCardSetRedemptionIncreaseByFive:
            if (currentValue < 12)
                nextValue = currentValue + 2;
            else if (currentValue == 12)
                nextValue = 15;
            else
                nextValue = currentValue + 5;
            break;
            
        case RKCardSetRedemptionRemainConstant:
        default:
            nextValue = 5;
    }
    
    return nextValue;
}

//----------------------------------------------------------------------

- (int) armiesForNextCardSet
{
    return nextCardSetValue;
}

//----------------------------------------------------------------------
// The player is *NOT* responsible for removing cards from hand.
// How are computer players affected by the forced turning in of cards?
// i.e. There is placeArmies: followed by optionally turning in card sets
//      and then there is the forced turning in of card sets, followed by placeArmies:
//----------------------------------------------------------------------

- (void) turnInCardSet:(RKCardSet *)cardSet forPlayerNumber:(RKPlayer)number
{
    RKCard *card;
    RKCountry *country;
    
    AssertGameState (RKGameStatePlaceArmies);
    
    // Add number of armies to currently available armies for placement.
    // Add bonus armies to those card countries that we control.
    
    if (cardSet != nil)
    {
        //NSLog (@"turning in this card set: %@", cardSet);
        
        card = cardSet.card1;
        country = card.country;
        if (country.playerNumber == number)
        {
            [country addTroops:2];
            [mapView drawCountry:country];
        }
        [players[number] removeCardFromHand:card];
        [discardDeck addObject:card];
        
        card = cardSet.card2;
        country = card.country;
        if (country.playerNumber == number)
        {
            [country addTroops:2];
            [mapView drawCountry:country];
        }
        [players[number] removeCardFromHand:card];
        [discardDeck addObject:card];
        
        card = cardSet.card3;
        country = card.country;
        if (country.playerNumber == number)
        {
            [country addTroops:2];
            [mapView drawCountry:country];
        }
        [players[number] removeCardFromHand:card];
        [discardDeck addObject:card];
        
        [self setArmiesLeftToPlace:armiesLeftToPlace + nextCardSetValue];
        [players[number] didTurnInCards:nextCardSetValue];
        //armiesLeftToPlace += nextCardSetValue;
        nextCardSetValue = [self _valueOfNextCardSet:nextCardSetValue];
        
        [statusView setNeedsDisplay:YES];
    }
}

//----------------------------------------------------------------------
// For the currently active (interactive) player
//----------------------------------------------------------------------

- (IBAction) reviewCards:(id)sender
{
    [self _loadCardPanel];
    [cardPanelController runCardPanel:NO forPlayer:players[currentPlayerNumber]];
}

//----------------------------------------------------------------------

- (IBAction) turnInCards:(id)sender
{
    AssertGameState (RKGameStatePlaceArmies);
    
    [self _loadCardPanel];
    [cardPanelController runCardPanel:YES forPlayer:players[currentPlayerNumber]];
    
    if ([players[currentPlayerNumber] canTurnInCardSet] == YES)
    {
        [turnInCardsButton setEnabled:YES];
    }
    else
    {
        [turnInCardsButton setEnabled:NO];
    }
}

//----------------------------------------------------------------------

- (void) automaticallyTurnInCardsForPlayerNumber:(RKPlayer)number
{
    RKCardSet *cardSet;
    
    while (players[number].playerCards.count > 4)
    {
        cardSet = [players[number] bestSet];
        [self turnInCardSet:cardSet forPlayerNumber:number];
    }
}

//----------------------------------------------------------------------

- (void) transferCardsFromPlayer:(RiskPlayer *)source toPlayer:(RiskPlayer *)destination
{
    NSArray *cardArray = [NSArray arrayWithArray:source.playerCards];
    
    //NSLog (@"transfering %d cards.", [cardArray count]);
    
    for (RKCard *card in cardArray)
    {
        [source removeCardFromHand:card];
        [destination addCardToHand:card];
    }
    
    [statusView setNeedsDisplay:YES];
}

//----------------------------------------------------------------------

- (void) _loadCardPanel
{
    if (cardPanelController == nil)
    {
        cardPanelController = [[RKCardPanelController alloc] init];
        [cardPanelController setGameManager:self];
    }
}

//----------------------------------------------------------------------

- (void) updatePhaseBox
{
    if (players[currentPlayerNumber].interactive == YES)
    {
        infoTextField.stringValue = RKGameStateInfo (gameState);
        phaseTextField.stringValue = NSStringFromGameState (gameState);
    }
    else
    {
        phaseTextField.stringValue = @"Computer Move";
        infoTextField.stringValue = @"The computer player named above is moving, please wait.";
    }
}

//----------------------------------------------------------------------

- (int) totalTroopsForPlayerNumber:(RKPlayer)number
{
    int total = 0;
    
    for (RKCountry *country in [world countriesForPlayer:number])
    {
        total += country.troopCount;
    }
    
    return total;
}

//----------------------------------------------------------------------

- (void) defaultsChanged:(NSNotification *)aNotification
{
    if (currentPlayerNumber > 0)
        playerColorWell.color = [[RKBoardSetup instance] colorForPlayer:currentPlayerNumber];
}

//======================================================================
// End of game stuff:
//======================================================================

- (BOOL) checkForEndOfPlayerNumber:(RKPlayer)number
{
    BOOL isGameOver;
    RKPlayer winner;
    
    isGameOver = NO;
    
    if ([world countriesForPlayer:number].count == 0)
    {
        [self playerHasLost:number];
        if (activePlayerCount < 2)
        {
            isGameOver = YES;
        }
    }
    
    if (isGameOver == YES)
    {
        for (winner = 1; winner < MAX_PLAYERS; winner++)
        {
            if (playersActive[winner] == YES)
            {
                // Use notification instead, and the brain can do the alert panel.
                
                // And make gameState == gs_game_over...
                NSAlert *alert = [NSAlert new];
                alert.messageText = @"Victory";
                alert.informativeText = [NSString stringWithFormat:@"Winner was %@.", players[winner].playerName];
                [alert runModal];
                
                [self playerHasWon:winner];
                break;
            }
        }
        
        [self stopGame];
    }
    
    return isGameOver;
}

//----------------------------------------------------------------------

- (void) playerHasLost:(RKPlayer)number
{
    [players[number] youLostGame];
    [self deactivatePlayerNumber:number];
}

//----------------------------------------------------------------------

- (void) playerHasWon:(RKPlayer)number
{
    [players[number] youWonGame];
    [self deactivatePlayerNumber:number];
}

//----------------------------------------------------------------------
// 1. Release player
// 2. Free items of the player's submenu (if any), and disable the player menu.
//----------------------------------------------------------------------

- (void) deactivatePlayerNumber:(RKPlayer)number
{
    NSMenu *playerMenu;
    NSArray *itemArray;
    NSMenuItem *menuItem;
    
    if (playersActive[number] == YES)
    {
        playersActive[number] = NO;
        
        if (players[number] != nil)
        {
            playerMenu = players[number].playerToolMenu;
            itemArray = playerMenu.itemArray;
            while (itemArray.count > 1)
            {
                menuItem = itemArray.lastObject;
                //NSLog (@"removing item: %@", [menuItem title]);
                [playerMenu removeItem:menuItem];
            }
            
            // Best to autorelease, especially for the Human player.
            players[number] = nil;
        }
        
        activePlayerCount--;
    }
}

@end
