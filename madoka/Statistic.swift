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
    @objc dynamic var start: Date = Date()
    @objc dynamic var end: Date = Date()
    @objc dynamic var applicationIdentifier: String = ""
}
