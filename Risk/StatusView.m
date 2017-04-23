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
        _textCell.backgroundColor = [NSColor lightGrayColor];
        [_textCell setBezeled:NO];
        [_textCell setBordered:NO];
        _textCell.font = [NSFont fontWithName:@"Helvetica" size:10.0];
        _textCell.alignment = NSCenterTextAlignment;
        [_textCell setEditable:NO];
        [_textCell setSelectable:NO];
        _textCell.textColor = [NSColor blackColor];
    }
}

//----------------------------------------------------------------------

- (instancetype) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        showCardSetCounts = [BoardSetup instance].showCardSetCounts;
        
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
    CGFloat boxHeight, boxWidth;
    NSRect boxRect, textRect;
    
    NSRect boundsRect = self.bounds;

    [[NSColor lightGrayColor] set];
    NSRectFill (boundsRect);
    
    int playerCount = [gameManager activePlayerCount];
    
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
    int offset = 0;
    
    for (int l = 0; l < 6; l++)
    {
        Player number = 1 + ((l + currentPlayer - 1) % 6);
        
        if ([gameManager isPlayerActive:number] == YES)
        {
            // draw his entry
            boxRect.origin.y = ((offset + 1) * INTERSPACE) + (offset * boxHeight);
            NSDrawWhiteBezel (boxRect, boundsRect);
            [[[BoardSetup instance] colorForPlayer:number] set];
            NSRectFill(NSInsetRect(boxRect, INSET, INSET));
            textRect.origin.y = ((offset + 1) * INTERSPACE) +
            (offset * boxHeight) +
            ((boxHeight - TEXTHEIGHT) / 2);
            
            if (showCardSetCounts == YES)
            {
                RiskPlayer *player = [gameManager playerNumber:number];
                NSInteger count = player.playerCards.count;
                
                if ([player canTurnInCardSet] == YES) {
#ifdef __APPLE_CPP__
                    [_textCell setTextColor:[NSColor darkGrayColor]];
#else
                _textCell.textColor = [NSColor whiteColor];
#endif
                } else {
                    _textCell.textColor = [NSColor blackColor];
                }
                
                _textCell.integerValue = count;
                [_textCell drawWithFrame:textRect inView:self];
            }

            offset++;
        }
    }
}

//----------------------------------------------------------------------

- (void) defaultsChanged:(NSNotification *)aNotification
{
    showCardSetCounts = [BoardSetup instance].showCardSetCounts;
    [self setNeedsDisplay:YES];
}

@end
