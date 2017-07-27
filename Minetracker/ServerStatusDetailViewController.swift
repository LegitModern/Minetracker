//
//  ServerStatusDetailViewController.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/15/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import SwiftyJSON
import UIKit
import Spring
import FirebaseAnalytics

class ServerStatusDetailViewController: UIViewController {

    @IBOutlet weak var serverNameLabel: UILabel?
    @IBOutlet weak var serverIPLabel: UILabel?
    @IBOutlet weak var playersLabel: UILabel?
    @IBOutlet weak var uptimeLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    
    @IBOutlet weak var serverNameView: UIView?
    @IBOutlet weak var serverIPView: UIView?
    @IBOutlet weak var playersView: UIView?
    @IBOutlet weak var uptimeView: UIView?
    @IBOutlet weak var statusView: UIView?
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    let serverJSON = ServerController.instance
    
    var segueIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        self.navigationItem.rightBarButtonItem = nil
        
        if let indexExists = self.segueIndex {
            self.title = serverJSON.name[indexExists] as String!
            self.loadServerView(indexExists, index: 0, label: self.serverNameLabel, view: self.serverNameView)
            self.loadServerView(indexExists, index: 1, label: self.serverIPLabel, view: self.serverIPView)
            self.loadServerView(indexExists, index: 2, label: self.playersLabel, view: self.playersView)
            self.loadServerView(indexExists, index: 3, label: self.uptimeLabel, view: self.uptimeView)
            self.loadServerView(indexExists, index: 4, label: self.statusLabel, view: self.statusView)
        }
        
        listenOnUpdate()
        
        var finalTitle = title!
        if finalTitle == "" {
            finalTitle = "Unknown"
        }
        FIRAnalytics.logEvent(withName: "visited_server_detail_controller", parameters: [
            "id": 3 as NSObject,
            "name": finalTitle as NSObject,
            "type": "PC" as NSObject
        ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        serverJSON.socket.off("update")
    }
    
    @IBAction func refreshData(_ sender: AnyObject) {
        serverJSON.refreshSocket()
        serverJSON.showLoadingHUD(self.view)
        
        let refreshHandler: UUID = serverJSON.socket.on("add") { (data, ack) in
            let json = JSON(data)
            let last = json[0][0].arrayValue.last!
            
            self.serverJSON.fetchItems(self.view, viewController: self, data: last, success: {
                DispatchQueue.main.async(execute: {
                    if let indexExists = self.segueIndex {
                        self.title = self.serverJSON.name[indexExists] as String!
                        self.loadServerView(indexExists, index: 0, label: self.serverNameLabel, view: self.serverNameView)
                        self.loadServerView(indexExists, index: 1, label: self.serverIPLabel, view: self.serverIPView)
                        self.loadServerView(indexExists, index: 2, label: self.playersLabel, view: self.playersView)
                        self.loadServerView(indexExists, index: 3, label: self.uptimeLabel, view: self.uptimeView)
                        self.loadServerView(indexExists, index: 4, label: self.statusLabel, view: self.statusView)
                    }
                })
                self.listenOnUpdate()
            })
        }
        
        serverJSON.socket.off(id: refreshHandler)
    }
    
    //TODO: VERSION 1.1 -- Refactor using data model!
    func loadServerView(_ segueIndex: Int, index: Int, label: UILabel?, view: UIView?) {
        
        let name = serverJSON.name[segueIndex] as String!
        let ip = serverJSON.ip[segueIndex] as String!
        let onlinePlayers = serverJSON.onlinePlayers[segueIndex] as Int!
        let maxPlayers = serverJSON.maxPlayers[segueIndex] as Int!
        let status = serverJSON.status[segueIndex] as String!
        let versions = serverJSON.versions[segueIndex] as String!
        
        switch (index) {
        case 0:
            label?.text = "\(name!)"
        case 1:
            label?.text = "\(ip!)"
        case 2:
            label?.text = "\(onlinePlayers)/\(maxPlayers)"
        case 3:
            label?.text = "\(versions!)"
        case 4:
            label?.text = "\(status)"
        default:
            label?.text = ""
        }
        
        if index == 3 {
            /* if let available = availability {
                getAvailabilityBackground(available, view: view)
            } */
        } else if index == 4 {
            if let labelExists = label {
                getStatusBackground(status, label: labelExists, view: view)
            }
        } else {
            //view?.backgroundColor = getRandomBackground()
        }
    }
    
    func getStatusBackground(_ status: String?, label: UILabel?, view: UIView?) {
        if status == "" {
            label?.text = "Online"
            view?.backgroundColor = UIColor(rgba: "#51B46D")
        } else {
            label?.text = "Offline"
            view?.backgroundColor = UIColor(rgba: "#e15258")
        }
    }
    
    func getRandomBackground(_ views: [UIView?]) -> UIColor? {
        let number = Int(arc4random_uniform(UInt32(7)))
        switch (number) {
        case 0:
            return UIColor(rgba: "#39add1")
        case 1:
            return UIColor(rgba: "#3079ab")
        case 2:
            return UIColor(rgba: "#c25975")
        case 3:
            return UIColor(rgba: "#838cc7")
        case 4:
            return UIColor(rgba: "#7d669e")
        case 5:
            return UIColor(rgba: "#53bbb4")
        case 6:
            return UIColor(rgba: "#637a91")
        case 7:
            return UIColor(rgba: "#f092b0")
        default:
            return UIColor(rgba: "#39add1")
        }
    }
    
    fileprivate func listenOnUpdate() {
        serverJSON.socket.on("update") { (data, ack) in
            let json = JSON(data)
            print(json)
            
            if let indexExists = self.segueIndex {
                if let networkName = json[0]["info"]["name"].string {
                    if self.serverJSON.name[indexExists] == networkName {
                        
                        if let onlinePlayer = json[0]["result"]["players"]["online"].int {
                            self.serverJSON.onlinePlayers[indexExists] = onlinePlayer
                        }
                        if let maxPlayer = json[0]["result"]["players"]["max"].int {
                            self.serverJSON.maxPlayers[indexExists] = maxPlayer
                        }
                        
                        let newOnlinePlayers = self.serverJSON.onlinePlayers[indexExists]
                        let newMaxPlayers = self.serverJSON.maxPlayers[indexExists]
                        
                        self.playersLabel?.text = "\(newOnlinePlayers)/\(newMaxPlayers)"
                    }
                }
            }
        }
    }
}
