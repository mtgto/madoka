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

    private var intervalIndex: Int = 0
    
    @IBOutlet weak var oneHourMenuItem: NSMenuItem!

    @IBOutlet weak var fourHoursMenuItem: NSMenuItem!

    @IBOutlet weak var eightHoursMenuItem: NSMenuItem!

    @IBOutlet weak var todayMenuItem: NSMenuItem!

    override init() {
        self.images = colors.map { StatusMenuController.imageFromColor($0) }
        self.intervalIndex = NSUserDefaults.standardUserDefaults().integerForKey(Constants.KeyPreferenceIntervalIndex)
    }
    
    @IBAction func menuSelected(sender: AnyObject) {
        oneHourMenuItem.state = NSOffState
        fourHoursMenuItem.state = NSOffState
        eightHoursMenuItem.state = NSOffState
        todayMenuItem.state = NSOffState

        if sender as! NSObject == oneHourMenuItem {
            oneHourMenuItem.state = NSOnState
            intervalIndex = 0
        } else if sender as! NSObject == fourHoursMenuItem {
            fourHoursMenuItem.state = NSOnState
            intervalIndex = 1
        } else if sender as! NSObject == eightHoursMenuItem {
            eightHoursMenuItem.state = NSOnState
            intervalIndex = 2
        } else if sender as! NSObject == todayMenuItem {
            todayMenuItem.state = NSOnState
            intervalIndex = 3
        }
        NSUserDefaults.standardUserDefaults().setInteger(intervalIndex, forKey: Constants.KeyPreferenceIntervalIndex)
    }

    func menuWillOpen(menu: NSMenu) {
        let viewController: StatisticsViewController = StatisticsViewController(nibName: "StatisticsViewController", bundle: NSBundle.mainBundle())!
        let current = NSDate()
        let applicationStatistics: [(name: String, duration: NSTimeInterval)] = madokaService.usedAppsSince(Constants.startDateFromIntervalIndex(intervalIndex, current)!, to: current)
        let totalDuration = applicationStatistics.reduce(0) { return $0 + $1.duration }
        viewController.updateData(applicationStatistics.enumerate().map { (legend: $0.element.name, color:self.colors[$0.index % self.colors.count], ratio: Float($0.element.duration / totalDuration)) })
        
        let menuItemCount = menu.itemArray.count
        for _ in 0..<menuItemCount-4 {
            menu.removeItemAtIndex(0)
        }

        for (i, statistic) in applicationStatistics.enumerate() {
            let title = String(format: "%@ (%.1f %%)", statistic.name, statistic.duration * 100 / totalDuration)
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.enabled = true
            menuItem.image = self.images[i % self.images.count]
            menu.insertItem(menuItem, atIndex: i)
            let subtitle = String(format: "%02d:%02d", Int(statistic.duration) / 60, Int(statistic.duration) % 60)
            let subMenu = NSMenu(title: "")
            subMenu.addItem(NSMenuItem(title: subtitle, action: nil, keyEquivalent: ""))
            menuItem.submenu = subMenu
        }
        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menuItem.view = viewController.view
        menu.insertItem(menuItem, atIndex: applicationStatistics.count)
        self.setIntervalMenuState()
    }

    private func setIntervalMenuState() {
        switch self.intervalIndex {
        case 0:
            oneHourMenuItem.state = NSOnState
        case 1:
            fourHoursMenuItem.state = NSOnState
        case 2:
            eightHoursMenuItem.state = NSOnState
        case 3:
            todayMenuItem.state = NSOnState
        default:
            break
        }
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
