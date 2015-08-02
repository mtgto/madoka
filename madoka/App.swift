//
//  App.swift
//  madoka
//
//  Created by mtgto on 2015/08/01.
//  Copyright (c) 2015 mtgto. All rights reserved.
//

import Foundation
import CoreData

class App: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var localized: String

}
