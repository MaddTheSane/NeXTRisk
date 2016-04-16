//
// $Id: RiskUtility.h,v 1.1.1.1 1997/12/09 07:19:17 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class Country, RiskMapView, RiskNeighbor, RiskWorld, RiskCard;

@interface RiskUtility : NSObject
{
    IBOutlet RiskMapView *riskMapView;
    IBOutlet NSTextField *fromTextfield;
    IBOutlet NSTextField *toTextfield;

    Country *fromCountry;
    Country *toCountry;

    IBOutlet NSTableView *neighborTableView;

    NSDictionary *continents;
    NSMutableArray *countryNeighbors;
    NSArray *cards;
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotificaiton;

- (IBAction) saveWorld:(id)sender;
- (void) writeRiskWorld:(RiskWorld *)riskWorld;

+ (NSDictionary *) readContinentTextfile;
+ (NSArray *) readCountryTextfile:(NSSet *)continentNames;
+ (NSMutableArray *) readCountryNeighborsTextfile:(NSArray *)countries;

+ (NSArray *) readCardTextfile:(NSArray *)countryArray;

+ (NSString *) neighborString:(NSArray *)neighborArray;

+ (NSDictionary *) buildContinents:(NSDictionary *)continentBonuses fromCountries:(NSArray *)countries;

- init;

+ (Country *) scanCountry:(NSScanner *)scanner validContinents:(NSSet *)continentNames;
+ (RiskNeighbor *) scanRiskNeighbor:(NSScanner *)scanner usingCountries:(NSDictionary *)countries;
+ (RiskContinent) continentFromString:(NSString *)str;
+ (RiskCard *) scanRiskCard:(NSScanner *)scanner usingCountries:(NSDictionary *)countries;
+ (RiskCardType) riskCardTypeFromString:(NSString *)str;

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry;
- (void) mouseUp:(NSEvent *)theEvent inCountry:(Country *)aCountry;

- (IBAction) removeNeighbor:(id)sender;
- (IBAction) writeNeighborTextFile:(id)sender;

- (NSArray *) riskNeighbors;

//======================================================================
// NSTableDataSource
//======================================================================

- (int) numberOfRowsInTableView:(NSTableView *)aTableView;
- tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

@end
