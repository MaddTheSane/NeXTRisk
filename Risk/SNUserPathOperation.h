//
// $Id: SNUserPathOperation.h,v 1.1.1.1 1997/12/09 07:18:58 nygard Exp $
//

#import <AppKit/AppKit.h>
#import <AppKit/dpsOpenStep.h>

@interface SNUserPathOperation : NSObject
{
    DPSUserPathOp operator;

    NSPoint point1;
    NSPoint point2;
    NSPoint point3;
    float radius;
    float angle1;
    float angle2;
}

+ (void) initialize;

+ _operation:(DPSUserPathOp)anOperator;

+ arc:(NSPoint)aPoint:(float)aRadius:(float)anAngle1:(float)anAngle2;
+ arcn:(NSPoint)aPoint:(float)aRadius:(float)anAngle1:(float)anAngle2;
+ arct:(NSPoint)aPoint1:(NSPoint)aPoint2:(float)aRadius;
+ closepath;
+ curveto:(NSPoint)aPoint1:(NSPoint)aPoint2:(NSPoint)aPoint3;
+ lineto:(NSPoint)aPoint;
+ moveto:(NSPoint)aPoint;
+ rcurveto:(NSPoint)delta1:(NSPoint)delta2:(NSPoint)delta3;
+ rlineto:(NSPoint)delta;
+ rmoveto:(NSPoint)delta;
+ setbbox:(NSPoint)lowerLeft:(NSPoint)upperRight;
+ ucache;

- initWithOperator:(DPSUserPathOp)anOperator;

- (void) encodeWithCoder:(NSCoder *)aCoder;
- initWithCoder:(NSCoder *)aDecoder;

- (int) operandCount;
- (DPSUserPathOp) operator;
- (void) operands:(float *)operands;

- (NSPoint) lowerLeft;
- (NSPoint) upperRight;

// Private
- (void) setPoint1:(NSPoint)aPoint;
- (void) setPoint2:(NSPoint)aPoint;
- (void) setPoint3:(NSPoint)aPoint;
- (void) setRadius:(float)newRadius;
- (void) setAngle1:(float)anAngle;
- (void) setAngle2:(float)anAngle;

- (NSString *) description;

@end
