//
// $Id: SNRandom.h,v 1.1.1.1 1997/12/09 07:18:57 nygard Exp $
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNRandom : NSObject

+ (SNRandom*)instance;
@property (class, readonly, strong) SNRandom *instance;

+ (void) seedGenerator:(int)seed;

// Primitive methods for generator.
- (void) seedGenerator:(int)seed;
- (long) randomNumber;

// Based on above primitive methods.
- (long) randomNumberModulo:(long)modulus;
- (long) randomNumberWithMaximum:(long)maximum NS_REFINED_FOR_SWIFT;
- (long) randomNumberBetween:(long)minimum :(long)maximum NS_REFINED_FOR_SWIFT;
- (double) randomPercent;
- (BOOL) randomBoolean;

- (long) rollDieWithSides:(int)sideCount;

@end

NS_ASSUME_NONNULL_END
