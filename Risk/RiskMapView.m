//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: RiskMapView.m,v 1.4 1997/12/18 21:03:47 nygard Exp $");

#import "RiskMapView.h"

#import "BoardSetup.h"
#import "Country.h"
#import "CountryShape.h"

//======================================================================
// The RiskMapView shows the background image and draws the countries
// over it.  It notifies it's delegate when a country has been selected.
//======================================================================

#define BOARDBACKING @"BoardBacking.tiff"

static NSImage *_boardBackingImage = nil;

#define RiskMapView_VERSION 1

@implementation RiskMapView

+ (void) initialize
// set our version
{
    if (self == [RiskMapView class])
    {
        [self setVersion:RiskMapView_VERSION];

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
    NSBundle *thisBundle;
    NSString *imagePath;
    
    thisBundle = [NSBundle bundleForClass:self];
    NSAssert (thisBundle != nil, @"Could not get bundle.");

    imagePath = [thisBundle pathForImageResource:BOARDBACKING];
    NSAssert1 (imagePath != nil, @"Could not find image: '%@'", BOARDBACKING);
    
    _boardBackingImage = [[NSImage alloc] initByReferencingFile:imagePath];
    NSAssert1 (_boardBackingImage != nil, @"Could not load image: '%@'", BOARDBACKING);
}

//----------------------------------------------------------------------

- (void) awakeFromNib
// post init initialization stuff
{
}

//----------------------------------------------------------------------

- initWithFrame:(NSRect)frameRect
// designated initializer
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    countryArray = nil;

    currentScaleFactor = 1;

    boardBackingImage = [_boardBackingImage copy];
    [boardBackingImage setScalesWhenResized:YES];

    delegate = nil;
    selectedCountry = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector (countryUpdated:)
                                          name:CountryUpdatedNotification
                                          object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector (boardSetupChanged:)
                                          name:RiskBoardSetupChangedNotification
                                          object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector (boardSetupChanged:)
                                          name:RiskBoardSetupPlayerColorsChangedNotification
                                          object:nil];

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
// free all our lists
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    SNRelease (boardBackingImage);
    SNRelease (countryArray);
    SNRelease (selectedCountry);
    SNRelease (delegate);
    
    [super dealloc];
}

//----------------------------------------------------------------------

- (BOOL) isOpaque
{
    return YES;
}

//----------------------------------------------------------------------

- (void) drawBackground:(NSRect)rect
{
    NSPoint aPoint;

    if (boardBackingImage != nil)
    {
        // draw backing
        aPoint = NSMakePoint (0, 0);
        //[boardBackingImage setSize:[self bounds].size]; // May want to make the image per instance (not per class)
        //[boardBackingImage compositeToPoint:aPoint operation:NSCompositeCopy];
        [boardBackingImage compositeToPoint:rect.origin fromRect:rect operation:NSCompositeCopy];
    }
}

- (void) drawRect:(NSRect)rect
// the meat of the display methods
{
    NSEnumerator *countryEnumerator;
    Country *country;
    NSRect countryBounds;

    [self drawBackground:rect];

    if (countryArray != nil)
    {
        countryEnumerator = [countryArray objectEnumerator];
        while (country = [countryEnumerator nextObject])
        {
            countryBounds = [[country countryShape] bounds];
            if (NSIsEmptyRect (NSIntersectionRect (countryBounds, rect)) == NO)
                [country drawInView:self isSelected:country == selectedCountry];
        }
    }

    // Redraw the selected country so that border is not overwritten.
    if (selectedCountry != nil)
        [selectedCountry drawInView:self isSelected:YES];
}

//----------------------------------------------------------------------

- (void) drawCountry:(Country *)aCountry
{
    // Get the union of country bounding box and the army cell,
    // and draw that.

#if 1
    // Currently, if troopCount drops to zero, the textfield is not
    // drawn, but the area it covers is not updated...
    [self lockFocus];
    [aCountry drawInView:self isSelected:aCountry == selectedCountry];

    // Redraw the selected country so that border is not overwritten.
    if (selectedCountry != nil && selectedCountry != aCountry)
        [selectedCountry drawInView:self isSelected:YES];

    [self unlockFocus];
#else
    [self displayRect:[[aCountry countryShape] bounds]]; // This cuts off the textfields at the bounding box.
#endif
    [[self window] flushWindow];
}

//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL hit;

    hit = NO;
    countryEnumerator = [countryArray objectEnumerator];
    while (hit == NO && (country = [countryEnumerator nextObject]) != nil)
    {
        hit = [country pointInCountry:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
        if (hit == YES)
        {
            if (delegate != nil && [delegate respondsToSelector:@selector (mouseDown:inCountry:)] == YES)
            {
                [delegate mouseDown:theEvent inCountry:country];
            }
        }
    }
}

//----------------------------------------------------------------------

- (void) mouseUp:(NSEvent *)theEvent
{
    NSEnumerator *countryEnumerator;
    Country *country;
    BOOL hit;

    hit = NO;
    countryEnumerator = [countryArray objectEnumerator];
    while (hit == NO && (country = [countryEnumerator nextObject]) != nil)
    {
        hit = [country pointInCountry:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
        if (hit == YES)
        {
            if (delegate != nil && [delegate respondsToSelector:@selector (mouseUp:inCountry:)] == YES)
            {
                [delegate mouseUp:theEvent inCountry:country];
            }
        }
    }
}

//----------------------------------------------------------------------

- (NSArray *) countryArray
{
    return countryArray;
}

//----------------------------------------------------------------------

- (void) setCountryArray:(NSArray *)countries
{
    [countryArray release];
    countryArray = [countries retain];

    [self setNeedsDisplay:YES];
    [[self superview] setNeedsDisplay:YES];
}

//----------------------------------------------------------------------

- (float) scaleFactor
{
    return currentScaleFactor;
}

//----------------------------------------------------------------------

- (void) setScaleFactor:(float)newScaleFactor
{
    NSSize imageSize;
    NSSize scaleSize;
    float factor;

    //NSLog (@"current: %f, new: %f", currentScaleFactor, newScaleFactor);

#if 1
    NSAssert (newScaleFactor != 0, @"Cannot scale to 0.");
    NSAssert (currentScaleFactor != 0, @"Current scale factor is 0.");
#endif    
    factor = newScaleFactor / currentScaleFactor;
    scaleSize = NSMakeSize (factor, factor);
    currentScaleFactor = newScaleFactor;

    [self scaleUnitSquareToSize:scaleSize];

    imageSize = [_boardBackingImage size];
    imageSize.width *= currentScaleFactor;
    imageSize.height *= currentScaleFactor;
    [boardBackingImage setSize:imageSize];
    [self setNeedsDisplay:YES];
    [[self superview] setNeedsDisplay:YES];
}

//----------------------------------------------------------------------

- delegate
{
    return delegate;
}

//----------------------------------------------------------------------

- (void) setDelegate:newDelegate
{
    if (delegate != nil)
        [delegate release];

    delegate = [newDelegate retain];
}

//----------------------------------------------------------------------
#if 0
- (NSString *) description
{
    //return [NSString stringWithFormat:@"<RiskMapView: boardBackingImage = %@, countryArray = %@, selectedCountry = %@, currentScaleFactor = %f, delegate = %@>", boardBackingImage, countryArray, selectedCountry, currentScaleFactor, delegate];
    return [NSString stringWithFormat:@"<RiskMapView: boardBackingImage = %@, countryArray = %@, selectedCountry = %@, currentScaleFactor = %f>", boardBackingImage, countryArray, selectedCountry, currentScaleFactor];
}
#endif
//----------------------------------------------------------------------

- (void) countryUpdated:(NSNotification *)aNotification
{
    Country *country;
    
    // Make sure country in array...

    country = [aNotification object];
    [self drawCountry:country];
}

//----------------------------------------------------------------------

- (void) selectCountry:(Country *)aCountry
{
    Country *tmp;

    //NSLog (@"old: %@, new: %@", selectedCountry, aCountry);

    tmp = selectedCountry;
    selectedCountry = [aCountry retain];

    if (tmp != nil)
    {
        [self drawCountry:tmp];
        [tmp release];
    }

    if (selectedCountry != nil)
    {
        [self drawCountry:selectedCountry];
    }
}

//----------------------------------------------------------------------

- (void) boardSetupChanged:(NSNotification *)aNotification
{
    // Note: This covers up the country name textfield.
    [self setNeedsDisplay:YES];
    [[self superview] setNeedsDisplay:YES];
}

@end
