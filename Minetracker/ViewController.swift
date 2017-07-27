//
//  ViewController.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/12/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit
import MessageUI
import NYAlertViewController
import FirebaseAnalytics

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var minetrackerLabel: UILabel!
    @IBOutlet weak var mojangStatusButton: UIButton!
    @IBOutlet weak var serverStatusButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func configureView() {
        // Custom Navigarion Bar Font/Color To Match Theme
        if let navbarFont = UIFont(name: "HelveticaNeue-Thin", size: 20.0) {
            let navbarAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: navbarFont
            ]
            self.navigationController?.navigationBar.titleTextAttributes = navbarAttributesDictionary
        }
        
        // Configure Navigation Bar Back Button
        if let buttonFont = UIFont(name: "HelveticaNeue-Thin", size: 20.0) {
            let barButtonAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: buttonFont
            ]
            UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributesDictionary, for: UIControlState())
        }
    }
    
    @IBAction func showAboutAlert(_ sender: AnyObject) {
        createAlertController()
    }
    
    func createAlertController() {
        let alertVC = NYAlertViewController()
        
        alertVC.title = "About"
        alertVC.message = "Minetracker was created by LegitModern thanks to Cryptkeeper's Minetrack on the web! If you enjoy the app, consider rating us on the App Store!\n\nTwitter: @Legit_Modern\nMinetrack: https://minetrack.me"
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
        
        alertVC.buttonColor = UIColor(red: 0.25, green: 0.25, blue: 0.29, alpha: 1.00)
        alertVC.buttonTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        alertVC.buttonTitleColor = UIColor.white
        
        alertVC.buttonCornerRadius = 2.0
        alertVC.transitionStyle = .fade
        alertVC.swipeDismissalGestureEnabled = false
        alertVC.backgroundTapDismissalGestureEnabled = false
        
        let cancelAction = NYAlertAction(
            title: "Close",
            style: .cancel,
            handler: { (action: NYAlertAction?) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
        )
        let emailAction = NYAlertAction(
            title: "Send Feedback",
            style: .default,
            handler: { (action: NYAlertAction?) -> Void in
                let platformVersion = UIDevice.current.modelName
                let systemVersion = UIDevice.current.systemVersion
                let appVersion: AnyObject? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as AnyObject?
                let appBuild: AnyObject? = Bundle.main.object(forInfoDictionaryKey: (kCFBundleVersionKey)! as String) as AnyObject?
                
                let emailTitle = "Minetracker ~ Feedback/Bug Report/Inquiry"
                let messageBody = "Please state your feedback or bug report here!\n\n### PLEASE DO NOT REMOVE THIS INFORMATION IF SUBMITTING A BUG REPORT! ###\nDevice Name: \(platformVersion)\niOS Version: \(systemVersion)\nApp Version: \(appVersion!)\nApp Build: \(appBuild!)"
                let toRecipents = ["minetrack.app@gmail.com"]
                
                let mailViewController = MFMailComposeViewController()
                mailViewController.mailComposeDelegate = self
                mailViewController.setSubject(emailTitle)
                mailViewController.setMessageBody(messageBody, isHTML: false)
                mailViewController.setToRecipients(toRecipents)
                
                self.dismiss(animated: true, completion: nil)
                self.present(mailViewController, animated: true, completion: nil)
            }
        )
        alertVC.addAction(cancelAction)
        alertVC.addAction(emailAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}

