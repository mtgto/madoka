//
//  StatisticsView.swift
//  madoka
//
//  Created by mtgto on 2016/01/31.
//  Copyright © 2016 mtgto. All rights reserved.
//

import Cocoa

class StatisticsView: NSView {
    private var values: [(legend: String, color: NSColor, ratio: Float)] = []
    
    func updateValues(values: [(legend: String, color: NSColor, ratio: Float)]) {
        self.values = values
    }
    
    private var currentContext : CGContext? {
        get {
            if #available(OSX 10.10, *) {
                return NSGraphicsContext.currentContext()?.CGContext
            } else if let contextPointer = NSGraphicsContext.currentContext()?.graphicsPort {
                let context: CGContextRef = Unmanaged.fromOpaque(COpaquePointer(contextPointer)).takeUnretainedValue()
                return context
            }
            
            return nil
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        let cy = CGRectGetHeight(self.bounds) / 2
        let cx = CGRectGetWidth(self.bounds) / 2
        let radius = min(cy * 0.8, cx * 0.8)
        let pi = M_PI
        var radian: CGFloat = CGFloat(pi / 2)
        let context = self.currentContext!
        
        for value in values {
            CGContextSetFillColorWithColor(context, value.color.CGColor)
            CGContextMoveToPoint(context, cx, cy)
            let toRadian = CGFloat(radian - CGFloat(Double(value.ratio) * 2 * pi))
            let midRadian = (radian + toRadian) / 2
            CGContextAddArc(context, cx, cy, radius, radian, toRadian, 1)
            radian = toRadian
            CGContextClosePath(context)
            CGContextFillPath(context)
            
            if value.ratio >= 0.1 {
                let strx = cx + cos(midRadian) * radius * 0.5
                let stry = cy + sin(midRadian) * radius * 0.5
                let string = NSAttributedString(string: String(format: "%.1f%%", value.ratio * 100),
                    attributes: [NSForegroundColorAttributeName: NSColor.whiteColor(), NSFontAttributeName: NSFont.systemFontOfSize(14)])
                let line = CTLineCreateWithAttributedString(string)
                CGContextSetTextPosition(context, strx - 20, stry)
                CGContextSaveGState(context)
                CGContextSetShadow(context, CGSizeMake(1, 1), 5)
                CTLineDraw(line, context)
                CGContextRestoreGState(context)
            }
        }
    }
}
