//
//  ServerStatusMasterViewController.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/14/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import SwiftyJSON
import UIKit
import FirebaseAnalytics

class ServerStatusMasterViewController: UITableViewController {

    let networkList = ServerController.instance
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if networkList.socket.engine != nil && networkList.socket.engine!.connected {
            reloadTableWithData(true)
        } else {
            networkList.showLoadingHUD(self.view)
            networkList.startSocket(self.view, viewController: self) {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.clear
        self.refreshControl?.tintColor = UIColor.white
        self.refreshControl?.addTarget(self, action: #selector(ServerStatusMasterViewController.reloadTableWithData), for: UIControlEvents.valueChanged)
        
        FIRAnalytics.logEvent(withName: "visited_server_master_controller", parameters: ["id": 2 as NSObject])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return networkList.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkList.numberOfItemsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ServerTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            cell.accessoryView?.backgroundColor = UIColor(rgba: "#2D2F33")
            cell.backgroundColor = UIColor(rgba: "#2D2F33")
        }
    }
    
    /* override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor(rgba: "#2D2F33")
        let highlightView = UIView()
        highlightView.backgroundColor = UIColor(rgba: "#2D2F33")
        cell?.selectedBackgroundView = highlightView
    } */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let indexPath = tableView.indexPathForSelectedRow
            let root = segue.destination as! ServerStatusDetailViewController
            if let pathExists = indexPath {
                root.segueIndex = (pathExists as NSIndexPath).row
            }
        }
    }
    
    func configureTableView() {
        self.tableView.rowHeight = 81
    }
    
    func configureCell(_ cell: ServerTableViewCell, atIndexPath indexPath: IndexPath) {
        cell.networkLabel?.text = networkList.titleForItemAtIndexPath(indexPath)
        cell.networkLabel?.textColor = UIColor.white
        
        if let image = networkList.imageForItemAtIndexPath(indexPath) {
            cell.faviconLabel?.image = image
        }
    }
    
    func reloadTableWithData(_ showHud: Bool) {
        networkList.refreshSocket()
        if (showHud) {
            networkList.showLoadingHUD(self.view)
        }
        
        let refreshHandler: UUID = networkList.socket.on("add") { (data, ack) in
            let json = JSON(data)
            let last = json[0][0].arrayValue.last!
            
            self.networkList.fetchItems(self.view, viewController: self, data: last, success: {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                    
                    if let refresher = self.refreshControl {
                        self.dateFormatter.dateFormat = "MMM d, h:mm a"
                        let date = NSDate()
                        let todaysDate = self.dateFormatter.string(from: date as Date)
                        let lastUpdated = "Last update: \(todaysDate)"
                        
                        let attributesDictionary = NSDictionary(object: UIColor.white, forKey: NSForegroundColorAttributeName as NSCopying)
                        let attributeString = NSAttributedString(string: lastUpdated, attributes: attributesDictionary as? [String : AnyObject])
                        refresher.attributedTitle = attributeString
                        
                        refresher.endRefreshing()
                    }
                })
            })
        }
    
        let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.networkList.socket.off(id: refreshHandler)
        }
    }
}
