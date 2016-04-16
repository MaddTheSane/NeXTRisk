//
//  SNUserPathOperation.m
//  Risk
//
//  Created by C.W. Betts on 4/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

#import "SNUserPathOperation.h"

typedef NS_ENUM(unsigned char, DPSUserPathOp) {
	dps_setbbox = 0,
	dps_moveto,
	dps_rmoveto,
	dps_lineto,
	dps_rlineto,
	dps_curveto,
	dps_rcurveto,
	dps_arc,
	dps_arcn,
	dps_arct,
	dps_closepath,
	dps_ucache
};

#define SNUserPathOperation_VERSION 1


@implementation SNUserPathOperation
{
	DPSUserPathOp operator;
	
	NSPoint point1;
	NSPoint point2;
	NSPoint point3;
	float radius;
	float angle1;
	float angle2;
}

+ (void) initialize
{
	if (self == [SNUserPathOperation class])
	{
		[self setVersion:SNUserPathOperation_VERSION];
	}
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSLog(@"Encoding SNUserPathOperation should not be needed!");
	});
	[aCoder encodeValueOfObjCType:@encode (DPSUserPathOp) at:&operator];
	[aCoder encodePoint:point1];
	[aCoder encodePoint:point2];
	[aCoder encodePoint:point3];
	[aCoder encodeValueOfObjCType:@encode (float) at:&radius];
	[aCoder encodeValueOfObjCType:@encode (float) at:&angle1];
	[aCoder encodeValueOfObjCType:@encode (float) at:&angle2];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init]) {
		[aDecoder decodeValueOfObjCType:@encode (DPSUserPathOp) at:&operator];
		point1 = [aDecoder decodePoint];
		point2 = [aDecoder decodePoint];
		point3 = [aDecoder decodePoint];
		[aDecoder decodeValueOfObjCType:@encode (float) at:&radius];
		[aDecoder decodeValueOfObjCType:@encode (float) at:&angle1];
		[aDecoder decodeValueOfObjCType:@encode (float) at:&angle2];
	}
	
	return self;
}

- (void)applyToBezierPath:(NSBezierPath*)bPath
{
	switch (operator) {
		case dps_arc:
			[bPath appendBezierPathWithArcWithCenter:point1 radius:radius startAngle:angle1 endAngle:angle2 clockwise:YES];
			break;
			
		case dps_arcn:
			[bPath appendBezierPathWithArcWithCenter:point1 radius:radius startAngle:angle1 endAngle:angle2 clockwise:NO];
			break;
			
		case dps_arct:
			[bPath appendBezierPathWithArcFromPoint:point1 toPoint:point2 radius:radius];
			break;
			
		case dps_closepath:
			[bPath closePath];
			break;
			
		case dps_curveto:
			[bPath curveToPoint:point1 controlPoint1:point2 controlPoint2:point3];
			break;
			
		case dps_lineto:
			[bPath lineToPoint:point1];
			break;
			
		case dps_moveto:
			[bPath moveToPoint:point1];
			break;
			
		case dps_ucache:
			//Do nothing
			break;
			
		case dps_rcurveto:
			[bPath relativeCurveToPoint:point1 controlPoint1:point2 controlPoint2:point3];
			break;
			
		case dps_rlineto:
			[bPath relativeLineToPoint:point1];
			break;
			
		case dps_rmoveto:
			[bPath relativeMoveToPoint:point1];
			break;
			
		case dps_setbbox:
			//[bPath set]
			break;
			
		default:
			NSLog(@"Unknown op: %i", operator);
			break;
	}
}

- (NSString *) description
{
	NSString *str;
	
	switch (operator) {
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
