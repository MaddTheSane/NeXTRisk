//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: DiceInspector.m,v 1.2 1997/12/15 07:43:50 nygard Exp $");

#import "RKDiceInspector.h"
#import "RKCountry.h"

#define DiceInspector_VERSION 1

static NSImage *_die1Image;
static NSImage *_die2Image;
static NSImage *_die3Image;
static NSImage *_die4Image;
static NSImage *_die5Image;
static NSImage *_die6Image;

struct image_names
{
    CFStringRef i_name;
    NSImage *__strong*i_image;
};

static struct image_names class_images[] =
{
    { CFSTR("Die1"),    &_die1Image },
    { CFSTR("Die2"),    &_die2Image },
    { CFSTR("Die3"),    &_die3Image },
    { CFSTR("Die4"),    &_die4Image },
    { CFSTR("Die5"),    &_die5Image },
    { CFSTR("Die6"),    &_die6Image },
};

@implementation RKDiceInspector
{
    NSArray *nibObjs;
}

+ (void) initialize
{
    if (self == [RKDiceInspector class])
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
    if (self == [RKDiceInspector class])
    {
        NSBundle *thisBundle = [NSBundle bundleForClass:self];
        NSAssert (thisBundle != nil, @"Could not get bundle.");
        
        // load class images
        for (int l = 0; l < sizeof (class_images) / sizeof (struct image_names); l++)
        {
            NSString *imagePath = (__bridge NSString *)(class_images[l].i_name);
            //imagePath = [thisBundle pathForImageResource:class_images[l].i_name];
            //NSAssert1 (imagePath != nil, @"Could not find image: '%@'", class_images[l].i_name);
            
            *(class_images[l].i_image) = [NSImage imageNamed:imagePath];
            if (! *(class_images[l].i_image)) {
                *(class_images[l].i_image) = [thisBundle imageForResource:imagePath];
            }
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
        NSArray *tmpArr;
        nibFile = @"DiceInspector";
        loaded = [[NSBundle bundleForClass:[self class]] loadNibNamed:nibFile owner:self topLevelObjects:&tmpArr];
        nibObjs = tmpArr;
        if (loaded == NO)
        {
            NSLog (@"Could not load %@.", nibFile);
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

- (void) showPanel
{
    [dicePanel orderFront:self];
}

//----------------------------------------------------------------------

- (BOOL) isPanelOnScreen
{
    return dicePanel.visible;
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
    
    aView.image = image;
}

//----------------------------------------------------------------------

- (void) showAttackFromCountry:(RKCountry *)attacker
                     toCountry:(RKCountry *)defender
                      withDice:(RKDiceRoll)dice
{
    int tmp;
    
    tmp = MIN (dice.attackerDieCount, dice.defenderDieCount);
    
    attackerCountryName.stringValue = attacker.countryName;
    attackerArmyCount.intValue = attacker.troopCount;
    attackerUsingDieCount.intValue = tmp;
    attackerRollingCount.intValue = dice.attackerDieCount;
    
    defenderCountryName.stringValue = defender.countryName;
    defenderArmyCount.intValue = defender.troopCount;
    defenderUsingDieCount.intValue = tmp;
    defenderRollingCount.intValue = dice.defenderDieCount;
    
    tmp = dice.attackerDieCount;
    [self setDieImage:attackerDie1 fromInt:((tmp > 0) ? dice.attackerDice[0] : 0)];
    [self setDieImage:attackerDie2 fromInt:((tmp > 1) ? dice.attackerDice[1] : 0)];
    [self setDieImage:attackerDie3 fromInt:((tmp > 2) ? dice.attackerDice[2] : 0)];
    
    tmp = dice.defenderDieCount;
    [self setDieImage:defenderDie1 fromInt:((tmp > 0) ? dice.defenderDice[0] : 0)];
    [self setDieImage:defenderDie2 fromInt:((tmp > 1) ? dice.defenderDice[1] : 0)];
    
    if (pauseCheckBox.state == 1)
    {
        [self waitForContinue];
    }
}

//----------------------------------------------------------------------

- (void) waitForContinue
{
    NSBeep();
    [dicePanel orderFront:self];
    [NSApp runModalForWindow:dicePanel];
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
