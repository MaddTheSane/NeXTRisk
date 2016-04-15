
#import "Risk.h"

RCSID ("$Id: SNUserPath.m,v 1.2 1997/12/15 07:44:18 nygard Exp $");

#import "SNUserPath.h"

#import <Foundation/NSObjCRuntime.h>

#import "SNUserPathOperation.h"
#import "SNUserPathWraps.h"

//======================================================================
// An SNUserPath provides an interface for creating user paths and
// using them for drawing or hit detection.  The bounding box
// calculations are incomplete, but work with straight lines.
//
// The MiscKit provides a more complete implementation.  Under Rhapsody
// this will probably move towards using the NSBezierPath path.
//
// Note that this means curved paths could be easily supported to
// provide better looking maps, but RiskUtil.app would need to be
// able to support them.
//======================================================================

#define SNUserPath_VERSION 1

@implementation SNUserPath

+ (void) initialize
{
    if (self == [SNUserPath class])
    {
        [self setVersion:SNUserPath_VERSION];
    }
}

//----------------------------------------------------------------------

- init
{
    if ([super init] == nil)
        return nil;

    operations = [[NSMutableArray array] retain];
    pathGenerated = NO;

    cached = NO;
    operators = NULL;
    operatorCount = 0;
    operands = NULL;
    operandCount = 0;

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (operations);

    if (operators != NULL)
        free (operators);

    if (operands != NULL)
        free (operands);

    [super dealloc];
}

//----------------------------------------------------------------------

// Encodes operations, not the generated user path data structures
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:operations];
    //[aCoder encodeValueOfObjCType:@encode (BOOL) at:&pathGenerated];
}

//----------------------------------------------------------------------

- initWithCoder:(NSCoder *)aDecoder
{
    [super init];

    operations = [[aDecoder decodeObject] retain];
    pathGenerated = NO;

    cached = NO;
    operators = NULL;
    operatorCount = 0;
    operands = NULL;
    operandCount = 0;

    return self;
}

//----------------------------------------------------------------------

- (void) addOperation:(SNUserPathOperation *)newOperation
{
    NSAssert (pathGenerated == NO, @"The user path has already been generated.");

    [operations addObject:newOperation];
}

//----------------------------------------------------------------------

// Also creates bounding box

- (void) createPathWithCache:(BOOL)flag
{
    NSEnumerator *enumerator;
    SNUserPathOperation *operation;
    DPSUserPathOp *nextOperator;
    float *nextOperand;
    NSPoint lowerLeft, upperRight;
    NSPoint ll, ur;

    NSAssert (pathGenerated == NO, @"The user path has already been generated.");

    lowerLeft = NSMakePoint (10000, 10000);
    upperRight = NSMakePoint (-10000, -10000);

    enumerator = [operations objectEnumerator];
    while (operation = [enumerator nextObject])
    {
        ll = [operation lowerLeft];
        ur = [operation upperRight];

        //NSLog (@"** lowerLeft: (%f,%f), point: (%f,%f)", lowerLeft.x, lowerLeft.y, ll.x, ll.y);
        lowerLeft.x = MIN (ll.x, lowerLeft.x);
        lowerLeft.y = MIN (ll.y, lowerLeft.y);
        //NSLog (@"** new lowerLeft: (%f,%f)", lowerLeft.x, lowerLeft.y);

        upperRight.x = MAX (ur.x, upperRight.x);
        upperRight.y = MAX (ur.y, upperRight.y);
    }
    
    //NSLog (@"snup bbox: lowerLeft (%f,%f), upperRight (%f,%f)", lowerLeft.x, lowerLeft.y, upperRight.x, upperRight.y);
    [operations insertObject:[SNUserPathOperation setbbox:lowerLeft:upperRight] atIndex:0];

    if (flag == YES)
    {
        cached = YES;
        [operations insertObject:[SNUserPathOperation ucache] atIndex:0];
    }

    operatorCount = [operations count];
    enumerator = [operations objectEnumerator];
    operandCount = 0;
    while (operation = [enumerator nextObject])
    {
        operandCount += [operation operandCount];
    }

    // Mallocing...
    operators = (DPSUserPathOp *) malloc (operatorCount * sizeof (float));
    NSAssert (operators != NULL, @"Could not malloc() operators.");
    
    operands = (float *) malloc (operandCount * sizeof (float));
    NSAssert (operands != NULL, @"Could not malloc() operands.");

    nextOperator = operators;
    nextOperand = operands;

    enumerator = [operations objectEnumerator];
    while (operation = [enumerator nextObject])
    {
        *nextOperator++ = [operation operator];
        [operation operands:nextOperand];
        nextOperand += [operation operandCount];
    }

    pathGenerated = YES;

    if (cached == YES)
    {
        // Remove it to make sure it's not archived (which might result
        // in duplicate ucache operators.)
        [operations removeObjectAtIndex:0];
    }

    // Get rid of the bounding box for the same reason.
    [operations removeObjectAtIndex:0];
}

//----------------------------------------------------------------------

- (BOOL) isPathGenerated
{
    return pathGenerated;
}

//----------------------------------------------------------------------

- (DPSUserPathOp *) operators
{
    NSAssert (pathGenerated == YES, @"The user path has not been generated.");
    return operators + ((cached == YES) ? 2 : 1); // Skip over bbox
}

//----------------------------------------------------------------------

- (int) operatorCount
{
    NSAssert (pathGenerated == YES, @"The user path has not been generated.");
    return operatorCount - ((cached == YES) ? 2 : 1); // Skip bbox
}

//----------------------------------------------------------------------

- (float *) operands
{
    NSAssert (pathGenerated == YES, @"The user path has not been generated.");
    return operands + 4; // Skip bbox
}

//----------------------------------------------------------------------

- (int) operandCount
{
    NSAssert (pathGenerated == YES, @"The user path has not been generated.");
    return operandCount - 4; // Skip bbox
}

//----------------------------------------------------------------------

- (float *) bbox
{
    return operands;
}

//----------------------------------------------------------------------

- (NSRect) bounds
{
    return NSMakeRect (operands[0], operands[1], operands[2] - operands[0], operands[3] - operands[1]);
}

//----------------------------------------------------------------------

- (void) getUserPath:(DPSUserPathOp **)operatorPtr:(int *)operatorCountPtr:(float **)operandPtr:(int *)operandCountPtr
                    :(float **)bboxPtr
{
    NSAssert (pathGenerated == YES, @"The user path has not been generated.");

    *operatorPtr = operators + ((cached == YES) ? 2 : 1);
    *operatorCountPtr = operatorCount - ((cached == YES) ? 2 : 1);
    *operandPtr = operands + 4;
    *operandCountPtr = operandCount - 4;
    *bboxPtr = operands;
}

//----------------------------------------------------------------------

- (void) getFullUserPath:(DPSUserPathOp **)operatorPtr:(int *)operatorCountPtr:(float **)operandPtr:(int *)operandCountPtr
{
    NSAssert (pathGenerated == YES, @"The user path has not been generated.");

    *operatorPtr = operators;
    *operatorCountPtr = operatorCount;
    *operandPtr = operands;
    *operandCountPtr = operandCount;
}

//----------------------------------------------------------------------

- (void) fill
{
    SNUserPathDraw (operators, operatorCount, operands, operandCount, dps_ufill);
}

//----------------------------------------------------------------------

- (void) evenOddFill
{
    SNUserPathDraw (operators, operatorCount, operands, operandCount, dps_ueofill);
}

//----------------------------------------------------------------------

- (void) stroke
{
    SNUserPathDraw (operators, operatorCount, operands, operandCount, dps_ustroke);
}

//----------------------------------------------------------------------

- (BOOL) inFill:(NSPoint)aPoint
{
    int r = 0;
    SNUserPathWasHitFill (aPoint.x, aPoint.y, operators, operatorCount, operands, operandCount, &r);
    return r == 1;
}

//----------------------------------------------------------------------

- (BOOL) inEvenOddFill:(NSPoint)aPoint
{
    int r = 0;
    SNUserPathWasHitEvenOddFill (aPoint.x, aPoint.y, operators, operatorCount, operands, operandCount, &r);
    return r == 1;
}

//----------------------------------------------------------------------

- (BOOL) inStroke:(NSPoint)aPoint
{
    int r = 0;
    SNUserPathWasHitStroke (aPoint.x, aPoint.y, operators, operatorCount, operands, operandCount, &r);
    return r == 1;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<SNUserPath: pathGenerated = %@, operations = %@>",
                     (pathGenerated == YES) ? @"Yes" : @"No", operations];
}

@end
