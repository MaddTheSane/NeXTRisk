//
//  LineView.swift
//  Risk
//
//  Created by C.W. Betts on 11/2/19.
//  Copyright © 2019 C.W. Betts. All rights reserved.
//

import Cocoa

/// Provide a simple view to show the width of a line, for use when
/// changing the border width.
@IBDesignable
class LineView: NSView {
    
    @IBInspectable @objc var lineWidth: CGFloat = 1 {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let boundsRect = self.bounds
        
        NSDrawWhiteBezel(boundsRect, boundsRect)
        let mp = boundsRect.midY
        let begin = boundsRect.origin.x + 2
        let end = boundsRect.origin.x + boundsRect.size.width - 2
        
        NSColor.black.set()
        let path = NSBezierPath()
        path.lineWidth = lineWidth
        path.move(to: NSPoint(x: begin, y: mp))
        path.line(to: NSPoint(x: end, y: mp))
        path.close()
        path.stroke()
    }
}
