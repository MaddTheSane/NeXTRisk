//
// This file is a part of Risk by Mike Ferris.
//

#import <RiskKit/Risk.h>

RCSID ("$Id: RiskMapView.m,v 1.4 1997/12/18 21:03:47 nygard Exp $");

#import "RiskMapView.h"

#import <RiskKit/RKBoardSetup.h>
#import <RiskKit/RKCountry.h>
#import <RiskKit/RKCountryShape.h>

#if !__has_feature(objc_arc)
#error this file needs to be compiled with Automatic Reference Counting (ARC)
#endif

#define BOARDBACKING @"BoardBacking"

static NSImage *_boardBackingImage = nil;

#define RiskMapView_VERSION 1

@implementation RiskMapView
@synthesize delegate;
@synthesize scaleFactor = currentScaleFactor;

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
    NSBundle *thisBundle = [NSBundle bundleForClass:self];
    NSAssert (thisBundle != nil, @"Could not get bundle.");
    
    _boardBackingImage = [thisBundle imageForResource:BOARDBACKING];
    NSAssert1 (_boardBackingImage != nil, @"Could not load image: '%@'", BOARDBACKING);
}

//----------------------------------------------------------------------

- (void) awakeFromNib
{
    [super awakeFromNib];
}

//----------------------------------------------------------------------

- (instancetype)initWithFrame:(NSRect)frameRect
// designated initializer
{
    if (self = [super initWithFrame:frameRect]) {
        countryArray = nil;
        
        currentScaleFactor = 1;
        
        boardBackingImage = [_boardBackingImage copy];
        
        delegate = nil;
        selectedCountry = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (countryUpdated:)
                                                     name:RKCountryUpdatedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (boardSetupChanged:)
                                                     name:RKBoardSetupChangedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector (boardSetupChanged:)
                                                     name:RKBoardSetupPlayerColorsChangedNotification
                                                   object:nil];
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
// free all our lists
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//----------------------------------------------------------------------

- (BOOL) isOpaque
{
    return YES;
}

//----------------------------------------------------------------------

- (void) drawBackground:(NSRect)rect
{
    if (boardBackingImage != nil)
    {
        // draw backing
        //NSPoint aPoint = NSMakePoint (0, 0);
        //[boardBackingImage setSize:[self bounds].size]; // May want to make the image per instance (not per class)
        //[boardBackingImage compositeToPoint:aPoint operation:NSCompositeCopy];
        [boardBackingImage drawAtPoint:rect.origin fromRect:rect operation:NSCompositingOperationCopy fraction:1];
    }
}

- (void) drawRect:(NSRect)rect
// the meat of the display methods
{
    [self drawBackground:rect];
    
    if (countryArray != nil)
    {
        for (RKCountry *country in countryArray)
        {
            NSRect countryBounds = country.countryShape.bounds;
            if (NSIsEmptyRect (NSIntersectionRect (countryBounds, rect)) == NO)
                [country drawInView:self isSelected:country == selectedCountry];
        }
    }
    
    // Redraw the selected country so that border is not overwritten.
    if (selectedCountry != nil)
        [selectedCountry drawInView:self isSelected:YES];
}

//----------------------------------------------------------------------

- (void) drawCountry:(RKCountry *)aCountry
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
    [self.window flushWindow];
}

//----------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent
{
    NSEnumerator *countryEnumerator;
    RKCountry *country;
    BOOL hit;
    
    hit = NO;
    countryEnumerator = [countryArray objectEnumerator];
    while (hit == NO && (country = [countryEnumerator nextObject]) != nil)
    {
        hit = [country pointInCountry:[self convertPoint:theEvent.locationInWindow fromView:nil]];
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
    RKCountry *country;
    BOOL hit;
    
    hit = NO;
    countryEnumerator = [countryArray objectEnumerator];
    while (hit == NO && (country = [countryEnumerator nextObject]) != nil)
    {
        hit = [country pointInCountry:[self convertPoint:theEvent.locationInWindow fromView:nil]];
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
    countryArray = [countries mutableCopy];
    
    [self setNeedsDisplay:YES];
    [self.superview setNeedsDisplay:YES];
}

//----------------------------------------------------------------------

- (void) setScaleFactor:(CGFloat)newScaleFactor
{
    NSSize imageSize;
    NSSize scaleSize;
    CGFloat factor;
    
    //NSLog (@"current: %f, new: %f", currentScaleFactor, newScaleFactor);
    
#if 1
    NSAssert (newScaleFactor != 0, @"Cannot scale to 0.");
    NSAssert (currentScaleFactor != 0, @"Current scale factor is 0.");
#endif
    factor = newScaleFactor / currentScaleFactor;
    scaleSize = NSMakeSize (factor, factor);
    currentScaleFactor = newScaleFactor;
    
    [self scaleUnitSquareToSize:scaleSize];
    
    imageSize = _boardBackingImage.size;
    imageSize.width *= currentScaleFactor;
    imageSize.height *= currentScaleFactor;
    boardBackingImage.size = imageSize;
    [self setNeedsDisplay:YES];
    [self.superview setNeedsDisplay:YES];
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
    RKCountry *country;
    
    // Make sure country in array...
    
    country = aNotification.object;
    [self drawCountry:country];
}

//----------------------------------------------------------------------

- (void) selectCountry:(RKCountry *)aCountry
{
    RKCountry *tmp;
    
    //NSLog (@"old: %@, new: %@", selectedCountry, aCountry);
    
    tmp = selectedCountry;
    selectedCountry = aCountry;
    
    if (tmp != nil)
    {
        [self drawCountry:tmp];
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
    [self.superview setNeedsDisplay:YES];
}

@end
