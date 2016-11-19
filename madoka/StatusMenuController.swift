//
//  StatusMenuController.swift
//  madoka
//
//  Created by mtgto on 2016/01/30.
//  Copyright © 2016 mtgto. All rights reserved.
//

import Cocoa
import ServiceManagement

class StatusMenuController: NSObject, NSMenuDelegate {
    private let madokaService: MadokaService = MadokaService.sharedInstance
    
    private let colors: [NSColor] = [
        NSColor.blue,
        NSColor.green,
        NSColor.yellow,
        NSColor.orange,
        NSColor.red,
        NSColor.purple
    ]

    enum IntervalIndex: Int {
        case oneHour = 0
        case fourHours = 1
        case eightHours = 2
        case today = 3

        func startDateFrom(_ current: Date) -> Date {
            switch self {
            case .oneHour:
                return current.addingTimeInterval(-60 * 60)
            case .fourHours:
                return current.addingTimeInterval(-4 * 60 * 60)
            case .eightHours:
                return current.addingTimeInterval(-8 * 60 * 60)
            case .today:
                let calendar = Calendar.current
                return calendar.date(from: (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: current))!
            }
        }
    }

    private var intervalIndex: IntervalIndex = .oneHour

    /**
     * Minimum duration to show in menu (inclusive).
     */
    private let minimumDuration: TimeInterval = 60

    @IBOutlet weak var oneHourMenuItem: NSMenuItem!

    @IBOutlet weak var fourHoursMenuItem: NSMenuItem!

    @IBOutlet weak var eightHoursMenuItem: NSMenuItem!

    @IBOutlet weak var todayMenuItem: NSMenuItem!

    @IBOutlet weak var launchAtLoginMenuItem: NSMenuItem!
    
    override init() {
        self.intervalIndex = IntervalIndex(rawValue: UserDefaults.standard.integer(forKey: Constants.KeyPreferenceIntervalIndex))!
    }
    
    @IBAction func toggleLaunchAtLogin(_ sender: Any) {
        if sender as! NSMenuItem == self.launchAtLoginMenuItem {
            let status = !UserDefaults.standard.bool(forKey: Constants.KeyPreferenceLaunchAtLogin)
            if SMLoginItemSetEnabled(Constants.HelperBundleIdentifier as CFString, status) {
                UserDefaults.standard.set(status, forKey: Constants.KeyPreferenceLaunchAtLogin)
                self.launchAtLoginMenuItem.state = status ? NSOnState : NSOffState
            } else {
                let alert = NSAlert()
                alert.messageText = NSLocalizedString("Error", comment: "Error")
                alert.informativeText = NSLocalizedString("Failed to set launch item at login.", comment: "Failed to set launch item at login.")
                alert.runModal()
            }
        }
    }

    @IBAction func menuSelected(_ sender: AnyObject) {
        oneHourMenuItem.state = NSOffState
        fourHoursMenuItem.state = NSOffState
        eightHoursMenuItem.state = NSOffState
        todayMenuItem.state = NSOffState

        if sender as! NSObject == oneHourMenuItem {
            oneHourMenuItem.state = NSOnState
            intervalIndex = .oneHour
        } else if sender as! NSObject == fourHoursMenuItem {
            fourHoursMenuItem.state = NSOnState
            intervalIndex = .fourHours
        } else if sender as! NSObject == eightHoursMenuItem {
            eightHoursMenuItem.state = NSOnState
            intervalIndex = .eightHours
        } else if sender as! NSObject == todayMenuItem {
            todayMenuItem.state = NSOnState
            intervalIndex = .today
        }
        UserDefaults.standard.set(intervalIndex.rawValue, forKey: Constants.KeyPreferenceIntervalIndex)
    }

    func menuWillOpen(_ menu: NSMenu) {
        let current = Date()
        let applicationStatistics: [(name: String, icon: NSImage?, duration: TimeInterval)] = self.madokaService.usedAppsSince(intervalIndex.startDateFrom(current), to: current)
            .filter { $0.duration >= minimumDuration }
        let totalDuration = applicationStatistics.reduce(0) { return $0 + $1.duration }
        
        for _ in 0..<menu.items.count-4 {
            menu.removeItem(at: 0)
        }

        for (i, statistic) in applicationStatistics.enumerated() {
            let title = String(format: "%@ (%.1f %%)", statistic.name, statistic.duration * 100 / totalDuration)
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.isEnabled = true
            if let sourceIcon = statistic.icon {
                menuItem.image = StatusMenuController.resizedIconImage(sourceIcon)
            }
            menu.insertItem(menuItem, at: i)
            let subtitle = String(format: "%02d:%02d", Int(statistic.duration) / 60, Int(statistic.duration) % 60)
            let subMenu = NSMenu(title: "")
            subMenu.addItem(NSMenuItem(title: subtitle, action: nil, keyEquivalent: ""))
            menuItem.submenu = subMenu
        }
        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        if applicationStatistics.isEmpty {
            menuItem.title = NSLocalizedString("No app is used one minute or more", comment: "No app is used one minute or more")
        } else {
            let viewController: StatisticsViewController = StatisticsViewController(nibName: "StatisticsViewController", bundle: Bundle.main)!
            viewController.updateData(applicationStatistics.enumerated().map { (legend: $0.1.name, color:self.colors[$0.0 % self.colors.count], ratio: Float($0.1.duration / totalDuration), icon: $0.1.icon) })
            menuItem.view = viewController.view
        }
        menu.insertItem(menuItem, at: applicationStatistics.count)
        self.setIntervalMenuState()
        self.launchAtLoginMenuItem.state = UserDefaults.standard.bool(forKey: Constants.KeyPreferenceLaunchAtLogin) ? NSOnState : NSOffState
    }

    private func setIntervalMenuState() {
        switch self.intervalIndex {
        case .oneHour:
            oneHourMenuItem.state = NSOnState
        case .fourHours:
            fourHoursMenuItem.state = NSOnState
        case .eightHours:
            eightHoursMenuItem.state = NSOnState
        case .today:
            todayMenuItem.state = NSOnState
        }
    }

    private static func resizedIconImage(_ source: NSImage) -> NSImage {
        let width: CGFloat = 16
        let height: CGFloat = 16
        let newSize = NSMakeSize(width, height)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        NSGraphicsContext.current()?.imageInterpolation = .high
        source.draw(in: NSMakeRect(0, 0, width, height), from: NSMakeRect(0, 0, source.size.width, source.size.height), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
