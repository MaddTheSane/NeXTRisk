//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: CardPanelController.m,v 1.3 1997/12/15 07:43:41 nygard Exp $");

#import "CardPanelController.h"

#import "RiskCard.h"
#import "RiskPlayer.h"
#import "Country.h"
#import "RiskGameManager.h"
#import "CardSet.h"

//======================================================================
// The CardPanelController provides interactive Risk players with an
// interface for reviewing their hand and choosing card sets to turn
// in.  It will force the player to turn in cards when they are able to
// and have more than four cards in their hand.
//
// The cards are not turned in until all sets have been chosen.  The
// RiskPlayer is notified about the number of extra armies for each
// set turned in.
//======================================================================

#define CardPanelController_VERSION 1

static NSImage *_cardBackImage = nil;
static NSImage *_littleStarImage = nil;

struct image_names
{
    CFStringRef i_name;
    NSImage *__strong*i_image;
};

static struct image_names class_images[] =
{
    { CFSTR("CardBack"),    &_cardBackImage },
    { CFSTR("LittleStar"),  &_littleStarImage },
};

@implementation CardPanelController
@synthesize gameManager;

+ (void) initialize
{
    if (self == [CardPanelController class])
    {
        [self setVersion:CardPanelController_VERSION];

        if ([NSBundle bundleForClass:self] == nil)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector (loadClassImages)
                                                  name:NSApplicationDidFinishLaunchingNotification
                                                  object:NSApp];
        }
        else
        {
            [self loadClassImages];
        }
    }
}

//----------------------------------------------------------------------

+ (void) loadClassImages
{
    int l;
    NSBundle *thisBundle;

    if (self == [CardPanelController class])
    {
        thisBundle = [NSBundle bundleForClass:self];
        NSAssert (thisBundle != nil, @"Could not get bundle.");

        // load class images
        for (l = 0; l < sizeof (class_images) / sizeof (struct image_names); l++)
        {
            //imagePath = [thisBundle pathForImageResource:class_images[l].i_name];
            //NSAssert1 (imagePath != nil, @"Could not find image: '%@'", class_images[l].i_name);

            *(class_images[l].i_image) = [NSImage imageNamed:(__bridge NSString * _Nonnull)(class_images[l].i_name)];
            NSAssert1 (*(class_images[l].i_image) != nil, @"Couldn't load image: '%@'\n", class_images[l].i_name);
        }
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//----------------------------------------------------------------------

- (instancetype)init
{
    BOOL loaded;
    NSString *nibFile;

    if (self = [super init]) {
        nibFile = @"CardPanel.nib";
        loaded = [NSBundle loadNibNamed:nibFile owner:self];
        if (loaded == NO)
        {
            NSLog (@"Could not load %@.", nibFile);
            return nil;
        }

        currentPlayerNumber = 0;

        gameManager = nil;
        playerCards = nil;
        cardSets = [[NSMutableArray alloc] init];
    }

    return self;
}

//----------------------------------------------------------------------

// Note: We can't use a matrix of NSImageCells, because it seems that
// they don't allow a selected cell, and so we can't tell which cell
// was clicked.

- (IBAction) handAction:(id)sender
{
    NSCell *cell;
    NSInteger index;

    index = handMatrix.selectedColumn;
	
    if (index != -1 && canTurnInCards == YES && setMatrixCount < 3 )
    {
        cell = [handMatrix cellAtRow:0 column:index];
        
        // if there is room in the box and they didn't click on an empty cell
        if (cell.image == _cardBackImage)
        {
            return;
        }

        if (setMatrixCount == 2)
        {
            RiskCard *lastCard;

            lastCard = playerCards[index];

            // check to see if this one will make a third
            if ([CardSet isValidCardSet:currentSet[0]:currentSet[1]:lastCard] == NO)
            {
                NSBeep();
                return;
            }
        }

        // turn the card over
        cell.image = _cardBackImage;

        // record which card it is
        currentSet[setMatrixCount] = playerCards[index];
        currentIndices[setMatrixCount] = (int)index;

        // put it down below
        [[setMatrix cellAtRow:0 column:setMatrixCount] setImage:currentSet[setMatrixCount].image];
        [[setStarMatrix cellAtRow:0 column:setMatrixCount] setImage:[[handStarMatrix cellAtRow:0 column:index] image]];
		
        setMatrixCount++;

        [handMatrix setNeedsDisplay:YES];
        [setMatrix setNeedsDisplay:YES];
        [handStarMatrix setNeedsDisplay:YES];
        [setStarMatrix setNeedsDisplay:YES];

        if (setMatrixCount == 3)
        {
            [turnInButton setEnabled:YES];
        }
    }
}

//----------------------------------------------------------------------

- (IBAction) setAction:(id)sender
{
    NSInteger index;
    NSInteger l;
	
    index = setMatrix.selectedColumn;

    // put it back up above
    if (index >= 0 && index < setMatrixCount)
    {
        [[handMatrix cellAtRow:0 column:currentIndices[index]] setImage:currentSet[index].image];

        // move the others back a step
        for (l = index; l < setMatrixCount - 1; l++)
        {
            [[setMatrix cellAtRow:0 column:l] setImage:[[setMatrix cellAtRow:0 column:l + 1] image]];
            [[setStarMatrix cellAtRow:0 column:l] setImage:[[setStarMatrix cellAtRow:0 column:l + 1] image]];
            currentSet[l] = currentSet[l + 1];
            currentIndices[l] = currentIndices[l + 1];
        }

        [[setMatrix cellAtRow:0 column:setMatrixCount - 1] setImage:nil];
        [[setStarMatrix cellAtRow:0 column:setMatrixCount - 1] setImage:nil];
        currentSet[setMatrixCount - 1] = nil;
        currentIndices[setMatrixCount - 1] = -1;
        setMatrixCount--;

        [handMatrix setNeedsDisplay:YES];
        [setMatrix setNeedsDisplay:YES];
        [handStarMatrix setNeedsDisplay:YES];
        [setStarMatrix setNeedsDisplay:YES];
    }

    if (setMatrixCount < 3)
    {
        [turnInButton setEnabled:NO];
    }
}

//----------------------------------------------------------------------

- (IBAction) doneAction:(id)sender
{
    NSEnumerator *cardSetEnumerator;
    CardSet *cardSet;

    // Go through list of sets, and instruct the game manager to turn
    // in those card sets on behalf of the player.

    cardSetEnumerator = [cardSets objectEnumerator];
    while (cardSet = [cardSetEnumerator nextObject])
    {
        [gameManager turnInCardSet:cardSet forPlayerNumber:currentPlayerNumber];
    }

    [cardSets removeAllObjects];

    [NSApp stopModal];
}

//----------------------------------------------------------------------

// Cancel sets -- remove cards sets, show all cards again, and enable
// the done button.

- (IBAction) stopAction:(id)sender
{
    [cardSets removeAllObjects];
    [self enableButtons];
    [self resetPanel];
}

//----------------------------------------------------------------------

- (IBAction) turnInSetAction:(id)sender
{
    CardSet *cardSet;
    int l;
	
    if (setMatrixCount == 3)
    {
        cardSet = [CardSet cardSet:currentSet[0]:currentSet[1]:currentSet[2]];
        NSAssert (cardSet != nil, @"Invalid card set.");
        
        for (l = 0; l < 3; l++)
        {
            currentSet[l] = nil;
            currentIndices[l] = -1;
            [[setMatrix cellAtRow:0 column:l] setImage:nil];
            [[setStarMatrix cellAtRow:0 column:l] setImage:nil];
        }

        setMatrixCount = 0;
        [setMatrix setNeedsDisplay:YES];
        [setStarMatrix setNeedsDisplay:YES];

        amassedTextField.intValue = amassedTextField.intValue + currentCardSetValue;
        currentCardSetValue = [gameManager _valueOfNextCardSet:currentCardSetValue];

        [cardSets addObject:cardSet];
        [self enableButtons];
    }

    worthTextField.intValue = currentCardSetValue;
}

//----------------------------------------------------------------------

- (void) enableButtons
{
    if (canTurnInCards == YES && playerCards.count - (cardSets.count * 3) > 4)
        [doneButton setEnabled:NO];
    else
        [doneButton setEnabled:YES];

    if (cardSets.count > 0)
        [cancelButton setEnabled:YES];
    else
        [cancelButton setEnabled:NO];
}

//----------------------------------------------------------------------

- (void) resetPanel
{
    NSInteger l, cardCount;
    NSRect aFrame, boundsRect;
    RiskCard *card;
    NSView *superView;

    cardCount = playerCards.count;

    [handMatrix renewRows:1 columns:cardCount];
    [handStarMatrix renewRows:1 columns:cardCount];

    [handMatrix sizeToCells];
    [handStarMatrix sizeToCells];

    aFrame = NSUnionRect (handMatrix.frame, handStarMatrix.frame);

    superView = handMatrix.superview;
    boundsRect = superView.bounds;

    boundsRect.size.width = aFrame.origin.x + aFrame.size.width;
    [superView setFrameSize:boundsRect.size]; // -setBounds: is ineffective..
    [superView setNeedsDisplay:YES];

    for (l = 0; l < cardCount; l++)
    {
        card = playerCards[l];
        [[handMatrix cellAtRow:0 column:l] setImage:card.image];
        if (card.country.playerNumber == currentPlayerNumber)
            [[handStarMatrix cellAtRow:0 column:l] setImage:_littleStarImage];
        else
            [[handStarMatrix cellAtRow:0 column:l] setImage:nil];
    }

    for (l = 0; l < 3; l++)
    {
        [[setMatrix cellAtRow:0 column:l] setImage:nil];
        [[setStarMatrix cellAtRow:0 column:l] setImage:nil];
    }

    [setMatrix setNeedsDisplay:YES];
    [setStarMatrix setNeedsDisplay:YES];

    [turnInButton setEnabled:NO];

    if (cardCount > 4 && canTurnInCards == YES)
    {
        forceTextField.stringValue = @"You must turn in cards.";
    }
    else
    {
        forceTextField.stringValue = @"";
    }

    [self enableButtons];
    amassedTextField.intValue = 0;

    setMatrixCount = 0;

    currentCardSetValue = [gameManager armiesForNextCardSet];
    worthTextField.intValue = currentCardSetValue;

    [cardSets removeAllObjects];
}

//----------------------------------------------------------------------

- (void) setupPanelForPlayer:(RiskPlayer *)player
{
    currentPlayerNumber = player.playerNumber;
    playerCards = player.playerCards;
    [self resetPanel];
}

//----------------------------------------------------------------------

- (void) runCardPanel:(BOOL)canTurnInCardsFlag forPlayer:(RiskPlayer *)player
{
    canTurnInCards = canTurnInCardsFlag;
    [self setupPanelForPlayer:player];

    [cardPanel makeKeyAndOrderFront:self];
    [NSApp runModalForWindow:cardPanel];
    [cardPanel orderOut:self];
}

@end
