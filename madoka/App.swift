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
    dynamic var appIdentifier: String = ""
    dynamic var localized: String?
    let stats = List<Stat>()
    
    override static func primaryKey() -> String? {
        return "appIdentifier"
    }
    
    override var hashValue: Int {
        return appIdentifier.hashValue
    }
}

func ==(lhs: App, rhs: App) -> Bool {
    return lhs.appIdentifier == rhs.appIdentifier
}
