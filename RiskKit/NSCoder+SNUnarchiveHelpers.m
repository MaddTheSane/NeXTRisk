//
//  NSCoder+SNUnarchiveHelpers.m
//  Risk
//
//  Created by C.W. Betts on 6/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

#import <RiskKit/NSCoder+SNUnarchiveHelpers.h>

@implementation NSCoder (SNUnarchiveHelpers)

- (float)decodeFloatWithoutKey
{
	float toRet;
	[self decodeValueOfObjCType:@encode (float) at:&toRet];
	return toRet;
}

- (DPSUserPathOp)decodeUserPathOpWithoutKey
{
	DPSUserPathOp toRet;
	[self decodeValueOfObjCType:@encode (DPSUserPathOp) at:&toRet];
	return toRet;
}

@end
