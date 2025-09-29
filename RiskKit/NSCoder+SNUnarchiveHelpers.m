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
	if (@available(macOS 10.13, *)) {
		[self decodeValueOfObjCType:@encode (float) at:&toRet size:sizeof(toRet)];
	} else {
		[self decodeValueOfObjCType:@encode (float) at:&toRet];
	}
	return toRet;
}

- (DPSUserPathOp)decodeUserPathOpWithoutKey
{
	DPSUserPathOp toRet;
	if (@available(macOS 10.13, *)) {
		[self decodeValueOfObjCType:@encode (DPSUserPathOp) at:&toRet size:sizeof(toRet)];
	} else {
		[self decodeValueOfObjCType:@encode (DPSUserPathOp) at:&toRet];
	}
	return toRet;
}

@end
