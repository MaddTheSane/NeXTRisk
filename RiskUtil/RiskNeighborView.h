//
// $Id: RiskNeighborView.h,v 1.1.1.1 1997/12/09 07:19:18 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Country.h"
#import "CountryShape.h"
#import "RiskMapView.h"

@protocol RiskNeighborViewDataSource <NSObject>
- (NSArray *) riskNeighbors;
@end

@interface RiskNeighborView : RiskMapView
{
    id<RiskNeighborViewDataSource> datasource;
}

- initWithFrame:(NSRect)frameRect;

- (void) drawRect:(NSRect)rect;

@end

