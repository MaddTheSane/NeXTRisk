//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: ArmyView.m,v 1.1.1.1 1997/12/09 07:18:52 nygard Exp $");

#import "ArmyView.h"

#define ArmyView_VERSION 1

static NSImage *_soldierImage;
static NSImage *_fiveImage;
static NSImage *_tenImage;

struct image_names
{
    NSString *i_name;
    NSImage **i_image;
};

static struct image_names class_images[] =
{
    { @"Soldier",    &_soldierImage },
    { @"5Soldiers",  &_fiveImage },
    { @"10Soldiers", &_tenImage },
};

@implementation ArmyView
@synthesize armyCount;

+ (void) initialize
{
    if (self == [ArmyView class])
    {
        [self setVersion:ArmyView_VERSION];

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

    if (self == [ArmyView class])
    {
        thisBundle = [NSBundle bundleForClass:self];
        NSAssert (thisBundle != nil, @"Could not get bundle.");

        // load class images
        for (l = 0; l < sizeof (class_images) / sizeof (struct image_names); l++)
        {
            *(class_images[l].i_image) = [[NSImage imageNamed:class_images[l].i_name] retain];
            NSAssert1 (*(class_images[l].i_image) != nil, @"Couldn't load image: '%@'\n", class_images[l].i_name);
        }
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//----------------------------------------------------------------------

- initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        armyCount = 0;
    }
	
    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [super dealloc];
}

//----------------------------------------------------------------------

- (void) setArmyCount:(int)newCount
{
    armyCount = newCount;
    [self setNeedsDisplay:YES];
}

//----------------------------------------------------------------------

#define INTERSPACE	-1.0

- (void) drawRect:(NSRect)rect
{
    NSPoint point;
    NSSize imageSize;
    int i;
    int tens, fives, ones;
	
    NSRect boundsRect;

    i = armyCount;
    tens = i / 10;
    i = i % 10;
    fives = i / 5;
    ones = i % 5;
	
    point = NSMakePoint (3, 5);
    boundsRect = [self bounds];

    NSDrawWhiteBezel (boundsRect, boundsRect);
    imageSize = [_tenImage size];
    for (i = 0; i < tens; i++)
    {
		[_tenImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        point.x += imageSize.width + INTERSPACE;
    }

    imageSize = [_fiveImage size];
    for (i = 0; i < fives; i++)
    {
		[_fiveImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        point.x += imageSize.width + INTERSPACE;
    }

    imageSize = [_soldierImage size];
    for (i = 0; i < ones; i++)
    {
		[_soldierImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        point.x += imageSize.width + INTERSPACE;
    }
}

@end
