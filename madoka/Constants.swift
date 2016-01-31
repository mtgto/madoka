//
//  Constant.swift
//  madoka
//
//  Created by mtgto on 2015/07/20.
//  Copyright (c) 2015 mtgto. All rights reserved.
//

import Foundation

struct Constants {
    static let ErrorDomain = "net.mtgto.madoka"
    static let KeyPreferenceIntervalIndex = "Interval"
    static let startDateFromIntervalIndex = { (i: Int, current: NSDate) -> NSDate? in
        switch i {
        case 0: // 1 hour ago
            return current.dateByAddingTimeInterval(-60 * 60)
        case 1: // 4 hour ago
            return current.dateByAddingTimeInterval(-4 * 60 * 60)
        case 2: // 8 hour ago
            return current.dateByAddingTimeInterval(-8 * 60 * 60)
        case 3: // today
            let calendar = NSCalendar.currentCalendar()
            return calendar.dateFromComponents(calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: current))!
        default:
            return nil
        }
    }
}
