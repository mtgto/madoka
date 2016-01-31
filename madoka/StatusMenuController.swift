//
//  StatusMenuController.swift
//  madoka
//
//  Created by mtgto on 2016/01/30.
//  Copyright © 2016 mtgto. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSMenuDelegate {
    private let madokaService: MadokaService = MadokaService.sharedInstance
    
    private let colors: [NSColor] = [
        NSColor.blueColor(),
        NSColor.greenColor(),
        NSColor.yellowColor(),
        NSColor.orangeColor(),
        NSColor.redColor(),
        NSColor.purpleColor()
    ]
    
    private let images: [NSImage]
    
    override init() {
        self.images = colors.map { StatusMenuController.imageFromColor($0) }
    }
    
    func menuWillOpen(menu: NSMenu) {
        debugPrint("menuWillOpen")
        let viewController: StatisticsViewController = StatisticsViewController(nibName: "StatisticsViewController", bundle: NSBundle.mainBundle())!
        let current = NSDate()
        let applicationStatistics: [(name: String, duration: NSTimeInterval)] = madokaService.usedAppsSince(current.dateByAddingTimeInterval(-60 * 60), to: current)
        let totalDuration = applicationStatistics.reduce(0) { return $0 + $1.duration }
        viewController.updateData(applicationStatistics.enumerate().map { (legend: $0.element.name, color:self.colors[$0.index % self.colors.count], ratio: Float($0.element.duration / totalDuration)) })
        
        let menuItemArray = menu.itemArray
        let aboutMenuItem = menuItemArray[menuItemArray.count-2]
        let quitMenuItem = menuItemArray.last!
        menu.removeAllItems()
        
        for (i, statistic) in applicationStatistics.enumerate() {
            let title = String(format: "%@ (%.1f %%)", statistic.name, statistic.duration * 100 / totalDuration)
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.enabled = true
            menuItem.image = self.images[i % self.images.count]
            menu.addItem(menuItem)
        }
        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menuItem.view = viewController.view
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(aboutMenuItem)
        menu.addItem(quitMenuItem)
    }
    
    private static func imageFromColor(color: NSColor) -> NSImage {
        let width: CGFloat = 16
        let height: CGFloat = 16
        let image = NSImage(size: NSMakeSize(width, height))
        image.lockFocus()
        color.drawSwatchInRect(NSMakeRect(0, 0, width, height))
        image.unlockFocus()
        return image
    }
}
