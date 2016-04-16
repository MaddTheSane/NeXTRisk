//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: StatusView.m,v 1.4 1997/12/15 07:44:22 nygard Exp $");

#import "StatusView.h"

#import "BoardSetup.h"
#import "RiskGameManager.h"
#import "SNUtility.h"
#import "RiskPlayer.h"

//======================================================================
// The StatusView shows the color of each player (in the order of play)
// and, optionally, the number of cards in their hand.  This number is
// highlighted if the player has a valid card set.
//======================================================================

#define StatusView_VERSION 1

static NSTextFieldCell *_textCell = nil;

@implementation StatusView

+ (void) initialize
{
    if (self == [StatusView class])
    {
        [self setVersion:StatusView_VERSION];

        _textCell = [[NSTextFieldCell alloc] init];
        [_textCell setBackgroundColor:[NSColor lightGrayColor]];
        [_textCell setBezeled:NO];
        [_textCell setBordered:NO];
        [_textCell setFont:[NSFont fontWithName:@"Helvetica" size:10.0]];
        [_textCell setAlignment:NSCenterTextAlignment];
        [_textCell setEditable:NO];
        [_textCell setSelectable:NO];
        [_textCell setTextColor:[NSColor blackColor]];
    }
}

//----------------------------------------------------------------------

- initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        showCardSetCounts = [[BoardSetup instance] showCardSetCounts];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (defaultsChanged:)
                                                     name:RiskBoardSetupShowCardSetCountsChangedNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (defaultsChanged:)
                                                     name:RiskBoardSetupPlayerColorsChangedNotification
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

- (BOOL) isFlipped
{
    return YES;
}

//----------------------------------------------------------------------

#define INTERSPACE (5.0)
#define TEXTWIDTH (10.0)
#define TEXTHEIGHT (15.0)
#define INSET (5.0)

- (void) drawRect:(NSRect)rect
{
    Player currentPlayer;
    int playerCount;
    float boxHeight, boxWidth;
    NSRect boxRect, textRect;
    int l, offset;
    NSRect boundsRect;
    Player number;
	

    boundsRect = [self bounds];

    [[NSColor controlColor] set];
    NSRectFill (boundsRect);

    playerCount = [gameManager activePlayerCount];

    if (playerCount == 0 || [gameManager gameInProgress] == NO)
    {
        return;
    }

    currentPlayer = [gameManager currentPlayerNumber];

    boxHeight = (boundsRect.size.height - ((playerCount + 1) * INTERSPACE)) / playerCount;
    boxWidth = (boundsRect.size.width - (3 * INTERSPACE)) - TEXTWIDTH;
	
    boxRect.origin.x = INTERSPACE;
    boxRect.size.width = boxWidth;
    boxRect.size.height = boxHeight;
    textRect.origin.x = (INTERSPACE * 2) + boxWidth;
    textRect.size.width = TEXTWIDTH;
    textRect.size.height = TEXTHEIGHT;
    offset = 0;

    for (l = 0; l < 6; l++)
    {
        number = 1 + ((l + currentPlayer - 1) % 6);
        
        if ([gameManager isPlayerActive:number] == YES)
        {
            // draw his entry
            boxRect.origin.y = ((offset + 1) * INTERSPACE) + (offset * boxHeight);
            NSDrawWhiteBezel (boxRect, boundsRect);
            [[[BoardSetup instance] colorForPlayer:number] set];

			NSRectFill(NSInsetRect(boxRect, -INSET, -INSET));
            textRect.origin.y = ((offset + 1) * INTERSPACE) + 
                (offset * boxHeight) +
                ((boxHeight - TEXTHEIGHT) / 2);

            if (showCardSetCounts == YES)
            {
                RiskPlayer *player;
                NSInteger count;

                player = [gameManager playerNumber:number];
                count = [[player playerCards] count];

                if ([player canTurnInCardSet] == YES)
#ifdef __APPLE_CPP__
                    [_textCell setTextColor:[NSColor darkGrayColor]];
#else
                    [_textCell setTextColor:[NSColor whiteColor]];
#endif
                else
                    [_textCell setTextColor:[NSColor blackColor]];

                [_textCell setIntegerValue:count];
                [_textCell drawWithFrame:textRect inView:self];
            }

            offset++;
        }
    }
}

//----------------------------------------------------------------------

- (void) defaultsChanged:(NSNotification *)aNotification
{
    showCardSetCounts = [[BoardSetup instance] showCardSetCounts];
    [self setNeedsDisplay:YES];
}

@end
