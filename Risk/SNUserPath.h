//
//  SNUserPath.h
//  Risk
//
//  Created by C.W. Betts on 4/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SNUserPath : NSObject <NSCoding>

- (NSBezierPath*)toBezierPath;

@end
