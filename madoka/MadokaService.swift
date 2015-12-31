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
    
    private var timer: NSTimer!
    
    private var usingApp: UsingApplication?
    
    private var apps: Set<App> = Set(try! Realm().objects(App))
    
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
                    usingApp = UsingApplication(appId: bundleIdentifier, since: current)
                }
            }
        }
    }
    
    func updateUsingApp(lastUsingApp: UsingApplication, duration: NSTimeInterval) {
        let app = App()
        let stat = Stat(app: app, start: lastUsingApp.since, duration: Int32(duration * 1000))
        let realm = try! Realm()
        try! realm.write {
            realm.add(stat)
        }
    }
}
