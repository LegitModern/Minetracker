//
//  MojangInterfaceController.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/23/16.
//  Copyright © 2016 Ryan Donaldson. All rights reserved.
//

import WatchKit
import Foundation


class MojangInterfaceController: WKInterfaceController {
    
    @IBOutlet var mojangStatusTable: WKInterfaceTable!
    
//    let mojangController = MojangController.instance
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        loadTableData()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func loadTableData() {
        mojangStatusTable.setNumberOfRows(5, withRowType: "MojangStatusRow")
        
        
    }
}
