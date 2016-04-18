//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskGameManager.m,v 1.7 1997/12/18 21:03:46 nygard Exp $");

#import "RiskGameManager.h"

#import "ArmyPlacementValidator.h"
#import "ArmyView.h"
#import "BoardSetup.h"
#import "CardPanelController.h"
#import "CardSet.h"
#import "Country.h"
#import "DiceInspector.h"
#import "GameConfiguration.h"
#import "RiskCard.h"
#import "RiskMapView.h"
#import "RiskPlayer.h"
#import "RiskWorld.h"
#import "SNRandom.h"
#import "StatusView.h"
#import "WorldInfoController.h"

//======================================================================
// The RiskGameManager controls most of the game play.  It notifies
// the players of the various phases of game play, and does some
// checking of messages to try to limit invalid actions by players (or
// some cheating.)
//======================================================================

DEFINE_NSSTRING (RGMGameOverNotification);

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
        
        configuration = [[GameConfiguration alloc] init];;
        
        activePlayerCount = 0;
        
        for (int l = 0; l < MAX_PLAYERS; l++)
        {
            players[l] = nil;
            playersActive[l] = NO;
        }
        
        initialArmyCount = 0;
        gameState = gs_no_game;
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
                                                     name:RiskBoardSetupPlayerColorsChangedNotification
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
    
#ifdef __APPLE_CPP__
    // We don't want to have to validate the items like we do menu items.
    [attackMethodPopup setAutoenablesItems:NO];
#endif
}

//----------------------------------------------------------------------

- (void) _logGameState
{
    NSString *str;
    
    switch (gameState)
    {
        case gs_no_game:
            str = @"No game";
            break;
            
        case gs_establishing_game:
            str = @"Establishing game.";
            break;
            
        case gs_choose_countries:
            str = [NSString stringWithFormat:@"Choose countries -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case gs_place_initial_armies:
            str = [NSString stringWithFormat:@"Place initial armies -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case gs_place_armies:
            str = [NSString stringWithFormat:@"Place armies -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case gs_attack:
            str = [NSString stringWithFormat:@"Attack -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case gs_move_attacking_armies:
            str = [NSString stringWithFormat:@"Move attacking armies -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case gs_fortify:
            str = [NSString stringWithFormat:@"Fortify -- player %ld.", (long)currentPlayerNumber];
            break;
            
        case gs_place_fortifying_armies:
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
        diceInspector = [[DiceInspector alloc] init];
    }
    
    [diceInspector showPanel];
}

//----------------------------------------------------------------------

- (IBAction) showWorldInfoPanel:(id)sender
{
    if (worldInfoController == nil)
    {
        worldInfoController = [[WorldInfoController alloc] init];
        [worldInfoController setWorld:world];
    }
    
    [worldInfoController showPanel];
}

//----------------------------------------------------------------------

- (BOOL) validateMenuItem:(NSMenuItem *)menuCell
{
    SEL action;
    BOOL valid;
    NSInteger tag;
    
    valid = NO;
    action = menuCell.action;
    tag = menuCell.tag;
    
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

// Set the country name in the map view.  Forward event to current player.
// This is the delegate method of RiskMapView.

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry
{
    countryNameTextField.stringValue = aCountry.countryName;
    
    if (players[currentPlayerNumber] != nil)
        [players[currentPlayerNumber] mouseDown:theEvent inCountry:aCountry];
}

//======================================================================
// General access to world data
//======================================================================

- (RiskWorld *) world
{
    return world;
}

//----------------------------------------------------------------------

// Set the world to be used for the game.

- (void) setWorld:(RiskWorld *)newWorld
{
    // Can't change world while game is in progress.
    AssertGameState (gs_no_game);
    
    world = newWorld;
    
    mapView.countryArray = world.allCountries.allObjects;
    
    SNRelease (armyPlacementValidator);
    armyPlacementValidator = [[ArmyPlacementValidator alloc] initWithRiskWorld:world];
}

//----------------------------------------------------------------------

- (void) setGameConfiguration:(GameConfiguration *)newGameConfiguration
{
    // Can't change the rules of a game in progress.
    AssertGameState (gs_no_game);
    
    configuration = newGameConfiguration;
}

//======================================================================
// For status view.
//======================================================================

- (BOOL) isPlayerActive:(Player)number
{
    NSAssert (number > 0 && number < MAX_PLAYERS, @"Player number out of range.");
    
    return playersActive[number];
}

//----------------------------------------------------------------------

- (RiskPlayer *) playerNumber:(Player)number
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
    NSEnumerator *countryEnumerator;
    Country *country;
    
    NSAssert ([self gameInProgress] == NO, @"Game already in progress.");
    
    countryEnumerator = [world.allCountries objectEnumerator];
    [mapView.window disableFlushWindow];
    while (country = [countryEnumerator nextObject])
    {
        country.playerNumber = 0;
    }
    //[mapView display]; // This is because drawCountry: doesn't draw the background... and it probably should.
    [mapView.window enableFlushWindow];
    
    gameState = gs_establishing_game;
    
    // Set up card and discard decks.
    cardDeck = [world.cards mutableCopy];
    
    nextCardSetValue = 4;
}

//----------------------------------------------------------------------

- (BOOL) addPlayer:(RiskPlayer *)aPlayer number:(Player)number
{
    // Can only add players while establishing a new game.
    AssertGameState (gs_establishing_game);
    
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
    AssertGameState (gs_establishing_game);
    
    // Calculate initial army count
    initialArmyCount = RiskInitialArmyCountForPlayers (activePlayerCount);
    
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
    
    gameState = gs_no_game;
    
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RGMGameOverNotification
                                                        object:self];
}

//======================================================================
// Game State
//======================================================================

- (BOOL) gameInProgress
{
    return gameState != gs_no_game;
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
    FortifyRule fortifyRule;
    int count, tmp;
    
    NSAssert (gameState != gs_no_game /*&& gameState != gs_establishing_game*/, @"No game in progess.");
    
    //[self _logGameState];
    
    // 1. Determine next phase.
    // 2. Setup UI elements for that phase (switched view).
    // 3. Initiate the phase.
    
    // Determine next phase.
    switch (gameState)
    {
        case gs_establishing_game:
            gameState = gs_choose_countries;
            if (configuration.initialCountryDistribution == RandomlyChosen)
            {
                [self randomlyChooseCountriesForActivePlayers];
                gameState = gs_place_initial_armies;
                [self enteringInitialArmyPlacementPhase];
            }
            else
            {
                [self enteringChooseCountriesPhase];
            }
            
            currentPlayerNumber = 0;
            [self nextActivePlayer];
            break;
            
        case gs_choose_countries:
            if ([self unoccupiedCountries].count > 0)
            {
                [mapView selectCountry:nil];
                [self nextActivePlayer];
            }
            else
            {
                [self leavingChooseCountriesPhase];
                gameState = gs_place_initial_armies;
                [self enteringInitialArmyPlacementPhase];
                currentPlayerNumber = 0;
                [self nextActivePlayer];
            }
            
            break;
            
        case gs_place_initial_armies:
            [mapView selectCountry:nil];
            if ([self nextActivePlayer] == YES)
            {
                initialArmyCount -= configuration.armyPlacementCount;
            }
            //NSLog (@"initial army count: %d", initialArmyCount);
            if (initialArmyCount < 1)
            {
                [self leavingInitialArmyPlacementPhase];
                gameState = gs_place_armies;
                currentPlayerNumber = 0;
                [self nextActivePlayer];
                [players[currentPlayerNumber] willBeginTurn];
                [self setArmiesLeftToPlace:[self earnedArmyCountForPlayer:currentPlayerNumber]];
            }
            break;
            
        case gs_place_armies:
            if (armiesLeftToPlace > 0)
            {
                NSLog (@"Player %ld has %d unplaced armies.", (long)currentPlayerNumber, armiesLeftToPlace);
            }
            gameState = gs_attack;
            break;
            
        case gs_attack:
            if (playerHasConqueredCountry == YES)
            {
                // Deal a card to the player.
                [self dealCardToPlayerNumber:currentPlayerNumber];
            }
            gameState = gs_fortify;
            armiesBefore = [self totalTroopsForPlayerNumber:currentPlayerNumber];
            //NSLog (@"Attack->Fortify, player %d, armies: %d", currentPlayerNumber, armiesBefore);
            break;
            
        case gs_move_attacking_armies:
            // Go back to the attack phase:
            if (players[currentPlayerNumber].playerCards.count > 4)
            {
                // Force the player to turn in cards.
                gameState = gs_place_armies;
                [self setArmiesLeftToPlace:0];
            }
            else
            {
                gameState = gs_attack;
            }
            break;
            
        case gs_fortify:
            tmp = [self totalTroopsForPlayerNumber:currentPlayerNumber];
            //NSLog (@"Fortify->next, Player %d: armies before = %d, armies now = %d", currentPlayerNumber, armiesBefore, tmp);
            if (armiesBefore != tmp)
            {
                NSLog (@"!!Player %ld: armies before = %d, armies now = %d", (long)currentPlayerNumber, armiesBefore, tmp);
            }
            [players[currentPlayerNumber] willEndTurn];
            gameState = gs_place_armies;
            [self nextActivePlayer];
            [players[currentPlayerNumber] willBeginTurn];
            [self setArmiesLeftToPlace:[self earnedArmyCountForPlayer:currentPlayerNumber]];
            break;
            
        case gs_place_fortifying_armies:
            fortifyRule = configuration.fortifyRule;
            if (fortifyRule == OneToOneNeighbor || fortifyRule == OneToManyNeighbors)
            {
                tmp = [self totalTroopsForPlayerNumber:currentPlayerNumber];
                //NSLog (@"PlaceFortify->next, Player %d: armies before = %d, armies now = %d",currentPlayerNumber, armiesBefore, tmp);
                if (armiesBefore != tmp)
                {
                    NSLog (@"!!Player %ld: armies before = %d, armies now = %d", (long)currentPlayerNumber, armiesBefore, tmp);
                }
                [players[currentPlayerNumber] willEndTurn];
                gameState = gs_place_armies;
                [self nextActivePlayer];
                [players[currentPlayerNumber] willBeginTurn];
                [self setArmiesLeftToPlace:[self earnedArmyCountForPlayer:currentPlayerNumber]];
            }
            else
            {
                gameState = gs_fortify;
            }
            break;
            
        default:
            NSLog (@"Invalid game state.");
    }
    
    //[self _logGameState];
    //NSLog (@"active player count: %d", activePlayerCount);
    
    //------------------------------------------------------------
    if (currentPhaseView != nil)
    {
        [currentPhaseView removeFromSuperview];
        currentPhaseView = nil;
    }
    
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
        case gs_choose_countries:
            newPhaseView = (isInteractivePlayer == YES) ? phaseChooseCountries : phaseComputerMove;
            break;
            
        case gs_place_initial_armies:
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
            
        case gs_place_armies:
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
            
        case gs_attack:
            newPhaseView = (isInteractivePlayer == YES) ? phaseAttack : phaseComputerMove;
            [self takeAttackMethodFromPlayerNumber:currentPlayerNumber];
            attackingFromTextField.stringValue = @"";
            break;
            
        case gs_fortify:
            newPhaseView = (isInteractivePlayer == YES) ? phaseFortify : phaseComputerMove;
            break;
            
        case gs_move_attacking_armies:
        case gs_place_fortifying_armies:
            // These states are entered in a different manner.
        default:
            NSLog (@"Invalid game state.");
    }
    
    // Now set up player stuff in "Turn Phase" box:
    nameTextField.stringValue = players[currentPlayerNumber].playerName;
    playerColorWell.color = [[BoardSetup instance] colorForPlayer:currentPlayerNumber];
    
    [self updatePhaseBox];
    
    if (newPhaseView != nil)
    {
        [controlPanel.contentView addSubview:newPhaseView];
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
        case gs_choose_countries:
            [players[currentPlayerNumber] chooseCountry];
            break;
            
        case gs_place_initial_armies:
            [players[currentPlayerNumber] placeInitialArmies:armiesLeftToPlace];
            break;
            
        case gs_place_armies:
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
            
        case gs_attack:
            [players[currentPlayerNumber] attackPhase];
            break;
            
        case gs_move_attacking_armies:
            //NSLog (@"player #%d", currentPlayerNumber);
            [players[currentPlayerNumber] moveAttackingArmies:armiesLeftToPlace
                                                      between:[armyPlacementValidator sourceCountry]:[armyPlacementValidator destinationCountry]];
            break;
            
        case gs_fortify:
            [players[currentPlayerNumber] fortifyPhase:configuration.fortifyRule];
            break;
            
        case gs_place_fortifying_armies:
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
    AssertGameState (gs_attack);
    
    [self endTurn];
}

//----------------------------------------------------------------------

// End turn for interactive player.  May skip over fortify phase.
- (IBAction) endTurn:(id)sender
{
    // End turn action should only be executed in either the attack or fortify phase.
    AssertGameState2 (gs_attack, gs_fortify);
    
    [self endTurn];
    if (gameState == gs_fortify)
        [self endTurn];
}

//----------------------------------------------------------------------

- (void) moveAttackingArmies:(int)minimum between:(Country *)source :(Country *)destination
{
    BOOL isInteractivePlayer;
    NSView *newPhaseView;
    int count;
    
    AssertGameState (gs_attack);
    
    // Allow the movement of the remaining armies into either source or destination.
    
    destination.troopCount = minimum;
    
    count = source.troopCount - minimum;
    
    //NSLog (@"minimum: %d, armiesLeftToPlace: %d", minimum, count);
    
    gameState = gs_move_attacking_armies;
    
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

- (void) fortifyArmiesFrom:(Country *)source
{
    BOOL isInteractivePlayer;
    NSView *newPhaseView;
    
    //NSLog (@"source: %@", source);
    
    AssertGameState (gs_fortify);
    int count = source.movableTroopCount;
    
    if (count < 1)
        return;
    
    gameState = gs_place_fortifying_armies;
    
    // Need to base this on current fortify rule
    
    FortifyRule fortifyRule = configuration.fortifyRule;
    switch (fortifyRule)
    {
        case OneToOneNeighbor:
            //NSLog (@"1:1");
            [armyPlacementValidator placeInOneNeighborOfCountry:source forPlayerNumber:currentPlayerNumber];
            break;
            
        case OneToManyNeighbors:
            //NSLog (@"1:N");
            [armyPlacementValidator placeInAnyNeighborOfCountry:source forPlayerNumber:currentPlayerNumber];
            break;
            
        case ManyToManyNeighbors:
            //NSLog (@"N:M");
            [armyPlacementValidator placeInAnyNeighborOfCountry:source forPlayerNumber:currentPlayerNumber];
            break;
            
        case ManyToManyConnected:
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
    
    AssertGameState (gs_attack);
    
    isInteractivePlayer = players[currentPlayerNumber].interactive;
    
    gameState = gs_place_armies;
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

- (void) resetMovableArmiesForPlayerNumber:(Player)number
{
    NSEnumerator *countryEnumerator;
    Country *country;
    
    countryEnumerator = [[world countriesForPlayer:number] objectEnumerator];
    
    while (country = [countryEnumerator nextObject])
    {
        [country resetUnmovableTroops];
    }
}

//======================================================================
// Choose countries
//======================================================================

- (BOOL) player:(RiskPlayer *)aPlayer choseCountry:(Country *)country
{
    Player number;
    BOOL valid;
    
    AssertGameState (gs_choose_countries);
    
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
    NSEnumerator *countryEnumerator;
    Country *country;
    
    array = [NSMutableArray array];
    countryEnumerator = [world.allCountries objectEnumerator];
    while (country = [countryEnumerator nextObject])
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
    Country *country;
    NSInteger count, index;
    
    AssertGameState (gs_choose_countries);
    
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

- (BOOL) player:(RiskPlayer *)aPlayer placesArmies:(int)count inCountry:(Country *)country
{
    BOOL okay;
    
    AssertGameState4 (gs_place_armies, gs_place_initial_armies, gs_move_attacking_armies, gs_place_fortifying_armies);
    NSAssert2 (count <= armiesLeftToPlace, @"Tried to place too many(%d) armies.  max: %d ", count, armiesLeftToPlace);
    
    okay = [armyPlacementValidator validatePlacement:country];
    if (okay == YES)
    {
        [armyPlacementValidator placeArmies:count inCountry:country];
        if (gameState == gs_place_fortifying_armies)
        {
            [country addUnmovableTroopCount:count];
        }
        armiesLeftToPlace -= count;
        if (gameState == gs_place_initial_armies)
            initialArmiesLeftTextField.intValue = initialArmiesLeftTextField.intValue - count;
        [self setArmiesLeftToPlace:armiesLeftToPlace];
    }
    
    [country update];
    
    return okay;
}

//======================================================================
// Attacking
//======================================================================

- (AttackResult) attackUntilUnableToContinueFromCountry:(Country *)attacker
                                              toCountry:(Country *)defender
                               moveAllArmiesUponVictory:(BOOL)moveFlag
{
    AttackResult attackResult;
    
    attackResult.conqueredCountry = NO;
    
    while (attackResult.conqueredCountry == NO && attacker.troopCount > 0)
    {
        attackResult = [self attackOnceFromCountry:attacker toCountry:defender moveAllArmiesUponVictory:moveFlag];
    }
    
    return attackResult;
}

//----------------------------------------------------------------------

- (AttackResult) attackMultipleTimes:(int)count
                         fromCountry:(Country *)attacker
                           toCountry:(Country *)defender
            moveAllArmiesUponVictory:(BOOL)moveFlag
{
    AttackResult attackResult;
    
    attackResult.conqueredCountry = NO;
    
    while (count-- > 0 && attackResult.conqueredCountry == NO && attacker.troopCount > 0)
    {
        attackResult = [self attackOnceFromCountry:attacker toCountry:defender moveAllArmiesUponVictory:moveFlag];
    }
    
    return attackResult;
}

//----------------------------------------------------------------------

- (AttackResult) attackFromCountry:(Country *)attacker
                         toCountry:(Country *)defender
                 untilArmiesRemain:(int)count
          moveAllArmiesUponVictory:(BOOL)moveFlag
{
    AttackResult attackResult;
    
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

- (AttackResult) attackOnceFromCountry:(Country *)attacker
                             toCountry:(Country *)defender
              moveAllArmiesUponVictory:(BOOL)moveFlag
{
    AttackResult attackResult;
    DiceRoll diceRoll;
    int compareCount;
    int l;
    int attackerLosses, defenderLosses;
    Player attackingPlayerNumber, defendingPlayerNumber;
    GameState initialGameState;
    BOOL isGameOver;
    
    NSAssert ([defender isAdjacentToCountry:attacker] == YES, @"The countries are not neighbors.");
    
    initialGameState = gameState;
    
    attackResult.conqueredCountry = NO;
    isGameOver = NO;
    
    attackingPlayerNumber = attacker.playerNumber;
    defendingPlayerNumber = defender.playerNumber;
    
    diceRoll = [self rollDiceWithAttackerArmies:attacker.troopCount defenderArmies:defender.troopCount];
    // return YES if we won -- enter gs_move_attacking_armies state
    
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

- (int) earnedArmyCountForPlayer:(Player)number
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

- (DiceRoll) rollDiceWithAttackerArmies:(int)attackerArmies defenderArmies:(int)defenderArmies
{
    DiceRoll diceRoll;
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

- (void) selectCountry:(Country *)aCountry
{
    [mapView selectCountry:aCountry];
}

//----------------------------------------------------------------------

- (void) takeAttackMethodFromPlayerNumber:(Player)number
{
    AttackMethod attackMethod;
    int attackMethodValue;
    int index;
    
    attackMethod = players[number].attackMethod;
    attackMethodValue = players[number].attackMethodValue;
    
    switch (attackMethod)
    {
        case AttackMultipleTimes:
            index = 1;
            break;
            
        case AttackUntilArmiesRemain:
            index = 2;
            break;
            
        case AttackUntilUnableToContinue:
            index = 3;
            break;
            
        case AttackOnce:
        default:
            index = 0;
            break;
    }
    
    [attackMethodPopup selectItemAtIndex:index];
    
    methodCountSlider.intValue = attackMethodValue;
}

//----------------------------------------------------------------------

- (void) setAttackMethodForPlayerNumber:(Player)number
{
    NSInteger index;
    
    AttackMethod attackMethods[] = { AttackOnce, AttackMultipleTimes, AttackUntilArmiesRemain, AttackUntilUnableToContinue };
    
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

- (void) dealCardToPlayerNumber:(Player)number
{
    RiskCard *card;
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
    CardSetRedemption cardSetRedemption;
    int nextValue;
    
    cardSetRedemption = configuration.cardSetRedemption;
    switch (cardSetRedemption)
    {
        case IncreaseByOne:
            nextValue = currentValue + 1;
            break;
            
        case IncreaseByFive:
            if (currentValue < 12)
                nextValue = currentValue + 2;
            else if (currentValue == 12)
                nextValue = 15;
            else
                nextValue = currentValue + 5;
            break;
            
        case RemainConstant:
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

- (void) turnInCardSet:(CardSet *)cardSet forPlayerNumber:(Player)number
{
    RiskCard *card;
    Country *country;
    
    AssertGameState (gs_place_armies);
    
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
    AssertGameState (gs_place_armies);
    
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

- (void) automaticallyTurnInCardsForPlayerNumber:(Player)number
{
    CardSet *cardSet;
    
    while (players[number].playerCards.count > 4)
    {
        cardSet = [players[number] bestSet];
        [self turnInCardSet:cardSet forPlayerNumber:number];
    }
}

//----------------------------------------------------------------------

- (void) transferCardsFromPlayer:(RiskPlayer *)source toPlayer:(RiskPlayer *)destination
{
    NSArray *cardArray;
    NSEnumerator *cardEnumerator;
    RiskCard *card;
    
    cardArray = [NSArray arrayWithArray:source.playerCards];
    cardEnumerator = [cardArray objectEnumerator];
    
    //NSLog (@"transfering %d cards.", [cardArray count]);
    
    while (card = [cardEnumerator nextObject])
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
        cardPanelController = [[CardPanelController alloc] init];
        [cardPanelController setGameManager:self];
    }
}

//----------------------------------------------------------------------

- (void) updatePhaseBox
{
    if (players[currentPlayerNumber].interactive == YES)
    {
        infoTextField.stringValue = gameStateInfo (gameState);
        phaseTextField.stringValue = NSStringFromGameState (gameState);
    }
    else
    {
        phaseTextField.stringValue = @"Computer Move";
        infoTextField.stringValue = @"The computer player named above is moving, please wait.";
    }
}

//----------------------------------------------------------------------

- (int) totalTroopsForPlayerNumber:(Player)number
{
    NSEnumerator *countryEnumerator;
    Country *country;
    int total;
    
    total = 0;
    countryEnumerator = [[world countriesForPlayer:number] objectEnumerator];
    while (country = [countryEnumerator nextObject])
    {
        total += country.troopCount;
    }
    
    return total;
}

//----------------------------------------------------------------------

- (void) defaultsChanged:(NSNotification *)aNotification
{
    if (currentPlayerNumber > 0)
        playerColorWell.color = [[BoardSetup instance] colorForPlayer:currentPlayerNumber];
}

//======================================================================
// End of game stuff:
//======================================================================

- (BOOL) checkForEndOfPlayerNumber:(Player)number
{
    BOOL isGameOver;
    Player winner;
    
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
                NSRunAlertPanel (@"Victory", @"Winner was %@.", @"OK", nil, nil, players[winner].playerName);
                
                [self playerHasWon:winner];
                break;
            }
        }
        
        [self stopGame];
    }
    
    return isGameOver;
}

//----------------------------------------------------------------------

- (void) playerHasLost:(Player)number
{
    [players[number] youLostGame];
    [self deactivatePlayerNumber:number];
}

//----------------------------------------------------------------------

- (void) playerHasWon:(Player)number
{
    [players[number] youWonGame];
    [self deactivatePlayerNumber:number];
}

//----------------------------------------------------------------------
// 1. Release player
// 2. Free items of the player's submenu (if any), and disable the player menu.
//----------------------------------------------------------------------

- (void) deactivatePlayerNumber:(Player)number
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
