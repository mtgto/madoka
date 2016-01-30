//
//  LocalizedName.swift
//  madoka
//
//  Created by mtgto on 2016/01/30.
//  Copyright © 2016 mtgto. All rights reserved.
//

import Foundation
import RealmSwift

class LocalizedName: Object {
    dynamic var applicationIdentifier: String = ""
    dynamic var localizedName: String = ""
    
    override static func primaryKey() -> String? {
        return "localizedName"
    }
    
    convenience init(applicationIdentifier: String, localizedName: String) {
        self.init()
        self.applicationIdentifier = applicationIdentifier
        self.localizedName = localizedName
    }
}
