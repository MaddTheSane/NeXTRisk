//
//  SNUserPath.h
//  Risk
//
//  Created by C.W. Betts on 4/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/// An SNUserPath provides an interface for creating user paths and
/// using them for drawing or hit detection.  The bounding box
/// calculations are incomplete, but work with straight lines.
///
/// The MiscKit provides a more complete implementation.  Under Rhapsody
/// this will probably move towards using the <code>NSBezierPath</code> path.
///
/// Note that this means curved paths could be easily supported to
/// provide better looking maps, but RiskUtil.app would need to be
/// able to support them.
@interface SNUserPath : NSObject <NSCoding>

- (nonnull NSBezierPath*)toBezierPath;

@end
