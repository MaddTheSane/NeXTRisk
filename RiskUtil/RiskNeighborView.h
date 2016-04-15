//
// $Id: RiskNeighborView.h,v 1.1.1.1 1997/12/09 07:19:18 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Country.h"
#import "CountryShape.h"
#import "RiskMapView.h"

@protocol RiskNeighborViewDataSource
- (NSArray *) riskNeighbors;
@end

@interface RiskNeighborView : RiskMapView
{
    id datasource;
}

+ (void) initialize;

- initWithFrame:(NSRect)frameRect;
- (void) dealloc;

- (void) drawRect:(NSRect)rect;

@end

