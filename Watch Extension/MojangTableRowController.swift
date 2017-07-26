//
//  MojangTableRowController.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/31/16.
//  Copyright © 2016 Ryan Donaldson. All rights reserved.
//

import WatchKit

class MojangTableRowController: NSObject {

    @IBOutlet var statusSeparator: WKInterfaceSeparator!
    @IBOutlet var websiteLabel: WKInterfaceLabel!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    
    var serviceData: ServiceData? {
        didSet {
            if let serviceDataExists = serviceData {
                websiteLabel.setText(serviceDataExists.name)
                statusLabel.setText(serviceDataExists.status)
            }
        }
    }
}
