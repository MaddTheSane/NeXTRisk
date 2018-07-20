//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskPlayer.m,v 1.7 1997/12/15 21:09:43 nygard Exp $");

#import "RiskPlayer.h"

#import "RiskGameManager.h"
#import "RKCountry.h"
#import "RiskWorld.h"
#import "SNRandom.h"
#import "RKCard.h"
#import "RKCardSet.h"

#define RiskPlayer_VERSION 1

@implementation RiskPlayer
{
@private
    NSArray *nibObjs;
}
@synthesize rng;
@synthesize gameManager;
@synthesize playerToolMenu;
@synthesize attackMethod;
@synthesize attackMethodValue;
@synthesize playerName;
@synthesize playerNumber;

+ (void) load
{
    //NSLog (@"RiskPlayer.");
}

+ (void) initialize
{
    if (self == [RiskPlayer class])
    {
        [self setVersion:RiskPlayer_VERSION];
    }
}

- (instancetype) initWithPlayerName:(NSString *)aName number:(RKPlayer)number gameManager:(RiskGameManager *)aManager
{
    if (self = [super init]) {
        playerName = [aName copy];
        playerNumber = number;
        playerCards = [[NSMutableArray alloc] init];
        gameManager = aManager;
        
        attackMethod = RKAttackMethodOnce;
        attackMethodValue = 1;
        
        consoleWindow = nil;
        consoleMessageText = nil;
        continueButton = nil;
        pauseForContinueButton = nil;
        
        playerToolMenu = nil;
        
        rng = [SNRandom instance];
    }
    
    return self;
}

- (void) dealloc
{
    if (consoleWindow != nil)
    {
        // What happens to a window that is already closed when it gets this message?
        [consoleWindow setReleasedWhenClosed:YES];
        [continueButton setEnabled:NO];
        [pauseForContinueButton setEnabled:NO];
    }
}

- (NSArray *) playerCards
{
    return playerCards;
}

- (void) addCardToHand:(RKCard *)newCard
{
    [playerCards addObject:newCard];
}

- (void) removeCardFromHand:(RKCard *)aCard
{
    [playerCards removeObject:aCard];
}

- (void) turnDone
{
    [gameManager endTurn];
}

- (void) mouseDown:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry
{
}

- (void) mouseUp:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry
{
}

- (void) windowWillClose:(NSNotification *)aNotification
{
    // Stop pausing if we close the window, otherwise we're stuck!
    if (aNotification.object == consoleWindow && pauseForContinueButton.state == 1)
    {
        [NSApp stopModal];
        pauseForContinueButton.state = 0;
        [continueButton setEnabled:NO];
    }
}

#pragma mark - General methods for players

- (NSSet *) ourCountries
{
    return [gameManager.world countriesForPlayer:playerNumber];
}

- (NSSet *) countriesWithAllOptions:(RKCountryFlags)options from:(NSSet<RKCountry *> *)source
{
    NSMutableSet *resultingSet = [NSMutableSet set];
    for (RKCountry *country in source)
    {
        RKPlayer number = country.playerNumber;
        int troopCount = country.troopCount;
        int movableTroopCount = country.movableTroopCount;
        BOOL hasEnemyNeighbors = country.hasEnemyNeighbors;
        
        if (((options & RKCountryFlagsPlayerNone) && number != 0)
            || ((options & RKCountryFlagsPlayerOne) && number != 1)
            || ((options & RKCountryFlagsPlayerTwo) && number != 2)
            || ((options & RKCountryFlagsPlayerThree) && number != 3)
            || ((options & RKCountryFlagsPlayerFour) && number != 4)
            || ((options & RKCountryFlagsPlayerFive) && number != 5)
            || ((options & RKCountryFlagsPlayerSix) && number != 6)
            || ((options & RKCountryFlagsThisPlayer) && number != playerNumber)
            || ((options & RKCountryFlagsWithTroops) && troopCount < 1)
            || ((options & RKCountryFlagsWithoutTroops) && troopCount > 0)
            || ((options & RKCountryFlagsWithMovableTroops) && movableTroopCount < 1)
            || ((options & RKCountryFlagsWithoutMovableTroops) && movableTroopCount > 0)
            || ((options & RKCountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == NO)
            || ((options & RKCountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == YES))
        {
            continue;
        }
        
        [resultingSet addObject:country];
    }
    
    return [resultingSet copy];
}

- (NSSet<RKCountry*> *) countriesWithAnyOptions:(RKCountryFlags)options from:(NSSet<RKCountry *> *)source
{
    NSMutableSet *resultingSet = [[NSMutableSet alloc] init];
    
    for (RKCountry *country in source)
    {
        RKPlayer number = country.playerNumber;
        RKArmyCount troopCount = country.troopCount;
        RKArmyCount movableTroopCount = country.movableTroopCount;
        BOOL hasEnemyNeighbors = country.hasEnemyNeighbors;
        
        if (((options & RKCountryFlagsPlayerNone) && number == 0)
            || ((options & RKCountryFlagsPlayerOne) && number == 1)
            || ((options & RKCountryFlagsPlayerTwo) && number == 2)
            || ((options & RKCountryFlagsPlayerThree) && number == 3)
            || ((options & RKCountryFlagsPlayerFour) && number == 4)
            || ((options & RKCountryFlagsPlayerFive) && number == 5)
            || ((options & RKCountryFlagsPlayerSix) && number == 6)
            || ((options & RKCountryFlagsThisPlayer) && number == playerNumber)
            || ((options & RKCountryFlagsWithTroops) && troopCount > 0)
            || ((options & RKCountryFlagsWithoutTroops) && troopCount < 1)
            || ((options & RKCountryFlagsWithMovableTroops) && movableTroopCount > 0)
            || ((options & RKCountryFlagsWithoutMovableTroops) && movableTroopCount < 1)
            || ((options & RKCountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == YES)
            || ((options & RKCountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == NO))
        {
            [resultingSet addObject:country];
        }
    }
    
    return [resultingSet copy];
}

- (BOOL) hasCountriesWithAllOptions:(RKCountryFlags)options from:(NSSet<RKCountry *> *)source
{
    BOOL flag = NO;
    
    for (RKCountry *country in source)
    {
        RKPlayer number = country.playerNumber;
        RKArmyCount troopCount = country.troopCount;
        RKArmyCount movableTroopCount = country.movableTroopCount;
        BOOL hasEnemyNeighbors = country.hasEnemyNeighbors;
        
        if (((options & RKCountryFlagsPlayerNone) && number != 0)
            || ((options & RKCountryFlagsPlayerOne) && number != 1)
            || ((options & RKCountryFlagsPlayerTwo) && number != 2)
            || ((options & RKCountryFlagsPlayerThree) && number != 3)
            || ((options & RKCountryFlagsPlayerFour) && number != 4)
            || ((options & RKCountryFlagsPlayerFive) && number != 5)
            || ((options & RKCountryFlagsPlayerSix) && number != 6)
            || ((options & RKCountryFlagsThisPlayer) && number != playerNumber)
            || ((options & RKCountryFlagsWithTroops) && troopCount < 1)
            || ((options & RKCountryFlagsWithoutTroops) && troopCount > 0)
            || ((options & RKCountryFlagsWithMovableTroops) && movableTroopCount < 1)
            || ((options & RKCountryFlagsWithoutMovableTroops) && movableTroopCount > 0)
            || ((options & RKCountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == NO)
            || ((options & RKCountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == YES))
        {
            continue;
        }
        
        flag = YES;
        break;
    }
    
    return flag;
}

- (BOOL) hasCountriesWithAnyOptions:(RKCountryFlags)options from:(NSSet<RKCountry*> *)source
{
    BOOL flag = NO;
    for (RKCountry *country in source)
    {
        RKPlayer number = country.playerNumber;
        RKArmyCount troopCount = country.troopCount;
        RKArmyCount movableTroopCount = country.movableTroopCount;
        BOOL hasEnemyNeighbors = country.hasEnemyNeighbors;
        
        if (((options & RKCountryFlagsPlayerNone) && number == 0)
            || ((options & RKCountryFlagsPlayerOne) && number == 1)
            || ((options & RKCountryFlagsPlayerTwo) && number == 2)
            || ((options & RKCountryFlagsPlayerThree) && number == 3)
            || ((options & RKCountryFlagsPlayerFour) && number == 4)
            || ((options & RKCountryFlagsPlayerFive) && number == 5)
            || ((options & RKCountryFlagsPlayerSix) && number == 6)
            || ((options & RKCountryFlagsThisPlayer) && number == playerNumber)
            || ((options & RKCountryFlagsWithTroops) && troopCount > 0)
            || ((options & RKCountryFlagsWithoutTroops) && troopCount < 1)
            || ((options & RKCountryFlagsWithMovableTroops) && movableTroopCount > 0)
            || ((options & RKCountryFlagsWithoutMovableTroops) && movableTroopCount < 1)
            || ((options & RKCountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == YES)
            || ((options & RKCountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == NO))
        {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

- (NSSet *) chooseCountriesInContinentNamed:(NSString *)continentName from:(NSSet<RKCountry*> *)source
{
    NSMutableSet *resultingSet = [[NSMutableSet alloc] init];
    
    for (RKCountry *country in source)
    {
        if ([country.continentName isEqualToString:continentName] == YES)
            [resultingSet addObject:country];
    }
    
    return [resultingSet copy];
}

- (NSSet *) removeCountriesInContinentNamed:(NSString *)continentName from:(NSSet<RKCountry*> *)source
{
    NSMutableSet *resultingSet = [[NSMutableSet alloc] init];

    for (RKCountry *country in source)
    {
        if ([country.continentName isEqualToString:continentName] == NO)
            [resultingSet addObject:country];
    }
    
    return [resultingSet copy];
}

#pragma mark - Card set methods

- (NSSet<RKCardSet*> *) allOurCardSets
{
    NSMutableSet *allCardSets = [NSMutableSet set];
    
    for (RKCard *card1 in playerCards)
    {
        for (RKCard *card2 in playerCards)
        {
            for (RKCard *card3 in playerCards)
            {
                RKCardSet *cardSet = [[RKCardSet alloc] initCardSet:card1:card2:card3];
                if (cardSet != nil)
                    [allCardSets addObject:cardSet];
            }
        }
    }
    
    return [allCardSets copy];
}

- (RKCardSet *) bestSet
{
    RKCardSet *bestSet = nil;
    NSSet *allSets = [self allOurCardSets];
    
    for (RKCardSet *cardSet in allSets)
    {
        if (compareCardSetValues (cardSet, bestSet, (void *)playerNumber) == NSOrderedAscending)
            bestSet = cardSet;
    }
    
    return bestSet;
}

- (BOOL) canTurnInCardSet
{
    NSInteger count = playerCards.count;
    RKCard *card1, *card2, *card3;
    BOOL hasValidSet = NO;
    
    for (NSInteger i = 0; hasValidSet == NO && i < count; i++)
    {
        card1 = playerCards[i];
        for (NSInteger j = i + 1; hasValidSet == NO && j < count; j++)
        {
            card2 = playerCards[j];
            for (NSInteger k = j + 1; k < count; k++)
            {
                card3 = playerCards[k];
                
                if ([RKCardSet isValidCardSet:card1:card2:card3] == YES)
                {
                    hasValidSet = YES;
                    break;
                }
            }
        }
    }
    
    return hasValidSet;
}

#pragma mark - Console

- (IBAction) showConsolePanel:(id)sender
{
    if (consoleWindow == nil)
    {
        NSArray *tmpArr = nil;
        NSString *nibFile = @"PlayerConsole";
        BOOL loaded = [[NSBundle bundleForClass:[RiskPlayer class]] loadNibNamed:nibFile owner:self topLevelObjects:&tmpArr];
        nibObjs = tmpArr;
        
        NSAssert1 (loaded == YES, @"Could not load %@.", nibFile);
        
        consoleWindow.title = [NSString stringWithFormat:@"Player %ld Console", (long)playerNumber];
    }
    
    [consoleWindow orderFront:self];
}

- (void) logMessage:(NSString *)format, ...
{
    va_list ap;
    va_start(ap, format);
    [self logMessage:format format:ap];
    va_end(ap);
}

- (void) logMessage:(NSString *)format format:(va_list)ap
{
    NSRange selected;
    NSMutableString *str;
    
    if (consoleMessageText != nil)
    {
        str = [[NSMutableString alloc] initWithFormat:format arguments:ap];
        [str appendString:@"\n"];
        
        [consoleMessageText selectAll:nil];
        selected = [consoleMessageText selectedRange];
        selected.location = selected.length;
        selected.length = 0;
        [consoleMessageText setSelectedRange:selected];
        [consoleMessageText replaceCharactersInRange:selected withString:str];
        [consoleMessageText scrollRangeToVisible:selected];
        
        if (pauseForContinueButton.state == NSOnState)
            [self waitForContinue];
    }
}

- (void) waitForContinue
{
    [consoleWindow orderFront:self];
    [NSApp runModalForWindow:consoleWindow];
}

- (IBAction) continueAction:(id)sender
{
    [NSApp stopModal];
}

- (IBAction) pauseCheckAction:(id)sender
{
    [NSApp stopModal];
    
    if ([sender state] == 1)
    {
        [continueButton setEnabled:YES];
    }
    else
    {
        [continueButton setEnabled:NO];
    }
}

#pragma mark - Subclass Responsibilities

- (BOOL) isInteractive
{
    return NO;
}

#pragma mark Card management

- (void) mayTurnInCards
{
}

- (void) mustTurnInCards
{
}

- (void) didTurnInCards:(int)extraArmyCount
{
}

#pragma mark Initial game phases

- (void) willBeginChoosingCountries
{
}

- (void) chooseCountry
{
    NSArray *unoccupiedCountries;
    RKCountry *country;
    
    unoccupiedCountries = [gameManager unoccupiedCountries];
    country = unoccupiedCountries[[self.rng randomNumberModulo:unoccupiedCountries.count]];
    
    [gameManager player:self choseCountry:country];
    // Possible to choose more than one country...
    
    [self turnDone];
}

- (void) willEndChoosingCountries
{
}

- (void) willBeginPlacingInitialArmies
{
}

- (void) placeInitialArmies:(int)count
{
    [self turnDone];
}

- (void) willEndPlacingInitialArmies
{
}

- (void) youLostGame
{
    //NSLog (@"(%d) %@ has lost the game.", playerNumber, playerName);
}

- (void) youWonGame
{
    //NSLog (@"(%d) %@ has won the game.", playerNumber, playerName);
}

#pragma mark Regular turn phases

- (void) willBeginTurn
{
}

- (void) placeArmies:(int)count
{
    [self turnDone];
}

- (void) attackPhase
{
    [self turnDone];
}

- (void) moveAttackingArmies:(int)count between:(RKCountry *)source :(RKCountry *)destination
{
    [self turnDone];
}

- (void) fortifyPhase:(RKFortifyRule)fortifyRule
{
    [self turnDone];
}

- (void) placeFortifyingArmies:(int)count fromCountry:(RKCountry *)source
{
    [self turnDone];
}

- (void) willEndTurn
{
}

#pragma mark - Inform computer players of important events that happed during other players turns.

- (void) playerNumber:(RKPlayer)number attackedCountry:(RKCountry *)attackedCountry
{
}

- (void) playerNumber:(RKPlayer)number capturedCountry:(RKCountry *)capturedCountry
{
}

@end
