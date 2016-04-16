//
// $Id: WorldInfoController.h,v 1.1.1.1 1997/12/09 07:18:58 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@class RiskWorld;

@interface WorldInfoController : NSObject <NSTableViewDataSource>
{
    IBOutlet NSWindow *worldInfoWindow;

    IBOutlet NSTableView *continentTable;

    //RiskWorld *world;
    NSArray *continents;
}

- (instancetype)init;

//- (RiskWorld *) world;
- (void) setWorld:(RiskWorld *)newWorld;

- (void) showPanel;

- (void) orderByName;
- (void) orderByCountryCount;
- (void) orderByBonusValue;

- (IBAction) reorder:(id)sender;

@end
