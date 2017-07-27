//
//  ServerJSON.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/14/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import SwiftyJSON
import MBProgressHUD
import SocketIO
import NYAlertViewController

class ServerController {
    
    static let instance = ServerController()
    
    let socket = SocketIOClient(socketURL: URL(string: "https://minetrack.me")!, config: [
//            .log(true),
            .reconnects(true),
            .reconnectAttempts(10),
            .reconnectWait(1000)
        ]
    )
    
    var onlinePlayers = [Int]()
    var maxPlayers = [Int]()
    var ip = [String]()
    var name = [String]()
    var versions = [String]()
    var status = [String]()
    var favicon = [UIImage?]()
    
    var data = [ServerData]()
    
    let versionAsString: [Int: String] = [
        4: "1.7.2",
        5: "1.7.10",
        47: "1.8",
        107: "1.9",
        210: "1.10",
        315: "1.11"
    ]
    
    func startSocket(_ view: UIView, viewController: UIViewController, success: @escaping () -> ()) {
        
        socket.connect(timeoutAfter: 30) {
            print("Failed to reconnect to the Minetrack socket!")
            self.hideLoadingHUD(view)
            self.createAlertController(viewController)
            if let tableView = viewController as? UITableViewController {
                tableView.refreshControl?.endRefreshing()
            }
        }
        
        socket.on("connect") { (data, ack) in
            print("Connected to Minetrack socket!")
            self.socket.emit("requestListing")
        }
        
        socket.on("disconnect") { (data, ack) in
            print("Disconnected from the Minetrack socket!")
        }
        
        socket.on("reconnect") { (data, ack) in
            print("Reconnecting to the Minetrack socket...")
        }
        
        let handler: UUID = socket.on("add") { (data, ack) in
            let json = JSON(data)
            let last = json[0][0].arrayValue.last!
            self.fetchItems(view, viewController: viewController, data: last, success: {
                success()
            })
        }
    
        let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.socket.off(id: handler)
        }
    }
    
    func refreshSocket() {
        removeAllFromArrays()
        socket.emit("requestListing")
    }
    
    func fetchItems(_ view: UIView, viewController: UIViewController, data: JSON, success: @escaping () -> ()) {
        
        if let onlinePlayer = data["result"]["players"]["online"].int {
            self.onlinePlayers.append(onlinePlayer)
        } else {
            self.onlinePlayers.append(0)
        }
        if let maxPlayer = data["result"]["players"]["max"].int {
            self.maxPlayers.append(maxPlayer)
        } else {
            self.maxPlayers.append(0)
        }
        if let networkIP = data["info"]["ip"].string {
            self.ip.append(networkIP)
        } else {
           self.ip.append("Loading...")
        }
        if let networkName = data["info"]["name"].string {
            self.name.append(networkName)
        }
        if let versions = data["versions"].array {
            var label = ""
            var labelToJoin: [String] = []
            
            for version in versions {
                if let networkVersion = version.int {
                    let finalVersion = self.versionAsString[networkVersion]
                    if finalVersion != nil {
                        labelToJoin.append(finalVersion!)
                    } else {
                        labelToJoin.append("\(networkVersion)")
                    }
                }
            }
            
            label = labelToJoin.joined(separator: ", ")
            
            self.versions.append(label)
        } else {
            self.versions.append("Loading...")
        }
        if let networkStatus = data["error"].string {
            self.status.append(networkStatus)
        } else {
            self.status.append("")
        }
        if let favicon = data["result"]["favicon"].string {
            if favicon == "/favicons/mineplex.png" {
                let mineplexFavicon = UIImage(named: "mineplex.png")
                self.favicon.append(mineplexFavicon!)
            } else {
                if let faviconImageExists = self.imageFromFaviconString(favicon) {
                    self.favicon.append(faviconImageExists)
                } else {
                    let noFavicon = UIImage(named: "nofavicon.png")
                    self.favicon.append(noFavicon!)
                }
            }
        } else {
            let noFavicon = UIImage(named: "nofavicon.png")
            self.favicon.append(noFavicon!)
        }
        
        let delayTime = DispatchTime.now() + Double(Int64(1.85 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.hideLoadingHUD(view)
            success()
//            print("\(self.name)")
        }
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return name.count
    }
    
    func titleForItemAtIndexPath(_ indexPath: IndexPath) -> String {
        return name[(indexPath as NSIndexPath).row]
    }
    
    func imageForItemAtIndexPath(_ indexPath: IndexPath) -> UIImage? {
        if let isImageHere = favicon[safe: (indexPath as NSIndexPath).row] {
            return isImageHere
        } else {
            return UIImage(named: "nofavicon.png")
        }
    }
    
    func imageFromFaviconString(_ base64String: String) -> UIImage? {
        let urlFromData = URL(string: base64String)
        let dataFromUrl = try? Data(contentsOf: urlFromData!)
        let decodedImage = UIImage(data: dataFromUrl!)
        
        if let imageExists = decodedImage {
            return imageExists
        } else {
            return nil
        }
    }
    
    func showLoadingHUD(_ view: UIView) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Loading..."
    }
    
     func hideLoadingHUD(_ view: UIView) {
        MBProgressHUD.hideAllHUDs(for: view, animated: true)
    }

    fileprivate func createAlertController(_ view: UIViewController) {
        let alertVC = NYAlertViewController()
        
        alertVC.title = "Error"
        alertVC.message = "Please make sure you have a valid internet connection & then refresh!"
        alertVC.alertViewCornerRadius = 2.0
        alertVC.alertViewBackgroundColor = UIColor(red: 0.23, green: 0.23, blue: 0.27, alpha: 1.00)
        alertVC.view.tintColor = UIColor(red: 0.23, green: 0.23, blue: 0.27, alpha: 1.00)
        
        alertVC.titleFont = UIFont(name: "HelveticaNeue-Light", size: 16.0)
        alertVC.titleColor = UIColor.white
        alertVC.messageFont = UIFont(name: "HelveticaNeue", size: 14.0)
        alertVC.messageColor = UIColor(white: 0.8, alpha: 1)
        
        alertVC.cancelButtonColor = UIColor(red: 0.25, green: 0.25, blue: 0.29, alpha: 1.00)
        alertVC.cancelButtonTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        alertVC.cancelButtonTitleColor = UIColor.white
        
        alertVC.buttonCornerRadius = 2.0
        alertVC.transitionStyle = .fade
        alertVC.swipeDismissalGestureEnabled = false
        alertVC.backgroundTapDismissalGestureEnabled = false
        
        let cancelAction = NYAlertAction(
            title: "Ok",
            style: .cancel,
            handler: { (action: NYAlertAction?) -> Void in
                view.dismiss(animated: true, completion: nil)
            }
        )
        alertVC.addAction(cancelAction)
        view.present(alertVC, animated: true, completion: nil)
    }
    
    func removeAllFromArrays() {
        self.onlinePlayers.removeAll(keepingCapacity: true)
        self.maxPlayers.removeAll(keepingCapacity: true)
        self.ip.removeAll(keepingCapacity: true)
        self.name.removeAll(keepingCapacity: true)
        self.versions.removeAll(keepingCapacity: true)
        self.status.removeAll(keepingCapacity: true)
        self.favicon.removeAll(keepingCapacity: true)
    }
}
