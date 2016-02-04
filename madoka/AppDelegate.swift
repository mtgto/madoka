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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserDefaults.standardUserDefaults().registerDefaults(
            [Constants.KeyPreferenceIntervalIndex: 0]
        )
        let notificationCenter = NSWorkspace.sharedWorkspace().notificationCenter
        notificationCenter.addObserver(self.madokaService, selector: "didActivateApplication:", name: NSWorkspaceDidActivateApplicationNotification, object: nil)
        notificationCenter.addObserver(self.madokaService, selector: "willSleep:", name: NSWorkspaceWillSleepNotification, object: nil)
        notificationCenter.addObserver(self.madokaService, selector: "didWake:", name: NSWorkspaceDidWakeNotification, object: nil)
        notificationCenter.addObserver(self.madokaService, selector: "sessionDidResignActive:", name: NSWorkspaceSessionDidResignActiveNotification, object: nil)
        notificationCenter.addObserver(self.madokaService, selector: "sessionDidBecomeActive:", name: NSWorkspaceSessionDidBecomeActiveNotification, object: nil)
        setupStatusMenu()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        madokaService.willTerminate()
        NSNotificationCenter.defaultCenter().removeObserver(self.madokaService)
    }
    
    // MARK: - User defined functions

    func setupStatusMenu() {
        let statusBar = NSStatusBar.systemStatusBar()
        statusItem = statusBar.statusItemWithLength(-1) // NSVariableStatusItemLength
        statusItem.highlightMode = true
        let menuImage: NSImage! = NSImage(named: "Menu")
        menuImage.template = true
        statusItem.image = menuImage
        let menuImage2: NSImage! = NSImage(named: "Menu2")
        menuImage2.template = true
        statusItem.alternateImage = menuImage2
        statusItem.menu = statusMenu
    }
}
