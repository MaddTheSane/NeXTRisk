//
//  SNUserPath.m
//  Risk
//
//  Created by C.W. Betts on 4/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

#import "SNUserPath.h"
#import "SNUserPathOperation.h"

#define SNUserPath_VERSION 1


@implementation SNUserPath
{
	NSMutableArray<SNUserPathOperation*> *operations;
}
+ (void) initialize
{
	if (self == [SNUserPath class])
	{
		[self setVersion:SNUserPath_VERSION];
	}
}

//----------------------------------------------------------------------

- (instancetype)init
{
	if ([super init] == nil)
		return nil;
	
	operations = [[NSMutableArray alloc] init];
	return self;
}

- (void)dealloc
{
	[operations release];
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:operations];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init]) {
		
		operations = [[aDecoder decodeObject] retain];
		
	}
	return self;
}

- (NSBezierPath*)toBezierPath
{
	NSBezierPath *path = [NSBezierPath bezierPath];
	for (SNUserPathOperation *op in operations) {
		[op applyToBezierPath:path];
	}
	
	return path;
}

@end
