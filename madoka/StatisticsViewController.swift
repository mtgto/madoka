//
//  StatisticsViewController.swift
//  madoka
//
//  Created by mtgto on 2016/01/31.
//  Copyright © 2016 mtgto. All rights reserved.
//

import Cocoa

class StatisticsViewController: NSViewController {
    func updateData(_ values: [(legend: String, color: NSColor, ratio: Float, icon: NSImage?)]) {
        let view = self.view as! StatisticsView
        view.updateValues(values)
    }
}
