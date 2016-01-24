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
    
    override init() {
        super.init()
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(10.0), target: self, selector: Selector("onUpdate:"), userInfo: nil, repeats: true)
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
    
    func updateUsingApp(lastUsingApp: UsingApplication, duration: NSTimeInterval) {
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
