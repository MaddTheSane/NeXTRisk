//
//  NSCoder+SNUnarchiveHelpers.h
//  Risk
//
//  Created by C.W. Betts on 6/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface NSCoder (SNUnarchiveHelpers)

- (float)decodeFloatWithoutKey;
- (DPSUserPathOp)decodeUserPathOpWithoutKey;

@end
