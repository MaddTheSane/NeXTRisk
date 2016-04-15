//
// $Id: SNUserPath.h,v 1.1.1.1 1997/12/09 07:18:58 nygard Exp $
//

#import <AppKit/AppKit.h>

@class SNUserPathOperation;

@interface SNUserPath : NSObject
{
    NSMutableArray *operations;
    BOOL pathGenerated;

    // Data after path created;
    BOOL cached;
    DPSUserPathOp *operators;
    int operatorCount;
    float *operands;
    int operandCount;
}

+ (void) initialize;

- init;
- (void) dealloc;

- (void) encodeWithCoder:(NSCoder *)aCoder;
- initWithCoder:(NSCoder *)aDecoder;

- (void) addOperation:(SNUserPathOperation *)newOperation;

- (void) createPathWithCache:(BOOL)flag;

- (BOOL) isPathGenerated;
- (DPSUserPathOp *) operators;
- (int) operatorCount;
- (float *) operands;
- (int) operandCount;
- (float *) bbox;

- (NSRect) bounds;

- (void) getUserPath:(DPSUserPathOp **)operatorPtr:(int *)operatorCountPtr:(float **)operandPtr:(int *)operandCountPtr
                    :(float **)bboxPtr;

- (void) getFullUserPath:(DPSUserPathOp **)operatorPtr:(int *)operatorCountPtr:(float **)operandPtr:(int *)operandCountPtr;

- (void) fill;
- (void) evenOddFill;
- (void) stroke;

- (BOOL) inFill:(NSPoint)aPoint;
- (BOOL) inEvenOddFill:(NSPoint)aPoint;
- (BOOL) inStroke:(NSPoint)aPoint;

- (NSString *) description;

@end
