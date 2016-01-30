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
        let localized: String?
        let since: NSDate
    }
    
    private var timer: NSTimer!
    
    private var usingApp: UsingApplication?
    
    private var apps: Dictionary<String, App> = try! Array<App>(Realm().objects(App)).reduce([String: App]()) {(var dict, element) in dict[element.appIdentifier] = element; return dict}
    
    /**
     * Tuple of (Application bundle's identifier, since (TimeIntervalSinceReferenceDate), duration)
     */
    private var stats: Array<(applicationIdentifier: String, since: NSTimeInterval, duration: NSTimeInterval)> = []
    
    override init() {
        super.init()
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
                        debugPrint("licalizedName: " + localizedName)
                        let current = NSDate()
                        // localizedがあればid -> localized辞書の更新
                        if let lastApplication = self.usingApp {
                            let duration: NSTimeInterval = current.timeIntervalSinceDate(lastApplication.since)
                            //updateUsingApp(lastApplication, duration: interval)
                            stats.append(applicationIdentifier: lastApplication.appId, since: lastApplication.since.timeIntervalSinceReferenceDate, duration: duration)
                        }
                        self.usingApp = UsingApplication(appId: applicationIdentifier, localized: localizedName, since: current)
                    }
                }
            }
        }
    }
    
    func usedAppsSince(since: NSDate, to: NSDate) -> [(name: String, duration: NSTimeInterval)] {
        let sinceReference = since.timeIntervalSinceReferenceDate
        let toReference = to.timeIntervalSinceReferenceDate
        return stats.reduce([String: NSTimeInterval]()) { (var dict: [String: NSTimeInterval], stat) in
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
            return (name: apps[$0.0]!.localized!, duration: $0.1)
        }
//        return stats.filter {
//            let duration = min($0.since + $0.duration, toReference) - max(sinceReference, $0.since)
//            return duration > 0
//        }.map {
//            let duration = min($0.since + $0.duration, toReference) - max(sinceReference, $0.since)
//            return (name: $0.applicationIdentifier, duration: duration)
//        }
    }
    
    func onUpdate(timer: NSTimer) {
        let workspace = NSWorkspace.sharedWorkspace()
        let current = NSDate()
        if let app = workspace.frontmostApplication {
            if let bundleIdentifier = app.bundleIdentifier {
                if let lastUsingApp = usingApp {
                    if lastUsingApp.appId != bundleIdentifier {
                        updateUsingApp(lastUsingApp, duration: lastUsingApp.since.timeIntervalSinceDate(current))
                    }
                }
                if usingApp?.appId != bundleIdentifier {
                    usingApp = UsingApplication(appId: bundleIdentifier, localized: app.localizedName, since: current)
                }
            }
        }
    }
    
    private func updateUsingApp(lastUsingApp: UsingApplication, duration: NSTimeInterval) {
        var app: App
        if self.apps[lastUsingApp.appId] != nil {
            app = self.apps[lastUsingApp.appId]!
        } else {
            app = App()
            app.appIdentifier = lastUsingApp.appId
            app.localized = lastUsingApp.localized
            self.apps[lastUsingApp.appId] = app
        }
        let stat: Stat = Stat(value: ["app": app, "start": lastUsingApp.since, "duration": Int(duration * 1000)])
        let realm = try! Realm()
        try! realm.write {
            realm.add(stat)
        }
    }
}
