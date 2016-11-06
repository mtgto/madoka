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
    dynamic var start: Date = Date()
    dynamic var end: Date = Date()
    dynamic var applicationIdentifier: String = ""
    
    convenience init(start: Date, end: Date, applicationIdentifier: String) {
        self.init()
        self.start = start
        self.end = end
        self.applicationIdentifier = applicationIdentifier
    }
}
