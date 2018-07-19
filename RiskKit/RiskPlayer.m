//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskPlayer.m,v 1.7 1997/12/15 21:09:43 nygard Exp $");

#import "RiskPlayer.h"

#import "RiskGameManager.h"
#import "Country.h"
#import "RiskWorld.h"
#import "SNRandom.h"
#import "RiskCard.h"
#import "CardSet.h"

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

- (instancetype) initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager
{
    if (self = [super init]) {
        playerName = [aName copy];
        playerNumber = number;
        playerCards = [[NSMutableArray alloc] init];
        gameManager = aManager;
        
        attackMethod = AttackMethodOnce;
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

- (void) addCardToHand:(RiskCard *)newCard
{
    [playerCards addObject:newCard];
}

- (void) removeCardFromHand:(RiskCard *)aCard
{
    [playerCards removeObject:aCard];
}

- (void) turnDone
{
    [gameManager endTurn];
}

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry
{
}

- (void) mouseUp:(NSEvent *)theEvent inCountry:(Country *)aCountry
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

- (NSSet *) countriesWithAllOptions:(CountryFlags)options from:(NSSet<Country *> *)source
{
    NSMutableSet *resultingSet = [NSMutableSet set];
    for (Country *country in source)
    {
        Player number = country.playerNumber;
        int troopCount = country.troopCount;
        int movableTroopCount = country.movableTroopCount;
        BOOL hasEnemyNeighbors = country.hasEnemyNeighbors;
        
        if (((options & CountryFlagsPlayerNone) && number != 0)
            || ((options & CountryFlagsPlayerOne) && number != 1)
            || ((options & CountryFlagsPlayerTwo) && number != 2)
            || ((options & CountryFlagsPlayerThree) && number != 3)
            || ((options & CountryFlagsPlayerFour) && number != 4)
            || ((options & CountryFlagsPlayerFive) && number != 5)
            || ((options & CountryFlagsPlayerSix) && number != 6)
            || ((options & CountryFlagsThisPlayer) && number != playerNumber)
            || ((options & CountryFlagsWithTroops) && troopCount < 1)
            || ((options & CountryFlagsWithoutTroops) && troopCount > 0)
            || ((options & CountryFlagsWithMovableTroops) && movableTroopCount < 1)
            || ((options & CountryFlagsWithoutMovableTroops) && movableTroopCount > 0)
            || ((options & CountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == NO)
            || ((options & CountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == YES))
        {
            continue;
        }
        
        [resultingSet addObject:country];
    }
    
    return [resultingSet copy];
}

- (NSSet<Country*> *) countriesWithAnyOptions:(CountryFlags)options from:(NSSet<Country *> *)source
{
    NSMutableSet *resultingSet = [[NSMutableSet alloc] init];
    
    for (Country *country in source)
    {
        Player number = country.playerNumber;
        RiskArmyCount troopCount = country.troopCount;
        RiskArmyCount movableTroopCount = country.movableTroopCount;
        BOOL hasEnemyNeighbors = country.hasEnemyNeighbors;
        
        if (((options & CountryFlagsPlayerNone) && number == 0)
            || ((options & CountryFlagsPlayerOne) && number == 1)
            || ((options & CountryFlagsPlayerTwo) && number == 2)
            || ((options & CountryFlagsPlayerThree) && number == 3)
            || ((options & CountryFlagsPlayerFour) && number == 4)
            || ((options & CountryFlagsPlayerFive) && number == 5)
            || ((options & CountryFlagsPlayerSix) && number == 6)
            || ((options & CountryFlagsThisPlayer) && number == playerNumber)
            || ((options & CountryFlagsWithTroops) && troopCount > 0)
            || ((options & CountryFlagsWithoutTroops) && troopCount < 1)
            || ((options & CountryFlagsWithMovableTroops) && movableTroopCount > 0)
            || ((options & CountryFlagsWithoutMovableTroops) && movableTroopCount < 1)
            || ((options & CountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == YES)
            || ((options & CountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == NO))
        {
            [resultingSet addObject:country];
        }
    }
    
    return [resultingSet copy];
}

- (BOOL) hasCountriesWithAllOptions:(CountryFlags)options from:(NSSet<Country *> *)source
{
    BOOL flag = NO;
    
    for (Country *country in source)
    {
        Player number = country.playerNumber;
        RiskArmyCount troopCount = country.troopCount;
        RiskArmyCount movableTroopCount = country.movableTroopCount;
        BOOL hasEnemyNeighbors = country.hasEnemyNeighbors;
        
        if (((options & CountryFlagsPlayerNone) && number != 0)
            || ((options & CountryFlagsPlayerOne) && number != 1)
            || ((options & CountryFlagsPlayerTwo) && number != 2)
            || ((options & CountryFlagsPlayerThree) && number != 3)
            || ((options & CountryFlagsPlayerFour) && number != 4)
            || ((options & CountryFlagsPlayerFive) && number != 5)
            || ((options & CountryFlagsPlayerSix) && number != 6)
            || ((options & CountryFlagsThisPlayer) && number != playerNumber)
            || ((options & CountryFlagsWithTroops) && troopCount < 1)
            || ((options & CountryFlagsWithoutTroops) && troopCount > 0)
            || ((options & CountryFlagsWithMovableTroops) && movableTroopCount < 1)
            || ((options & CountryFlagsWithoutMovableTroops) && movableTroopCount > 0)
            || ((options & CountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == NO)
            || ((options & CountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == YES))
        {
            continue;
        }
        
        flag = YES;
        break;
    }
    
    return flag;
}

- (BOOL) hasCountriesWithAnyOptions:(CountryFlags)options from:(NSSet<Country*> *)source
{
    BOOL flag = NO;
    for (Country *country in source)
    {
        Player number = country.playerNumber;
        RiskArmyCount troopCount = country.troopCount;
        RiskArmyCount movableTroopCount = country.movableTroopCount;
        BOOL hasEnemyNeighbors = country.hasEnemyNeighbors;
        
        if (((options & CountryFlagsPlayerNone) && number == 0)
            || ((options & CountryFlagsPlayerOne) && number == 1)
            || ((options & CountryFlagsPlayerTwo) && number == 2)
            || ((options & CountryFlagsPlayerThree) && number == 3)
            || ((options & CountryFlagsPlayerFour) && number == 4)
            || ((options & CountryFlagsPlayerFive) && number == 5)
            || ((options & CountryFlagsPlayerSix) && number == 6)
            || ((options & CountryFlagsThisPlayer) && number == playerNumber)
            || ((options & CountryFlagsWithTroops) && troopCount > 0)
            || ((options & CountryFlagsWithoutTroops) && troopCount < 1)
            || ((options & CountryFlagsWithMovableTroops) && movableTroopCount > 0)
            || ((options & CountryFlagsWithoutMovableTroops) && movableTroopCount < 1)
            || ((options & CountryFlagsWithEnemyNeighbors) && hasEnemyNeighbors == YES)
            || ((options & CountryFlagsWithoutEnemyNeighbors) && hasEnemyNeighbors == NO))
        {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

- (NSSet *) chooseCountriesInContinentNamed:(NSString *)continentName from:(NSSet<Country*> *)source
{
    NSMutableSet *resultingSet = [[NSMutableSet alloc] init];
    
    for (Country *country in source)
    {
        if ([country.continentName isEqualToString:continentName] == YES)
            [resultingSet addObject:country];
    }
    
    return [resultingSet copy];
}

- (NSSet *) removeCountriesInContinentNamed:(NSString *)continentName from:(NSSet<Country*> *)source
{
    NSMutableSet *resultingSet = [[NSMutableSet alloc] init];

    for (Country *country in source)
    {
        if ([country.continentName isEqualToString:continentName] == NO)
            [resultingSet addObject:country];
    }
    
    return [resultingSet copy];
}

#pragma mark - Card set methods

- (NSSet<CardSet*> *) allOurCardSets
{
    NSMutableSet *allCardSets = [NSMutableSet set];
    
    for (RiskCard *card1 in playerCards)
    {
        for (RiskCard *card2 in playerCards)
        {
            for (RiskCard *card3 in playerCards)
            {
                CardSet *cardSet = [[CardSet alloc] initCardSet:card1:card2:card3];
                if (cardSet != nil)
                    [allCardSets addObject:cardSet];
            }
        }
    }
    
    return [allCardSets copy];
}

- (CardSet *) bestSet
{
    CardSet *bestSet = nil;
    NSSet *allSets = [self allOurCardSets];
    
    for (CardSet *cardSet in allSets)
    {
        if (compareCardSetValues (cardSet, bestSet, (void *)playerNumber) == NSOrderedAscending)
            bestSet = cardSet;
    }
    
    return bestSet;
}

- (BOOL) canTurnInCardSet
{
    NSInteger count = playerCards.count;
    RiskCard *card1, *card2, *card3;
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
                
                if ([CardSet isValidCardSet:card1:card2:card3] == YES)
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
    Country *country;
    
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

- (void) moveAttackingArmies:(int)count between:(Country *)source :(Country *)destination
{
    [self turnDone];
}

- (void) fortifyPhase:(FortifyRule)fortifyRule
{
    [self turnDone];
}

- (void) placeFortifyingArmies:(int)count fromCountry:(Country *)source
{
    [self turnDone];
}

- (void) willEndTurn
{
}

#pragma mark - Inform computer players of important events that happed during other players turns.

- (void) playerNumber:(Player)number attackedCountry:(Country *)attackedCountry
{
}

- (void) playerNumber:(Player)number capturedCountry:(Country *)capturedCountry
{
}

@end