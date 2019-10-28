//
//  MainViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 13/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import SwiftyJSON
import UserNotifications

class MainViewController: UITabBarController, UITabBarControllerDelegate,UNUserNotificationCenterDelegate {

    var isFrom = ""
    var goToBookings = false
    static var changePage = true
    static var reloadPage = true
    static var status : [JSON]! = []
    var mycolor = UIColor()
    
    static var startChat = false

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate  = self
        }
        
        self.delegate = self;
        

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool)
    {
       
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()

        if(MainViewController.changePage)
        {
            if(goToBookings == true)
            {
                self.selectedIndex = 0
            }else{
                self.selectedIndex = 1
            }
        }
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
        }
        

        tabBar.items?[0].title = "Bookings".localized()
        tabBar.items?[1].title = "Home".localized()
        tabBar.items?[2].title = "Account".localized()
        tabBar.items?[3].title = "Message".localized()

        
        
/*        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("ReDirectNotificationVC"), object: nil)*/
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    @objc func methodOfReceivedNotification(notification: Notification)
    {
        let userDef = UserDefaults()
        
        var givenVal = (userDef.value(forKey: "type" ) as? String)
        
        print("Value = ",givenVal!)
        
        if userDef.bool(forKey: "isNotification")
        {
            if ((userDef.value(forKey: "type" ) as? String) == "chat")
            {
                let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
                let Dvc = stoaryboard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
               Dvc.receiverId = "593"
                present(Dvc, animated: true, completion: nil)
            }
        }
        
    }*/
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        let dct : NSDictionary = userInfo as NSDictionary
        
        print("dct = ",dct)
        
        if (dct.object(forKey: "notification_type") != nil)
        {
            let type = dct.object(forKey: "notification_type") as! String
            
            if type == "chat"
            {
                
                let receiver_id = dct.object(forKey: "sender_id") as! String
                
                if appDelegate.chatReceiveID == ""
                {
                    completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
                }
                else
                {
                    
                    
                }
                
            }
            else
            {
                
                completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
                
            }
        }
        else
        {
            
            completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
            
            
            
        }
        
    }
    
   
}
