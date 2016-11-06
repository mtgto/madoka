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
        case applicationName
        case applicationIcon

        static let values: [LegendType] = [.applicationName, .applicationIcon]
    }

    private var values: [(legend: String, color: NSColor, ratio: Float, icon: NSImage?)] = []
    private var legendType: LegendType = .applicationName

    /**
     * Minumum ratio to display the legend.
     */
    private let minimumRatio: Float = 0.1
    
    func updateValues(_ values: [(legend: String, color: NSColor, ratio: Float, icon: NSImage?)]) {
        self.values = values
    }
    
    private var currentContext : CGContext? {
        get {
            if #available(OSX 10.10, *) {
                return NSGraphicsContext.current()?.cgContext
            } else if let contextPointer: UnsafeMutableRawPointer = NSGraphicsContext.current()?.graphicsPort {
                let context: CGContext = Unmanaged.fromOpaque(contextPointer).takeUnretainedValue()
                return context
            }
            
            return nil
        }
    }

    override func viewDidMoveToWindow() {
        self.window?.becomeKey()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let cy = self.bounds.height / 2
        let cx = self.bounds.width / 2
        let graphSizeRatio: CGFloat = 0.85
        let radius = min(cy * graphSizeRatio, cx * graphSizeRatio)
        let pi = M_PI
        var radian: CGFloat = CGFloat(pi / 2)
        let context = self.currentContext!
        let lineWidth = Double(self.bounds.width / 4)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSCenterTextAlignment
        let lineAttributes = [NSForegroundColorAttributeName: NSColor.white, NSFontAttributeName: NSFont.systemFont(ofSize: 12), NSParagraphStyleAttributeName: paragraphStyle]
        let truncationToken = CTLineCreateWithAttributedString(NSAttributedString(string: "…", attributes: lineAttributes))

        func drawString(_ string: String, posX: CGFloat, posY: CGFloat) {
            let attributedString = NSAttributedString(string: string, attributes: lineAttributes)
            let line = CTLineCreateWithAttributedString(attributedString)
            let truncatedLine = CTLineCreateTruncatedLine(line, lineWidth, .end, truncationToken)!
            context.textPosition = CGPoint(x: posX, y: posY)
            context.saveGState()
            context.setShadow(offset: CGSize(width: 1, height: 1), blur: 5)
            CTLineDraw(truncatedLine, context)
            context.restoreGState()
        }

        func drawImage(_ image: NSImage?, posX: CGFloat, posY: CGFloat, width: CGFloat, height: CGFloat) {
            if let legendImage = image {
                context.saveGState()
                context.setShadow(offset: CGSize(width: 1, height: 1), blur: 5)
                let imageRect: UnsafeMutablePointer<NSRect>? = nil
                let originalSize = legendImage.size
                legendImage.size = NSMakeSize(width, height)
                let CGImage = legendImage.cgImage(forProposedRect: imageRect, context: nil, hints: nil)
                context.draw(CGImage!, in: CGRect(x: posX, y: posY, width: legendImage.size.width, height: legendImage.size.height))
                context.restoreGState()
                legendImage.size = originalSize
            }
        }

        for value in values.reversed() { // draw in descending order so that larger element can redraw smaller.
            let toRadian = CGFloat(radian + CGFloat(Double(value.ratio) * 2 * pi))
            let midRadian = (radian + toRadian) / 2
            let darkBrightness: CGFloat = max(0.0, value.color.brightnessComponent - 0.4)
            let gradientColors = [value.color.cgColor, NSColor(calibratedHue: value.color.hueComponent, saturation: value.color.saturationComponent, brightness: darkBrightness, alpha: value.color.alphaComponent).cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: [1.0, 0.0])

            context.saveGState()
            context.move(to: CGPoint(x: cx, y: cy))
            context.addArc(center: CGPoint(x: cx, y: cy), radius: radius, startAngle: radian, endAngle: toRadian, clockwise: false)
            radian = toRadian
            context.clip()
            context.drawLinearGradient(gradient!, start: CGPoint(x: cx, y: cy - radius), end: CGPoint(x: cx, y: cy + radius), options: CGGradientDrawingOptions.drawsAfterEndLocation)
            context.restoreGState()
            
            if value.ratio >= minimumRatio {
                let legendX = cx + cos(midRadian) * radius / 2
                let legendY = cy + sin(midRadian) * radius / 2

                switch legendType {
                case .applicationName:
                    drawString(value.legend, posX: legendX - 25, posY: legendY + 5)
                case .applicationIcon:
                    let imageLengthOfSide = CGFloat(min(32, 14 + value.ratio * 40))
                    drawImage(value.icon, posX: legendX - imageLengthOfSide / 2, posY: legendY, width: imageLengthOfSide, height: imageLengthOfSide)
                }
                drawString(String(format: "%.1f%%", value.ratio * 100), posX: legendX - 20, posY: legendY - 14)
            }
        }
    }

    override func mouseDown(with theEvent: NSEvent) {
        let currentIndex = LegendType.values.index(of: legendType)!
        legendType = LegendType.values[(currentIndex + 1) % LegendType.values.count]
    }
}
