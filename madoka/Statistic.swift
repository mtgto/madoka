//
//  Statistic.swift
//  madoka
//
//  Created by mtgto on 2016/01/30.
//  Copyright © 2016 mtgto. All rights reserved.
//

import Foundation
import RealmSwift

class Statistic: Object {
    dynamic var start: NSDate = NSDate()
    dynamic var end: NSDate = NSDate()
    dynamic var applicationIdentifier: String = ""
    
    convenience init(start: NSDate, end: NSDate, applicationIdentifier: String) {
        self.init()
        self.start = start
        self.end = end
        self.applicationIdentifier = applicationIdentifier
    }
}
