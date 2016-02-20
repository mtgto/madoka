//
//  StatisticsView.swift
//  madoka
//
//  Created by mtgto on 2016/01/31.
//  Copyright © 2016 mtgto. All rights reserved.
//

import Cocoa

class StatisticsView: NSView {
    enum LegendType {
        case ApplicationName
        case ApplicationIcon

        static let values: [LegendType] = [.ApplicationName, .ApplicationIcon]
    }

    private var values: [(legend: String, color: NSColor, ratio: Float, icon: NSImage?)] = []
    private var legendType: LegendType = .ApplicationName

    /**
     * Minumum ratio to display the legend.
     */
    private let minimumRatio: Float = 0.1
    
    func updateValues(values: [(legend: String, color: NSColor, ratio: Float, icon: NSImage?)]) {
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

    override func viewDidMoveToWindow() {
        self.window?.becomeKeyWindow()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        let cy = CGRectGetHeight(self.bounds) / 2
        let cx = CGRectGetWidth(self.bounds) / 2
        let graphSizeRatio: CGFloat = 0.85
        let radius = min(cy * graphSizeRatio, cx * graphSizeRatio)
        let pi = M_PI
        var radian: CGFloat = CGFloat(pi / 2)
        let context = self.currentContext!
        let lineWidth = Double(CGRectGetWidth(self.bounds) / 4)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSCenterTextAlignment
        let lineAttributes = [NSForegroundColorAttributeName: NSColor.whiteColor(), NSFontAttributeName: NSFont.systemFontOfSize(12), NSParagraphStyleAttributeName: paragraphStyle]
        let truncationToken = CTLineCreateWithAttributedString(NSAttributedString(string: "…", attributes: lineAttributes))

        func drawString(string: String, posX: CGFloat, posY: CGFloat) {
            let attributedString = NSAttributedString(string: string, attributes: lineAttributes)
            let line = CTLineCreateWithAttributedString(attributedString)
            let truncatedLine = CTLineCreateTruncatedLine(line, lineWidth, .End, truncationToken)!
            CGContextSetTextPosition(context, posX, posY)
            CGContextSaveGState(context)
            CGContextSetShadow(context, CGSizeMake(1, 1), 5)
            CTLineDraw(truncatedLine, context)
            CGContextRestoreGState(context)
        }

        func drawImage(image: NSImage?, posX: CGFloat, posY: CGFloat, width: CGFloat, height: CGFloat) {
            if let legendImage = image {
                CGContextSaveGState(context)
                CGContextSetShadow(context, CGSizeMake(1, 1), 5)
                let imageRect: UnsafeMutablePointer<NSRect> = nil
                let originalSize = legendImage.size
                legendImage.size = NSMakeSize(width, height)
                let CGImage = legendImage.CGImageForProposedRect(imageRect, context: nil, hints: nil)
                CGContextDrawImage(context, CGRectMake(posX, posY, legendImage.size.width, legendImage.size.height), CGImage)
                CGContextRestoreGState(context)
                legendImage.size = originalSize
            }
        }

        for value in values.reverse() { // draw in descending order so that larger element can redraw smaller.
            let toRadian = CGFloat(radian + CGFloat(Double(value.ratio) * 2 * pi))
            let midRadian = (radian + toRadian) / 2
            let darkBrightness: CGFloat = max(0.0, value.color.brightnessComponent - 0.4)
            let gradientColors = [value.color.CGColor, NSColor(calibratedHue: value.color.hueComponent, saturation: value.color.saturationComponent, brightness: darkBrightness, alpha: value.color.alphaComponent).CGColor]
            let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), gradientColors, [1.0, 0.0])

            CGContextSaveGState(context)
            CGContextMoveToPoint(context, cx, cy)
            CGContextAddArc(context, cx, cy, radius, radian, toRadian, 0)
            radian = toRadian
            CGContextClip(context)
            CGContextDrawLinearGradient(context, gradient, CGPointMake(cx, cy - radius), CGPointMake(cx, cy + radius), CGGradientDrawingOptions.DrawsAfterEndLocation)
            CGContextRestoreGState(context)
            
            if value.ratio >= minimumRatio {
                let legendX = cx + cos(midRadian) * radius / 2
                let legendY = cy + sin(midRadian) * radius / 2

                switch legendType {
                case .ApplicationName:
                    drawString(value.legend, posX: legendX - 25, posY: legendY + 5)
                case .ApplicationIcon:
                    let imageLengthOfSide = CGFloat(min(32, 14 + value.ratio * 40))
                    drawImage(value.icon, posX: legendX - imageLengthOfSide / 2, posY: legendY, width: imageLengthOfSide, height: imageLengthOfSide)
                }
                drawString(String(format: "%.1f%%", value.ratio * 100), posX: legendX - 20, posY: legendY - 14)
            }
        }
    }

    override func mouseDown(theEvent: NSEvent) {
        let currentIndex = LegendType.values.indexOf(legendType)!
        legendType = LegendType.values[(currentIndex + 1) % LegendType.values.count]
    }
}
