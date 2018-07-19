//
// $Id: RiskUtility.h,v 1.1.1.1 1997/12/09 07:19:17 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"
#import "RiskMapView.h"

@class RKCountry, RiskNeighbor, RiskWorld, RKCard;
@class RKContinent;

@interface RiskUtility : NSObject <NSApplicationDelegate, NSTableViewDataSource, RiskMapViewDelegate>
{
    IBOutlet RiskMapView *riskMapView;
    IBOutlet NSTextField *fromTextfield;
    IBOutlet NSTextField *toTextfield;

    RKCountry *fromCountry;
    RKCountry *toCountry;

    IBOutlet NSTableView *neighborTableView;

    NSDictionary<NSString*,RKContinent*> *continents;
    NSMutableArray<RiskNeighbor*> *countryNeighbors;
    NSArray<RKCard*> *cards;
}
@property (weak) IBOutlet NSWindow *window;

- (IBAction) saveWorld:(id)sender;
- (void) writeRiskWorld:(RiskWorld *)riskWorld;

+ (NSDictionary<NSString*,NSNumber*> *) readContinentTextfile;
+ (NSArray<RKCountry*> *) readCountryTextfile:(NSSet<NSString*> *)continentNames;
+ (NSMutableArray<RiskNeighbor*> *) readCountryNeighborsTextfile:(NSArray<RKCountry*> *)countries;

+ (NSArray<RKCard*> *) readCardTextfile:(NSArray<RKCountry *> *)countryArray;

+ (NSString *) neighborString:(NSArray<RiskNeighbor*> *)neighborArray;

+ (NSDictionary<NSString*,RKContinent*> *) buildContinents:(NSDictionary<NSString*,NSNumber*> *)continentBonuses fromCountries:(NSArray<RKCountry*> *)countries;

- (instancetype)init;

+ (RKCountry *) scanCountry:(NSScanner *)scanner validContinents:(NSSet<NSString*> *)continentNames;
+ (RiskNeighbor *) scanRiskNeighbor:(NSScanner *)scanner usingCountries:(NSDictionary<NSString*,RKCountry*> *)countries;
+ (RiskContinent) continentFromString:(NSString *)str;
+ (RKCard *) scanRiskCard:(NSScanner *)scanner usingCountries:(NSDictionary<NSString*,RKCountry*> *)countries;
+ (RKCardType) riskCardTypeFromString:(NSString *)str;

- (void) mouseDown:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry;
- (void) mouseUp:(NSEvent *)theEvent inCountry:(RKCountry *)aCountry;

- (IBAction) removeNeighbor:(id)sender;
- (IBAction) writeNeighborTextFile:(id)sender;

@property (readonly, copy) NSArray<RiskNeighbor*> *riskNeighbors;

@end
