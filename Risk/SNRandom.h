//
// $Id: SNRandom.h,v 1.1.1.1 1997/12/09 07:18:57 nygard Exp $
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//! The SNRandom class provides a simple interface for random number
//! generation.  Different algorithms may be implemented by subclassing
//! and providing a method of seeding, and of generating a long random
//! number.
@interface SNRandom : NSObject

@property (class, readonly, strong) SNRandom *instance;

+ (void) seedGenerator:(int)seed;

// Primitive methods for generator.
- (void) seedGenerator:(int)seed;
- (long) randomNumber;

// Based on above primitive methods.
- (long) randomNumberModulo:(long)modulus;
- (long) randomNumberWithMaximum:(long)maximum;
- (long) randomNumberBetween:(long)minimum :(long)maximum;
- (double) randomPercent;
- (BOOL) randomBoolean;

- (long) rollDieWithSides:(int)sideCount;

@end

NS_ASSUME_NONNULL_END
