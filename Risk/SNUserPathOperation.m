#import "Risk.h"

RCSID ("$Id: SNUserPathOperation.m,v 1.2 1997/12/15 07:44:20 nygard Exp $");

#import "SNUserPathOperation.h"

#import "NSObjectExtensions.h"
#import <Foundation/NSObjCRuntime.h>

//======================================================================
// An SNUserPathOperation represents an user path operator and its
// operands so that is can be stored in an array.
//======================================================================

#define SNUserPathOperation_VERSION 1

@implementation SNUserPathOperation

+ (void) initialize
{
    if (self == [SNUserPathOperation class])
    {
        [self setVersion:SNUserPathOperation_VERSION];
    }
}

//----------------------------------------------------------------------

+ _operation:(DPSUserPathOp)anOperator
{
    return [[[SNUserPathOperation alloc] initWithOperator:anOperator] autorelease];
}

//----------------------------------------------------------------------

+ arc:(NSPoint)aPoint:(float)aRadius:(float)anAngle1:(float)anAngle2
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_arc];
    [op setPoint1:aPoint];
    [op setRadius:aRadius];
    [op setAngle1:anAngle1];
    [op setAngle2:anAngle2];

    return op;
}

//----------------------------------------------------------------------

+ arcn:(NSPoint)aPoint:(float)aRadius:(float)anAngle1:(float)anAngle2
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_arcn];
    [op setPoint1:aPoint];
    [op setRadius:aRadius];
    [op setAngle1:anAngle1];
    [op setAngle2:anAngle2];

    return op;
}

//----------------------------------------------------------------------

+ arct:(NSPoint)aPoint1:(NSPoint)aPoint2:(float)aRadius
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_arct];
    [op setPoint1:aPoint1];
    [op setPoint2:aPoint2];
    [op setRadius:aRadius];

    return op;
}

//----------------------------------------------------------------------

+ closepath
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_closepath];

    return op;
}

//----------------------------------------------------------------------

+ curveto:(NSPoint)aPoint1:(NSPoint)aPoint2:(NSPoint)aPoint3
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_curveto];
    [op setPoint1:aPoint1];
    [op setPoint2:aPoint2];
    [op setPoint3:aPoint3];

    return op;
}

//----------------------------------------------------------------------

+ lineto:(NSPoint)aPoint
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_lineto];
    [op setPoint1:aPoint];

    return op;
}

//----------------------------------------------------------------------

+ moveto:(NSPoint)aPoint
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_moveto];
    [op setPoint1:aPoint];

    return op;
}

//----------------------------------------------------------------------

+ rcurveto:(NSPoint)delta1:(NSPoint)delta2:(NSPoint)delta3
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_rcurveto];
    [op setPoint1:delta1];
    [op setPoint2:delta2];
    [op setPoint3:delta3];

    return op;
}

//----------------------------------------------------------------------

+ rlineto:(NSPoint)delta
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_rlineto];
    [op setPoint1:delta];

    return op;
}

//----------------------------------------------------------------------

+ rmoveto:(NSPoint)delta
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_rmoveto];
    [op setPoint1:delta];

    return op;
}

//----------------------------------------------------------------------

+ setbbox:(NSPoint)lowerLeft:(NSPoint)upperRight
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_setbbox];
    [op setPoint1:lowerLeft];
    [op setPoint2:upperRight];

    return op;
}

//----------------------------------------------------------------------

+ ucache
{
    SNUserPathOperation *op;

    op = [SNUserPathOperation _operation:dps_ucache];

    return op;
}

//----------------------------------------------------------------------

- initWithOperator:(DPSUserPathOp)anOperator
{
    if ([super init] == nil)
        return nil;

    operator = anOperator;

    return self;
}

//----------------------------------------------------------------------

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeValueOfObjCType:@encode (DPSUserPathOp) at:&operator];
    [aCoder encodePoint:point1];
    [aCoder encodePoint:point2];
    [aCoder encodePoint:point3];
    [aCoder encodeValueOfObjCType:@encode (float) at:&radius];
    [aCoder encodeValueOfObjCType:@encode (float) at:&angle1];
    [aCoder encodeValueOfObjCType:@encode (float) at:&angle2];
}

//----------------------------------------------------------------------

- initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    [aDecoder decodeValueOfObjCType:@encode (DPSUserPathOp) at:&operator];
    point1 = [aDecoder decodePoint];
    point2 = [aDecoder decodePoint];
    point3 = [aDecoder decodePoint];
    [aDecoder decodeValueOfObjCType:@encode (float) at:&radius];
    [aDecoder decodeValueOfObjCType:@encode (float) at:&angle1];
    [aDecoder decodeValueOfObjCType:@encode (float) at:&angle2];

    return self;
}

//----------------------------------------------------------------------

- (int) operandCount
{
    int count;
    
    switch (operator)
    {
      case dps_arc:
      case dps_arcn:
      case dps_arct:
          count = 5;
          break;

      case dps_curveto:
      case dps_rcurveto:
          count = 6;
          break;
          
      case dps_lineto:
      case dps_moveto:
      case dps_rlineto:
      case dps_rmoveto:
          count = 2;
          break;

      case dps_setbbox:
          count = 4;
          break;

      case dps_closepath:
      case dps_ucache:
      default:
          count = 0;
    }

    return count;
}

//----------------------------------------------------------------------

- (DPSUserPathOp) operator
{
    return operator;
}

//----------------------------------------------------------------------

- (void) operands:(float *)operands
{
    switch (operator)
    {
      case dps_arc:
      case dps_arcn:
          *operands++ = point1.x;
          *operands++ = point1.y;
          *operands++ = radius;
          *operands++ = angle1;
          *operands++ = angle2;
          break;

      case dps_arct:
          *operands++ = point1.x;
          *operands++ = point1.y;
          *operands++ = point2.x;
          *operands++ = point2.y;
          *operands++ = radius;
          break;

      case dps_closepath:
          break;

      case dps_curveto:
      case dps_rcurveto:
          *operands++ = point1.x;
          *operands++ = point1.y;
          *operands++ = point2.x;
          *operands++ = point2.y;
          *operands++ = point3.x;
          *operands++ = point3.y;
          break;

      case dps_lineto:
      case dps_moveto:
      case dps_rlineto:
      case dps_rmoveto:
          *operands++ = point1.x;
          *operands++ = point1.y;
          break;

      case dps_setbbox:
          *operands++ = point1.x;
          *operands++ = point1.y;
          *operands++ = point2.x;
          *operands++ = point2.y;
          *operands++ = radius;
          break;

      case dps_ucache:
          break;

      default:
          break;
    }
}

//----------------------------------------------------------------------

- (NSPoint) lowerLeft
{
    NSPoint ll;

    ll = NSMakePoint (10000, 10000);

    switch (operator)
    {
      case dps_arc:
      case dps_arcn:
          ll.x = MIN (ll.x, point1.x);
          ll.y = MIN (ll.y, point1.y);
          break;

      case dps_arct:
          ll.x = MIN (ll.x, point1.x);
          ll.y = MIN (ll.y, point1.y);
          ll.x = MIN (ll.x, point2.x);
          ll.y = MIN (ll.y, point2.y);
          break;

      case dps_closepath:
          break;

      case dps_curveto:
      case dps_rcurveto:
          ll.x = MIN (ll.x, point1.x);
          ll.y = MIN (ll.y, point1.y);
          ll.x = MIN (ll.x, point2.x);
          ll.y = MIN (ll.y, point2.y);
          ll.x = MIN (ll.x, point3.x);
          ll.y = MIN (ll.y, point3.y);
          break;

      case dps_lineto:
      case dps_moveto:
      case dps_rlineto:
      case dps_rmoveto:
          //NSLog (@"ll: (%f,%f), point: (%f,%f)", ll.x, ll.y, point1.x, point1.y);
          ll.x = MIN (ll.x, point1.x);
          ll.y = MIN (ll.y, point1.y);
          //NSLog (@"new ll: (%f,%f)", ll.x, ll.y);
          break;

      case dps_setbbox: // n/a?
          //NSLog (@"-- ll: (%f,%f), point1: (%f,%f), point2: (%f,%f)", ll.x, ll.y, point1.x, point1.y, point2.x, point2.y);
          ll.x = MIN (ll.x, point1.x);
          ll.y = MIN (ll.y, point1.y);
          ll.x = MIN (ll.x, point2.x);
          ll.y = MIN (ll.y, point2.y);
          //NSLog (@"-- new ll: (%f,%f)", ll.x, ll.y);
          break;

      case dps_ucache:
          break;

      default:
          break;
    }

    return ll;
}

//----------------------------------------------------------------------

- (NSPoint) upperRight
{
    NSPoint ur;

    ur = NSMakePoint (-10000, -10000);

    switch (operator)
    {
      case dps_arc:
      case dps_arcn:
          ur.x = MAX (ur.x, point1.x);
          ur.y = MAX (ur.y, point1.y);
          break;

      case dps_arct:
          ur.x = MAX (ur.x, point1.x);
          ur.y = MAX (ur.y, point1.y);
          ur.x = MAX (ur.x, point2.x);
          ur.y = MAX (ur.y, point2.y);
          break;

      case dps_closepath:
          break;

      case dps_curveto:
      case dps_rcurveto:
          ur.x = MAX (ur.x, point1.x);
          ur.y = MAX (ur.y, point1.y);
          ur.x = MAX (ur.x, point2.x);
          ur.y = MAX (ur.y, point2.y);
          ur.x = MAX (ur.x, point3.x);
          ur.y = MAX (ur.y, point3.y);
          break;

      case dps_lineto:
      case dps_moveto:
      case dps_rlineto:
      case dps_rmoveto:
          ur.x = MAX (ur.x, point1.x);
          ur.y = MAX (ur.y, point1.y);
          break;

      case dps_setbbox: // n/a?
          ur.x = MAX (ur.x, point1.x);
          ur.y = MAX (ur.y, point1.y);
          ur.x = MAX (ur.x, point2.x);
          ur.y = MAX (ur.y, point2.y);
          break;

      case dps_ucache:
          break;

      default:
          break;
    }

    return ur;
}

//----------------------------------------------------------------------

// Private
- (void) setPoint1:(NSPoint)aPoint
{
    point1 = aPoint;
}

//----------------------------------------------------------------------

- (void) setPoint2:(NSPoint)aPoint
{
    point2 = aPoint;
}

//----------------------------------------------------------------------

- (void) setPoint3:(NSPoint)aPoint
{
    point3 = aPoint;
}

//----------------------------------------------------------------------

- (void) setRadius:(float)newRadius
{
    radius = newRadius;
}

//----------------------------------------------------------------------

- (void) setAngle1:(float)anAngle
{
    angle1 = anAngle;
}

//----------------------------------------------------------------------

- (void) setAngle2:(float)anAngle
{
    angle2 = anAngle;
}

//----------------------------------------------------------------------

- (NSString *) description
{
    NSString *str;

    switch (operator)
    {
      case dps_arc:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: arc p1:%f,%f r:%f a1:%f a2:%f>",
                          point1.x, point1.y, radius, angle1, angle2];
          break;

      case dps_arcn:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: arcn p1:%f,%f r:%f a1:%f a2:%f>",
                          point1.x, point1.y, radius, angle1, angle2];
          break;

      case dps_arct:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: arct p1:%f,%f p2:%f,%f r:%f>",
                          point1.x, point1.y, point2.x, point2.y, radius];
          break;

      case dps_closepath:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: closepath>"];
          break;

      case dps_curveto:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: curveto p1:%f,%f p2:%f,%f p3:%f,%f>",
                          point1.x, point1.y, point2.x, point2.y, point3.x, point3.y];
          break;

      case dps_lineto:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: lineto p1:%f,%f>",
                          point1.x, point1.y];
          break;

      case dps_moveto:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: moveto p1:%f,%f>",
                          point1.x, point1.y];
          break;

      case dps_rcurveto:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: rcurveto p1:%f,%f p2:%f,%f p3:%f,%f>",
                          point1.x, point1.y, point2.x, point2.y, point3.x, point3.y];
          break;

      case dps_rlineto:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: rlineto p1:%f,%f>",
                          point1.x, point1.y];
          break;

      case dps_rmoveto:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: rmoveto p1:%f,%f>",
                          point1.x, point1.y];
          break;

      case dps_setbbox:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: setbbox p1:%f,%f p2:%f,%f>",
                          point1.x, point1.y, point2.x, point2.y];
          break;

      case dps_ucache:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: ucache>"];
          break;

      default:
          str = [NSString stringWithFormat:@"<SNUserPathOperation: UNKNOWN>"];
    }

    return str;
}

@end
