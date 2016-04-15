//
// $Id: LineView.h,v 1.1.1.1 1997/12/09 07:18:59 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <AppKit/AppKit.h>

@interface LineView : NSView
{
    float lineWidth;
}

- (void) setLineWidth:(float)lw;

- (void) drawRect:(NSRect)rect;

@end
