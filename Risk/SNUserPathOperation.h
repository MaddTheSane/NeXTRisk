//
//  SNUserPathOperation.h
//  Risk
//
//  Created by C.W. Betts on 4/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/// An SNUserPathOperation represents an user path operator and its
/// operands so that is can be stored in an array.
///
/// Please migrate over to <code>NSBezierPath</code>s instead!
@interface SNUserPathOperation : NSObject <NSCoding>

- (void)applyToBezierPath:(NSBezierPath*)bPath;

@end
