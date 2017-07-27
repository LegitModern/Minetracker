//
//  MojangStatusViewController.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/12/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MojangStatusViewController: UIViewController {
    
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var sessionsView: UIView!
    @IBOutlet weak var apiView: UIView!
    @IBOutlet weak var skinsView: UIView!
    
    @IBOutlet weak var websiteStatus: UILabel!
    @IBOutlet weak var authStatus: UILabel!
    @IBOutlet weak var sessionsStatus: UILabel!
    @IBOutlet weak var apiStatus: UILabel!
    @IBOutlet weak var skinsStatus: UILabel!

    let mojangJSON = MojangController.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mojangJSON.showLoadingHUD(self.view)
        mojangJSON.startSocket(self.view, viewController: self) { 
            DispatchQueue.main.async(execute: {
                self.loadView(0, label: self.websiteStatus, view: self.websiteView)
                self.loadView(1, label: self.authStatus, view: self.authView)
                self.loadView(2, label: self.sessionsStatus, view: self.sessionsView)
                self.loadView(3, label: self.apiStatus, view: self.apiView)
                self.loadView(4, label: self.skinsStatus, view: self.skinsView)
            })
        }
        FIRAnalytics.logEvent(withName: "visited_mojang_controller", parameters: ["id": 1 as NSObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshData(_ sender: AnyObject) {
        if mojangJSON.socket.engine != nil && mojangJSON.socket.engine!.connected {
            mojangJSON.socket.disconnect()
            mojangJSON.showLoadingHUD(self.view)
            mojangJSON.startSocket(self.view, viewController: self) {
                DispatchQueue.main.async(execute: {
                    self.loadView(0, label: self.websiteStatus, view: self.websiteView)
                    self.loadView(1, label: self.authStatus, view: self.authView)
                    self.loadView(2, label: self.sessionsStatus, view: self.sessionsView)
                    self.loadView(3, label: self.apiStatus, view: self.apiView)
                    self.loadView(4, label: self.skinsStatus, view: self.skinsView)
                })
            }
        }
    }
    
    func loadView(_ index: Int, label: UILabel, view: UIView) {
        let mojangStatus = mojangJSON.statuses[index] as String!
        if let status = mojangStatus {
            switch (status) {
            case "green":
                label.text = "Online"
                view.backgroundColor = UIColor(rgba: "#51B46D")
            case "yellow":
                label.text = "Unstable"
                view.backgroundColor = UIColor(rgba: "#e15258")
            default:
                label.text = "Offline"
                view.backgroundColor = UIColor(rgba: "#e15258")
            }
        }
    }
}

