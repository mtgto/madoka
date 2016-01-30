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
    static let sharedInstance = MadokaService()
    
    struct UsingApplication {
        let appId: String
        let since: NSDate
    }
    
    private var usingApp: UsingApplication? = nil
    
    private var localizedNames: [String: String] = [String: String]()
    
    /**
     * Tuple of (Application bundle's identifier, since (TimeIntervalSinceReferenceDate), duration)
     *
     * It contains only today's statistics.
     * If you need to use older statistics, use realm.
     */
    private var statistics: Array<(applicationIdentifier: String, since: NSTimeInterval, duration: NSTimeInterval)> = []
    
    override init() {
        super.init()
        let realm = try! Realm()
        self.localizedNames = Array<LocalizedName>(realm.objects(LocalizedName))
            .reduce([String: String]()) { (var dict, element: LocalizedName) in
                dict[element.applicationIdentifier] = element.localizedName; return dict
            }
        self.statistics = Array<Statistic>(realm.objects(Statistic))
            .map {
                (applicationIdentifier: $0.applicationIdentifier, since: $0.start.timeIntervalSinceReferenceDate, $0.end.timeIntervalSinceDate($0.start))
            }
        //timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(10.0), target: self, selector: Selector("onUpdate:"), userInfo: nil, repeats: true)
    }
    
    /**
     * Be invoked from NSNotifacionCenter when active application has changed.
     */
    func didActivateApplication(notification: NSNotification?) {
        if let userInfo: [String: AnyObject] = notification?.userInfo as? [String: AnyObject] {
            if let application: NSRunningApplication = userInfo[NSWorkspaceApplicationKey] as? NSRunningApplication {
                if let applicationIdentifier = application.bundleIdentifier {
                    if let localizedName: String = application.localizedName {
                        debugPrint("localizedName: " + localizedName)
                        let current = NSDate()
                        if let lastApplication = self.usingApp {
                            let duration: NSTimeInterval = current.timeIntervalSinceDate(lastApplication.since)
                            updateUsingApp(lastApplication, localizedName: localizedName, duration: duration)
                        }
                        self.usingApp = UsingApplication(appId: applicationIdentifier, since: current)
                    }
                }
            }
        }
    }
    
    func usedAppsSince(since: NSDate, to: NSDate) -> [(name: String, duration: NSTimeInterval)] {
        let sinceReference = since.timeIntervalSinceReferenceDate
        let toReference = to.timeIntervalSinceReferenceDate
        return self.statistics.reduce([String: NSTimeInterval]()) { (var dict: [String: NSTimeInterval], stat) in
            let duration = min(stat.since + stat.duration, toReference) - max(sinceReference, stat.since)
            if duration > 0 {
                if let lastDuration: NSTimeInterval = dict[stat.applicationIdentifier] {
                    dict[stat.applicationIdentifier] = duration + lastDuration
                } else {
                    dict[stat.applicationIdentifier] = duration
                }
            }
            return dict
        }.sort {
            return $0.1 < $1.1
        }.map {
            return (name: self.localizedNames[$0.0]!, duration: $0.1)
        }
    }
    
    private func updateUsingApp(lastUsingApp: UsingApplication, localizedName: String, duration: NSTimeInterval) {
        let realm = try! Realm()
        try! realm.write {
            let statistic: Statistic = Statistic(start: lastUsingApp.since, end: lastUsingApp.since.dateByAddingTimeInterval(duration), applicationIdentifier: lastUsingApp.appId)
            realm.add(statistic)
            if (self.localizedNames[lastUsingApp.appId]) == nil {
                realm.add(LocalizedName(applicationIdentifier: lastUsingApp.appId, localizedName: localizedName))
                self.localizedNames[lastUsingApp.appId] = localizedName
            }
        }
        self.statistics.append(applicationIdentifier: lastUsingApp.appId, since: lastUsingApp.since.timeIntervalSinceReferenceDate, duration: duration)
    }
}
