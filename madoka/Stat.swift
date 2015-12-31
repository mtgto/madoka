//
//  Stat.swift
//  madoka
//
//  Created by mtgto on 2015/08/01.
//  Copyright (c) 2015 mtgto. All rights reserved.
//

import RealmSwift
import Foundation

class Stat: Object {
    dynamic var app: App?
    dynamic var start: NSDate = NSDate()
    dynamic var duration: Int32 = 0
    
    required init() {
        super.init()
    }
    
    init(app: App, start: NSDate, duration: Int32) {
        super.init()
        self.app = app
        self.start = start
        self.duration = duration
    }
    
    override static func indexedProperties() -> [String] {
        return ["start"]
    }
}
