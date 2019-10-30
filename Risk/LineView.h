//
// $Id: LineView.h,v 1.1.1.1 1997/12/09 07:18:59 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
/// Provide a simple view to show the width of a line, for use when
/// changing the border width.
@interface LineView : NSView

@property (nonatomic) IBInspectable CGFloat lineWidth;

- (void) drawRect:(NSRect)rect;

@end
