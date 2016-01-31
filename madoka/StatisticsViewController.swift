//
//  StatisticsViewController.swift
//  madoka
//
//  Created by mtgto on 2016/01/31.
//  Copyright © 2016 mtgto. All rights reserved.
//

import Cocoa

class StatisticsViewController: NSViewController {
    func updateData(values: [(legend: String, color: NSColor, ratio: Float)]) {
        let view = self.view as! StatisticsView
        view.updateValues(values)
    }
}
