//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: DiceInspector.m,v 1.2 1997/12/15 07:43:50 nygard Exp $");

#import "DiceInspector.h"
#import "Country.h"

//======================================================================
// The DiceInspector shows the dice as they are rolled, and optionally
// pauses between rolls so that you can see what is going happening.
//======================================================================

#define DiceInspector_VERSION 1

static NSImage *_die1Image;
static NSImage *_die2Image;
static NSImage *_die3Image;
static NSImage *_die4Image;
static NSImage *_die5Image;
static NSImage *_die6Image;

struct image_names
{
    NSString *i_name;
    NSImage **i_image;
};

static struct image_names class_images[] =
{
    { @"Die1.tiff",    &_die1Image },
    { @"Die2.tiff",    &_die2Image },
    { @"Die3.tiff",    &_die3Image },
    { @"Die4.tiff",    &_die4Image },
    { @"Die5.tiff",    &_die5Image },
    { @"Die6.tiff",    &_die6Image },
};

@implementation DiceInspector

+ (void) initialize
{
    if (self == [DiceInspector class])
    {
        [self setVersion:DiceInspector_VERSION];

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
    NSString *imagePath;

    if (self == [DiceInspector class])
    {
        thisBundle = [NSBundle bundleForClass:self];
        NSAssert (thisBundle != nil, @"Could not get bundle.");

        // load class images
        for (l = 0; l < sizeof (class_images) / sizeof (struct image_names); l++)
        {
            imagePath = [thisBundle pathForImageResource:class_images[l].i_name];
            NSAssert1 (imagePath != nil, @"Could not find image: '%@'", class_images[l].i_name);

            *(class_images[l].i_image) = [[NSImage alloc] initByReferencingFile:imagePath];
            NSAssert1 (*(class_images[l].i_image) != nil, @"Couldn't load image: '%@'\n", class_images[l].i_name);
        }
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//----------------------------------------------------------------------

- (id)init
{
    BOOL loaded;
    NSString *nibFile;

    if (self = [super init]) {
        nibFile = @"DiceInspector.nib";
        loaded = [NSBundle loadNibNamed:nibFile owner:self];
        if (loaded == NO)
        {
            NSLog (@"Could not load %@.", nibFile);
            [super dealloc];
            return nil;
        }

        [attackerDie1 setImage:nil];
        [attackerDie2 setImage:nil];
        [attackerDie3 setImage:nil];

        [defenderDie1 setImage:nil];
        [defenderDie2 setImage:nil];

        [dicePanel setBecomesKeyOnlyIfNeeded:YES];
        [dicePanel orderFront:self];
    }

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [super dealloc];
}

//----------------------------------------------------------------------

- (void) showPanel
{
    [dicePanel orderFront:self];
}

//----------------------------------------------------------------------

- (BOOL) isPanelOnScreen
{
    return [dicePanel isVisible];
}

//----------------------------------------------------------------------

- (void) setDieImage:(NSImageView *)aView fromInt:(int)value
{
    NSImage *image;

    switch (value)
    {
      case 1:
          image = _die1Image;
          break;

      case 2:
          image = _die2Image;
          break;

      case 3:
          image = _die3Image;
          break;

      case 4:
          image = _die4Image;
          break;

      case 5:
          image = _die5Image;
          break;

      case 6:
          image = _die6Image;
          break;

      default:
          image = nil;
          break;
    }

    [aView setImage:image];
}

//----------------------------------------------------------------------

- (void) showAttackFromCountry:(Country *)attacker
                     toCountry:(Country *)defender
                      withDice:(DiceRoll)dice
{
    int tmp;
    
    tmp = MIN (dice.attackerDieCount, dice.defenderDieCount);

    [attackerCountryName setStringValue:[attacker countryName]];
    [attackerArmyCount setIntValue:[attacker troopCount]];
    [attackerUsingDieCount setIntValue:tmp];
    [attackerRollingCount setIntValue:dice.attackerDieCount];

    [defenderCountryName setStringValue:[defender countryName]];
    [defenderArmyCount setIntValue:[defender troopCount]];
    [defenderUsingDieCount setIntValue:tmp];
    [defenderRollingCount setIntValue:dice.defenderDieCount];

    tmp = dice.attackerDieCount;
    [self setDieImage:attackerDie1 fromInt:((tmp > 0) ? dice.attackerDice[0] : 0)];
    [self setDieImage:attackerDie2 fromInt:((tmp > 1) ? dice.attackerDice[1] : 0)];
    [self setDieImage:attackerDie3 fromInt:((tmp > 2) ? dice.attackerDice[2] : 0)];

    tmp = dice.defenderDieCount;
    [self setDieImage:defenderDie1 fromInt:((tmp > 0) ? dice.defenderDice[0] : 0)];
    [self setDieImage:defenderDie2 fromInt:((tmp > 1) ? dice.defenderDice[1] : 0)];

    if ([pauseCheckBox state] == 1)
    {
        [self waitForContinue];
    }
}

//----------------------------------------------------------------------

- (void) waitForContinue
{
    NSInteger retVal;
	
    NSBeep ();
    [dicePanel orderFront:self];
    retVal = [NSApp runModalForWindow:dicePanel];
}

//----------------------------------------------------------------------

- (IBAction) continueAction:(id)sender
{
    [NSApp stopModal];
}

//----------------------------------------------------------------------

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

@end
