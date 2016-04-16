//
// $Id: SNRandom.h,v 1.1.1.1 1997/12/09 07:18:57 nygard Exp $
//

#import <Foundation/Foundation.h>

@interface SNRandom : NSObject
{
}

+ (SNRandom*)instance;

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
