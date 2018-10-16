//
// Random
//
// An Objective-C class for NeXT computers to provide services for random
// number generation and also die rolling.
//
// The Random class implements its own random number generator with a cycle
// length of 8.8 trillion.
// 
// Upon creation of a Random, the seeds are set using the system clock.
// Three calls are made to the system clock function, and for each the 
// microseconds are used as the seed value. Thus, the relationships between
// the seeds are dependant upon system load.
//
// The algorithm used by the Random class is that given in the article:
//   "A Higly Random Random-Number Generator" by T.A. Elkins
//   Computer Language, Volume 6, Number 12 (December 1989), Pages 59-65
//   Published by:
//        Miller Freeman Publications
//        500 Howard Street
//        San Francisco, CA  94105
//        (415) 397-1881
//
// History:
//   pre 1990 Mar 23
//     Used random number generation algorithm from K&R.
//   1990 Mar 23
//     Modified to use algorithm with cycle length of 8.8 trillion.
//   1990 Mar 26
//     * Added archiving.
//     * Added randMax:, randMin:Max:, and percent:.
//   1991 Apr 26
//     * Changed to use +alloc and -init as all NeXTStep 2.0 objects should.
//   1991 May 30
//     * Prepared for distribution and initial release.
//
//   1991 Nov 5
//     * Added - (BOOL)bool method.
//
//   1991 Dec 30
//     * Changed - (float)percent to return double instead.
//     * Added - (double)randFunc: method.
//
//   1992 Feb 27
//     * Added Gaussian functionality.
//
// Version 1.1, 1992 Feb 27 
//
// Written by Gregor Purdy
// gregor@umich.edu
//
// See the README file included for information
// and distribution and usage rights. 
//


#import <objc/Object.h>
#import <objc/typedstream.h>


typedef double (*ddfunc)(double);			// Double Function Returning Double.


@interface Random : Object


{
    int h1, h2, h3;			// Seeds.
    
    int		iset;			// For gaussian generation.
    double	gset;
    
    double	gscale;			// Gaussian scaling;
    double	gorigin;		// Gaussian origin;
}

+ (int)version;				// Version of the class.

- init;					// Init with seeds from newSeeds.
- initSeeds:(int)s1			// Init with seeds given.
  :(int)s2
  :(int)s3;

- newSeeds;				// Get seeds from system time.
- setSeeds:(int) s1			// Set seeds to those given.
  :(int) s2
  :(int) s3;
- getSeeds:(int *)s1			// Put the seeds into some vars.
  :(int *)s2
  :(int *)s3;

- (int)rand;				// Return a random integer.
- (int)randMax:(int)max;		// Return a random integer 0 <= x <= max.
- (int)randMin:(int)min			// Return a random integer min <= x <= max.
  max:(int)max;
- (double)percent;			// Return a random double 0.0 <= x <= 1.0.
- (BOOL)bool;				// Return randomly, YES or NO.

- (int)rollDie:(int)numSides;		// Return a random integer 1 <= x <= numSides.
- (int)roll:(int)numRolls		// Return the best numWanted of numRolls rolls.
  die:(int)numSides;
- (int)rollBest:(int)numWanted		// Return integer sum of best numWanted rolls.
  of:(int)numRolls
  die:(int)numSides;

- (double)randFunc:(ddfunc)func;	// See description file.

- (double)gScale;
- setGScale:(double)aScale;
- (double)gOrigin;
- setGOrigin:(double)anOrigin;
- (double)gaussian;			// Return gausian variable.

- read:(NXTypedStream *)stream;		// De-archive from a typed stream.
- write:(NXTypedStream *)stream;	// Archive to a typed stream.


@end


//
// End of file.
//