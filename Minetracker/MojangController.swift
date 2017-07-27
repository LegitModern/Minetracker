//
//  MojangJSON.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/11/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import SwiftyJSON
import MBProgressHUD
import SocketIO
import NYAlertViewController

class MojangController {
    
    static let instance = MojangController()
    
    let socket = SocketIOClient(socketURL: URL(string: "https://minetrack.me")!, config: [
//            .log(true),
            .reconnects(true),
            .reconnectAttempts(10),
            .reconnectWait(1000)
        ]
    )
    
    var names = [String]()
    var statuses = [String]()
    let services: [String] = ["authserver.mojang.com", "sessionserver.mojang.com", "api.mojang.com", "textures.minecraft.net"]
    
    func startSocket(_ view: UIView, viewController: UIViewController, success: @escaping () -> ()) {
        
        socket.connect(timeoutAfter: 30) {
            print("Failed to reconnect to the Minetrack socket!")
            self.hideLoadingHUD(view)
            self.createAlertController(viewController)
        }
        
        socket.on("connect") { (data, ack) in
            print("Connected to Minetrack socket!")
        }
        
        socket.on("disconnect") { (data, ack) in
            print("Disconnected from the Minetrack socket!")
        }
        
        socket.on("updateMojangServices") { (data, ack) in
            let json = JSON(data)
            self.fetchItems(view, viewController: viewController, data: json, success: { 
                success()
            })
        }
    }
    
    func fetchItems(_ view: UIView, viewController: UIViewController, data: JSON, success: () -> ()) {
        self.names.removeAll(keepingCapacity: true)
        self.statuses.removeAll(keepingCapacity: true)
        
        self.names.append("Website")
        self.statuses.append("green")
        
        for service in services {
            if let name = data[0][service]["name"].string {
                self.names.append(name)
            }
            if let status = data[0][service]["status"].string {
                self.statuses.append(status)
            }
        }
        
        success()
        self.hideLoadingHUD(view)
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
}
