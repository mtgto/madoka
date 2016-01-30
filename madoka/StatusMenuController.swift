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
    
    func menuWillOpen(menu: NSMenu) {
        print("menuWillOpen")
        let menuItemArray = menu.itemArray
        let aboutMenuItem = menuItemArray[menuItemArray.count-2]
        let quitMenuItem = menuItemArray.last!
        menu.removeAllItems()
        let current = NSDate()
        let applicationStatistics: [(name: String, duration: NSTimeInterval)] = madokaService.usedAppsSince(current.dateByAddingTimeInterval(-60 * 60), to: current)
        let totalDuration = applicationStatistics.reduce(0) { return $0 + $1.duration }
        for statistic in applicationStatistics {
            let title = String(format: "%@ (%.1f %%)", statistic.name, statistic.duration * 100 / totalDuration)
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.enabled = true
            menu.addItem(menuItem)
        }
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(aboutMenuItem)
        menu.addItem(quitMenuItem)
    }
}
