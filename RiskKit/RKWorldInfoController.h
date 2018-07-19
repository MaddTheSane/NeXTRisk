//
// $Id: WorldInfoController.h,v 1.1.1.1 1997/12/09 07:18:58 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/NSTableView.h>

NS_ASSUME_NONNULL_BEGIN

@class RiskWorld;
@class RKContinent;
@class NSWindow;

/// The World Info report shows the name of the world, and the name,
/// number of countries, and bonus value for each continent.
///
/// Double click on the column titles to sort by that column.
@interface RKWorldInfoController : NSObject <NSTableViewDataSource>
{
    IBOutlet NSWindow *worldInfoWindow;

    IBOutlet NSTableView *continentTable;

    //RiskWorld *world;
    NSArray<RKContinent*> *continents;
}

- (instancetype)init;

//- (RiskWorld *) world;
- (void) setWorld:(RiskWorld *)newWorld;

- (void) showPanel;

- (void) orderByName;
- (void) orderByCountryCount;
- (void) orderByBonusValue;

- (IBAction) reorder:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
