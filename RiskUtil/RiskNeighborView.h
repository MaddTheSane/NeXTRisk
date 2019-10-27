//
// $Id: RiskNeighborView.h,v 1.1.1.1 1997/12/09 07:19:18 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import <RiskKit/RKCountry.h>
#import "CountryShape.h"
#import "RiskMapView.h"

@class RKNeighbor;

@protocol RiskNeighborViewDataSource <NSObject>
- (NSArray<RKNeighbor*> *) riskNeighbors;
@end

@interface RiskNeighborView : RiskMapView
{
    __weak id<RiskNeighborViewDataSource> datasource;
}
@property (weak) IBOutlet id<RiskNeighborViewDataSource> dataSource;

- (instancetype)initWithFrame:(NSRect)frameRect;

- (void) drawRect:(NSRect)rect;

@end

