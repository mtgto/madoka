//
//  MadokaService.swift
//  madoka
//
//  Created by mtgto on 2015/07/22.
//  Copyright (c) 2015 mtgto. All rights reserved.
//

import Cocoa
import RealmSwift

class MadokaService: NSObject {
    private typealias StatisticTuple = (applicationIdentifier: String, since: TimeInterval, duration: TimeInterval)

    static let sharedInstance = MadokaService()
    
    struct UsingApplication {
        let applicationIdentifier: String
        let localizedName: String
        let since: Date
    }
    
    private var usingApp: UsingApplication? = nil
    
    private var localizedNames: [String: String] = [String: String]()

    private let ignoreApplicationIdentifiers: Set<String> = ["com.apple.loginwindow", "com.apple.ScreenSaver.Engine", "com.apple.SecurityAgent"]
    
    /**
     * Tuple of (Application bundle's identifier, since (TimeIntervalSinceReferenceDate), duration)
     *
     * It contains only today's statistics.
     * If you need to use older statistics, use realm.
     */
    private var statistics: [StatisticTuple] = []

    override init() {
        super.init()
        let realm = try! Realm()
        var localizedNames: [String: String] = [:]
        realm.objects(LocalizedName.self)
            .forEach { (element: LocalizedName) in
                localizedNames[element.applicationIdentifier] = element.localizedName
            }
        self.localizedNames = localizedNames
        self.statistics = Array<Statistic>(realm.objects(Statistic.self).filter("end >= %@", Date(timeIntervalSinceNow: -24 * 60 * 60)))
            .map {
                (applicationIdentifier: $0.applicationIdentifier, since: $0.start.timeIntervalSinceReferenceDate, $0.end.timeIntervalSince($0.start as Date))
            }
        if let application: NSRunningApplication = NSWorkspace.shared.frontmostApplication {
            if let applicationIdentfier = application.bundleIdentifier {
                if let localizedName = application.localizedName {
                    self.localizedNames[applicationIdentfier] = localizedName
                    self.usingApp = UsingApplication(applicationIdentifier: applicationIdentfier, localizedName: localizedName, since: Date())
                }
            }
        }
    }
    
    /**
     * Be invoked from NSNotifacionCenter when active application has changed.
     */
    @objc func didActivateApplication(_ notification: Notification?) {
        if let userInfo: [String: AnyObject] = notification?.userInfo as? [String: AnyObject] {
            if let application: NSRunningApplication = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                self.applicationChanged(application)
            }
        }
    }

    /**
     * Be invoked from NSNotifacionCenter when computer is going to sleep.
     */
    @objc func willSleep(_ notification: Notification?) {
        applicationChanged(nil)
    }

    /**
     * Be invoked from NSNotifacionCenter when computer wake.
     */
    @objc func didWake(_ notification: Notification?) {
        if let application = NSWorkspace.shared.frontmostApplication {
            applicationChanged(application)
        }
    }

    /**
     * Be invoked when madoka will terminate.
     */
    func willTerminate() {
        applicationChanged(nil)
    }

    /**
     * Be invoked from NSNotifacionCenter when user switched out.
     */
    @objc func sessionDidResignActive(_ notification: Notification?) {
        applicationChanged(nil)
    }

    /**
     * Be invoked from NSNotifacionCenter when user switched in.
     */
    @objc func sessionDidBecomeActive(_ notification: Notification?) {
        if let application = NSWorkspace.shared.frontmostApplication {
            applicationChanged(application)
        }
    }

    /**
     * Notify when current application changed.
     */
    func applicationChanged(_ application: NSRunningApplication?) {
        let current = Date()
        if let lastApplication = self.usingApp {
            let duration: TimeInterval = current.timeIntervalSince(lastApplication.since)
            self.updateUsingApp(lastApplication, duration: duration)
        }
        if let application = application {
            if let applicationIdentifier = application.bundleIdentifier {
                if let localizedName: String = application.localizedName {
                    debugPrint("localizedName: ", localizedName, applicationIdentifier)
                    self.localizedNames[applicationIdentifier] = localizedName
                    self.usingApp = UsingApplication(applicationIdentifier: applicationIdentifier, localizedName: localizedName, since: current)
                }
            }
        } else {
            self.usingApp = nil
        }
    }

    func usedAppsSince(_ since: Date, to: Date) -> [(name: String, icon: NSImage?, duration: TimeInterval)] {
        let sinceReference = since.timeIntervalSinceReferenceDate
        let toReference = to.timeIntervalSinceReferenceDate
        var usedDict: [String: TimeInterval] = [:]
        self.currentStatistics().forEach { (stat) in
            let duration = min(stat.since + stat.duration, toReference) - max(sinceReference, stat.since)
            if duration > 0 && !self.ignoreApplicationIdentifiers.contains(stat.applicationIdentifier) {
                if let lastDuration: TimeInterval = usedDict[stat.applicationIdentifier] {
                    usedDict[stat.applicationIdentifier] = duration + lastDuration
                } else {
                    usedDict[stat.applicationIdentifier] = duration
                }
            }
        }
        return usedDict.sorted {
            return $0.1 > $1.1
        }.map {
            return (name: self.localizedNames[$0.0]!, icon: MadokaService.applicationIconWithBundleIdentifier($0.0), duration: $0.1)
        }
    }

    /**
     * Statistics with current application.
     */
    private func currentStatistics() -> [StatisticTuple] {
        if let usingApplication = self.usingApp {
            return self.statistics + [(applicationIdentifier: usingApplication.applicationIdentifier, since: usingApplication.since.timeIntervalSinceReferenceDate, duration: -usingApplication.since.timeIntervalSinceNow)]
        } else {
            return self.statistics
        }
    }
    
    private func updateUsingApp(_ lastUsingApp: UsingApplication, duration: TimeInterval) {
        let realm = try! Realm()
        let statistic: Statistic = Statistic()
        statistic.start = lastUsingApp.since
        statistic.end = lastUsingApp.since.addingTimeInterval(duration)
        statistic.applicationIdentifier = lastUsingApp.applicationIdentifier
        let localizedName: LocalizedName
        if let localized = realm.object(ofType: LocalizedName.self, forPrimaryKey: lastUsingApp.localizedName) {
            localizedName = localized
        } else {
            localizedName = LocalizedName()
            localizedName.applicationIdentifier = lastUsingApp.applicationIdentifier
            localizedName.localizedName = lastUsingApp.localizedName
        }
        try! realm.write {
            realm.add(statistic)
            realm.add(localizedName)
        }
        self.statistics.append((applicationIdentifier: lastUsingApp.applicationIdentifier, since: lastUsingApp.since.timeIntervalSinceReferenceDate, duration: duration))
    }

    private class func applicationIconWithBundleIdentifier(_ identifier: String) -> NSImage? {
        guard let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: identifier) else {
            return nil
        }
        debugPrint("path: \(path)")
        return NSWorkspace.shared.icon(forFile: path)
    }
}
