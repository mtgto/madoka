//
//  Stat.swift
//  madoka
//
//  Created by mtgto on 2015/08/01.
//  Copyright (c) 2015 mtgto. All rights reserved.
//

import Foundation
import CoreData

class Stat: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var start: NSDate
    @NSManaged var duration: NSNumber

}
