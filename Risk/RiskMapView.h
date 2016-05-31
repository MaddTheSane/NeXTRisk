//
// $Id: RiskMapView.h,v 1.1.1.1 1997/12/09 07:18:55 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class Country;

@protocol RiskMapViewDelegate <NSObject>
- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry;
- (void) mouseUp:(NSEvent *)theEvent inCountry:(Country *)aCountry;
@end

/// The RiskMapView shows the background image and draws the countries
/// over it.  It notifies its delegate when a country has been selected.
@interface RiskMapView : NSView
{
    NSImage *boardBackingImage;
    NSMutableArray *countryArray;
    Country *selectedCountry;

    CGFloat currentScaleFactor;
}

+ (void) loadClassImages;

- (instancetype)initWithFrame:(NSRect)frameRect;

- (void) drawBackground:(NSRect)rect;
- (void) drawRect:(NSRect)rect;
- (void) drawCountry:(Country *)aCountry;

- (void) mouseDown:(NSEvent *)theEvent;
- (void) mouseUp:(NSEvent *)theEvent;

@property (copy) NSArray<Country*> *countryArray;

@property (nonatomic) CGFloat scaleFactor;

@property (strong) IBOutlet id<RiskMapViewDelegate> delegate;

- (void) countryUpdated:(NSNotification *)aNotification;

- (void) selectCountry:(Country *)aCountry;

- (void) boardSetupChanged:(NSNotification *)aNotification;

@end
