
#import "Risk.h"

RCSID ("$Id: SNRandom.m,v 1.2 1997/12/15 07:44:17 nygard Exp $");

#import "SNRandom.h"

#ifndef WIN32
#import <libc.h>
#define SRANDOM(x) srandom(x)
#define RANDOM() random()
#else
#define SRANDOM(x) srand(x)
#define RANDOM() rand()
#endif

//======================================================================
// The SNRandom class provides a simple interface for random number
// generation.  Different algorithms may be implemented by subclassing
// and providing a method of seeding, and of generating a long random
// number.
//======================================================================

static SNRandom *_instance = nil;

#define DK_SeedRandom @"SeedRandom"

#define SNRandom_VERSION 1

@implementation SNRandom

+ (void) initialize
{
    NSUserDefaults *defaults;
    NSMutableDictionary *riskDefaults;
    BOOL flag;
    
    if (self == [SNRandom class])
    {
        [self setVersion:SNRandom_VERSION];
        
        // Optionally (defaults) seed here? or in +instance?
        defaults = [NSUserDefaults standardUserDefaults];
        riskDefaults = [NSMutableDictionary dictionary];
        
        riskDefaults[DK_SeedRandom] = @YES;
        
        [defaults registerDefaults:riskDefaults];
        
        flag = [defaults boolForKey:DK_SeedRandom];
        if (flag == YES)
        {
            [SNRandom seedGenerator:time (NULL) & 0x7FFFFFFF];
        }
    }
}

//----------------------------------------------------------------------

// How does subclassing affect this?
+ instance
{
    if (_instance == nil)
    {
        _instance = [[SNRandom alloc] init];
    }
    
    return _instance;
}

//----------------------------------------------------------------------

+ (void) seedGenerator:(int)seed
{
    SRANDOM (seed);
}

//----------------------------------------------------------------------

- (void) seedGenerator:(int)seed
{
    SRANDOM (seed);
}

//----------------------------------------------------------------------

- (long) randomNumber
{
    return RANDOM ();
}

//----------------------------------------------------------------------

- (long) randomNumberModulo:(long)modulus
{
    NSAssert (modulus != 0, @"Modulus cannot be zero.");
    return [self randomNumber] % modulus;
}

//----------------------------------------------------------------------

- (long) randomNumberWithMaximum:(long)maximum
{
    return [self randomNumber] % (maximum + 1);
}

//----------------------------------------------------------------------

- (long) randomNumberBetween:(long)minimum :(long)maximum
{
    if (maximum <= minimum)
        return minimum;
    
    return minimum + [self randomNumberWithMaximum:maximum - minimum];
}

//----------------------------------------------------------------------

#define RANGE_FOR_PERCENT 1000000000.0
- (double) randomPercent
{
    return (double)[self randomNumberWithMaximum:RANGE_FOR_PERCENT] / RANGE_FOR_PERCENT * 100;
}

//----------------------------------------------------------------------

- (BOOL) randomBoolean
{
    return [self randomNumberWithMaximum:1] == 1;
}

//----------------------------------------------------------------------

- (long) rollDieWithSides:(int)sideCount
{
    return [self randomNumberBetween:1:sideCount];
}

@end
