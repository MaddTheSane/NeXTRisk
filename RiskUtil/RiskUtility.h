//
// $Id: RiskUtility.h,v 1.1.1.1 1997/12/09 07:19:17 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

#import "Risk.h"

@class Country, RiskMapView, RiskNeighbor, RiskWorld, RiskCard;

@interface RiskUtility : NSObject <NSApplicationDelegate, NSTableViewDataSource>
{
    IBOutlet RiskMapView *riskMapView;
    IBOutlet NSTextField *fromTextfield;
    IBOutlet NSTextField *toTextfield;

    Country *fromCountry;
    Country *toCountry;

    IBOutlet NSTableView *neighborTableView;

    NSDictionary *continents;
    NSMutableArray<RiskNeighbor*> *countryNeighbors;
    NSArray *cards;
}

- (IBAction) saveWorld:(id)sender;
- (void) writeRiskWorld:(RiskWorld *)riskWorld;

+ (NSDictionary *) readContinentTextfile;
+ (NSArray<Country*> *) readCountryTextfile:(NSSet<NSString*> *)continentNames;
+ (NSMutableArray<RiskNeighbor*> *) readCountryNeighborsTextfile:(NSArray<Country*> *)countries;

+ (NSArray<RiskCard*> *) readCardTextfile:(NSArray<Country *> *)countryArray;

+ (NSString *) neighborString:(NSArray<RiskNeighbor*> *)neighborArray;

+ (NSDictionary *) buildContinents:(NSDictionary *)continentBonuses fromCountries:(NSArray *)countries;

- (instancetype)init;

+ (Country *) scanCountry:(NSScanner *)scanner validContinents:(NSSet<NSString*> *)continentNames;
+ (RiskNeighbor *) scanRiskNeighbor:(NSScanner *)scanner usingCountries:(NSDictionary<NSString*,Country*> *)countries;
+ (RiskContinent) continentFromString:(NSString *)str;
+ (RiskCard *) scanRiskCard:(NSScanner *)scanner usingCountries:(NSDictionary<NSString*,Country*> *)countries;
+ (RiskCardType) riskCardTypeFromString:(NSString *)str;

- (void) mouseDown:(NSEvent *)theEvent inCountry:(Country *)aCountry;
- (void) mouseUp:(NSEvent *)theEvent inCountry:(Country *)aCountry;

- (IBAction) removeNeighbor:(id)sender;
- (IBAction) writeNeighborTextFile:(id)sender;

@property (readonly, copy) NSArray<RiskNeighbor*> *riskNeighbors;

@end
