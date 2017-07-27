//
//  ServerData.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/11/16.
//  Copyright © 2016 Ryan Donaldson. All rights reserved.
//

import Foundation
import UIKit

struct ServerData {
    var onlinePlayers: Int
    var maxPlayers: Int
    var ping: Int
    var ip: String
    var name: String
    var versions: String
    var status: String
    var favicon: UIImage?
}
