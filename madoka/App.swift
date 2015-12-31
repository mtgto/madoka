//
//  App.swift
//  madoka
//
//  Created by mtgto on 2015/08/01.
//  Copyright (c) 2015 mtgto. All rights reserved.
//

import Foundation
import RealmSwift

class App: Object, Hashable {
    dynamic var identifier: String = ""
    dynamic var localized: String?
    let stats = List<Stat>()
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    override var hashValue: Int {
        return identifier.hashValue
    }
}

func ==(lhs: App, rhs: App) -> Bool {
    return lhs.identifier == rhs.identifier
}
