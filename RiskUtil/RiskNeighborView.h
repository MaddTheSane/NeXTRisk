//
// $Id: RiskNeighborView.h,v 1.1.1.1 1997/12/09 07:19:18 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Country.h"
#import "CountryShape.h"
#import "RiskMapView.h"

@class RiskNeighbor;

@protocol RiskNeighborViewDataSource <NSObject>
- (NSArray<RiskNeighbor*> *) riskNeighbors;
@end

@interface RiskNeighborView : RiskMapView
{
    IBOutlet id<RiskNeighborViewDataSource> datasource;
}

- (instancetype)initWithFrame:(NSRect)frameRect;

- (void) drawRect:(NSRect)rect;

@end

