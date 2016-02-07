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

    enum IntervalIndex: Int {
        case OneHour = 0
        case FourHours = 1
        case EightHours = 2
        case Today = 3

        func startDateFrom(current: NSDate) -> NSDate {
            switch self {
            case .OneHour:
                return current.dateByAddingTimeInterval(-60 * 60)
            case .FourHours:
                return current.dateByAddingTimeInterval(-4 * 60 * 60)
            case .EightHours:
                return current.dateByAddingTimeInterval(-8 * 60 * 60)
            case .Today:
                let calendar = NSCalendar.currentCalendar()
                return calendar.dateFromComponents(calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: current))!
            }
        }
    }

    private var intervalIndex: IntervalIndex = .OneHour

    /**
     * Minimum duration to show in menu (inclusive).
     */
    private let minimumDuration: NSTimeInterval = 60

    @IBOutlet weak var oneHourMenuItem: NSMenuItem!

    @IBOutlet weak var fourHoursMenuItem: NSMenuItem!

    @IBOutlet weak var eightHoursMenuItem: NSMenuItem!

    @IBOutlet weak var todayMenuItem: NSMenuItem!

    override init() {
        self.intervalIndex = IntervalIndex(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(Constants.KeyPreferenceIntervalIndex))!
    }
    
    @IBAction func menuSelected(sender: AnyObject) {
        oneHourMenuItem.state = NSOffState
        fourHoursMenuItem.state = NSOffState
        eightHoursMenuItem.state = NSOffState
        todayMenuItem.state = NSOffState

        if sender as! NSObject == oneHourMenuItem {
            oneHourMenuItem.state = NSOnState
            intervalIndex = .OneHour
        } else if sender as! NSObject == fourHoursMenuItem {
            fourHoursMenuItem.state = NSOnState
            intervalIndex = .FourHours
        } else if sender as! NSObject == eightHoursMenuItem {
            eightHoursMenuItem.state = NSOnState
            intervalIndex = .EightHours
        } else if sender as! NSObject == todayMenuItem {
            todayMenuItem.state = NSOnState
            intervalIndex = .Today
        }
        NSUserDefaults.standardUserDefaults().setInteger(intervalIndex.rawValue, forKey: Constants.KeyPreferenceIntervalIndex)
    }

    func menuWillOpen(menu: NSMenu) {
        let current = NSDate()
        let applicationStatistics: [(name: String, icon: NSImage?, duration: NSTimeInterval)] = madokaService.usedAppsSince(intervalIndex.startDateFrom(current), to: current)
            .filter { $0.duration >= minimumDuration }
        let totalDuration = applicationStatistics.reduce(0) { return $0 + $1.duration }
        
        for _ in 0..<menu.itemArray.count-4 {
            menu.removeItemAtIndex(0)
        }

        for (i, statistic) in applicationStatistics.enumerate() {
            let title = String(format: "%@ (%.1f %%)", statistic.name, statistic.duration * 100 / totalDuration)
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.enabled = true
            if let sourceIcon = statistic.icon {
                menuItem.image = StatusMenuController.resizedIconImage(sourceIcon)
            }
            menu.insertItem(menuItem, atIndex: i)
            let subtitle = String(format: "%02d:%02d", Int(statistic.duration) / 60, Int(statistic.duration) % 60)
            let subMenu = NSMenu(title: "")
            subMenu.addItem(NSMenuItem(title: subtitle, action: nil, keyEquivalent: ""))
            menuItem.submenu = subMenu
        }
        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        if applicationStatistics.isEmpty {
            menuItem.title = NSLocalizedString("No app is used one minute or more", comment: "No app is used one minute or more")
        } else {
            let viewController: StatisticsViewController = StatisticsViewController(nibName: "StatisticsViewController", bundle: NSBundle.mainBundle())!
            viewController.updateData(applicationStatistics.enumerate().map { (legend: $0.element.name, color:self.colors[$0.index % self.colors.count], ratio: Float($0.element.duration / totalDuration), icon: $0.element.icon) })
            menuItem.view = viewController.view
        }
        menu.insertItem(menuItem, atIndex: applicationStatistics.count)
        self.setIntervalMenuState()
    }

    private func setIntervalMenuState() {
        switch self.intervalIndex {
        case .OneHour:
            oneHourMenuItem.state = NSOnState
        case .FourHours:
            fourHoursMenuItem.state = NSOnState
        case .EightHours:
            eightHoursMenuItem.state = NSOnState
        case .Today:
            todayMenuItem.state = NSOnState
        }
    }

    private static func resizedIconImage(source: NSImage) -> NSImage {
        let width: CGFloat = 16
        let height: CGFloat = 16
        let newSize = NSMakeSize(width, height)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        NSGraphicsContext.currentContext()?.imageInterpolation = .High
        source.drawInRect(NSMakeRect(0, 0, width, height), fromRect: NSMakeRect(0, 0, source.size.width, source.size.height), operation: .CompositeCopy, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
