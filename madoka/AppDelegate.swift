//
//  AppDelegate.swift
//  madoka
//
//  Created by mtgto on 2015/07/20.
//  Copyright (c) 2015 mtgto. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    var statusItem: NSStatusItem!
    
    let madokaService: MadokaService = MadokaService.sharedInstance

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register(
            defaults: [
                Constants.KeyPreferenceIntervalIndex: 0,
                Constants.KeyPreferenceLaunchAtLogin: false
            ]
        )
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(self.madokaService, selector: #selector(MadokaService.didActivateApplication(_:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        notificationCenter.addObserver(self.madokaService, selector: #selector(MadokaService.willSleep(_:)), name: NSWorkspace.willSleepNotification, object: nil)
        notificationCenter.addObserver(self.madokaService, selector: #selector(MadokaService.didWake(_:)), name: NSWorkspace.didWakeNotification, object: nil)
        notificationCenter.addObserver(self.madokaService, selector: #selector(MadokaService.sessionDidResignActive(_:)), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        notificationCenter.addObserver(self.madokaService, selector: #selector(MadokaService.sessionDidBecomeActive(_:)), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
        setupStatusMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        madokaService.willTerminate()
        NotificationCenter.default.removeObserver(self.madokaService)
    }
    
    // MARK: - User defined functions

    func setupStatusMenu() {
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: -1) // NSVariableStatusItemLength
        statusItem.highlightMode = true
        let menuImage: NSImage! = NSImage(named: "Menu")
        menuImage.isTemplate = true
        statusItem.image = menuImage
        let menuImage2: NSImage! = NSImage(named: "Menu2")
        menuImage2.isTemplate = true
        statusItem.alternateImage = menuImage2
        statusItem.menu = statusMenu
    }
}
