//
//  WaitingForPaymentConfirmationViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 29/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import SwiftyJSON
import UserNotifications
import SwiftyJSON
import SwiftSpinner
import Alamofire

class WaitingForPaymentConfirmationViewController: UIViewController,UNUserNotificationCenterDelegate {
    var bookingDetails : [String:JSON]!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var vwback: UIView!
    @IBOutlet weak var waitingLbl: UILabel!
    @IBOutlet weak var imgPay: UIImageView!
    @IBOutlet weak var lblpament: UILabel!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lblpament.text = "PAYMENT CONFIRMATION".localized()
        waitingLbl.text = "Waiting for Payment Confirmation".localized()
        
        
        lblpament.font = FontBook.Medium.of(size: 22)
        waitingLbl.font = FontBook.Medium.of(size: 20)
        
        vwback.layer.cornerRadius = vwback.frame.size.width / 2
        vwback.layer.masksToBounds = true
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(WaitingForPaymentConfirmationViewController.refresh(sender:)), name: NSNotification.Name(rawValue: "moveReview"), object: nil)

        
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        getAppSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAppSettings()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
         changeTintColor(imgPay, arg: UIColor.white)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            lblpament.textColor = mycolor
            
//            changeTintColor(imgPay, arg: mycolor)
            vwback.layer.backgroundColor = mycolor.cgColor
        }
    }
    
    
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
                getAppSettings()
                
                completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
                
            }
        }
        else
        {
            getAppSettings()
            
            completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
            
            
            
        }
        
    }

    func getAppSettings(){
        var headers : HTTPHeaders!
        if let accesstoken = UserDefaults.standard.string(forKey: "access_token") as String!
        {
            headers = [
                "Authorization": accesstoken,
                "Accept": "application/json"
            ]
        }
        else
        {
            headers = [
                "Authorization": "",
                "Accept": "application/json"
            ]
        }
        
        let url = APIList().getUrlString(url: .APPSETTINGS)

        Alamofire.request(url,method: .get, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                if let json = response.result.value {
                    print("APP SETTINGS JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else if(jsonResponse["delete_status"].stringValue == "active")
                    {
                        print(jsonResponse["delete_status"].stringValue)
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        let alert = UIAlertController(title: "Attenction!".localized(), message: "HI! Your Account Has Been Suspended By Admin. For Further Information Please Contact admin@uberdoo.com".localized(), preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                            self.present(vc, animated: true, completion: nil)
                        }))
                        // alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    else{
                        Constants.locations = jsonResponse["location"].arrayValue
                        Constants.timeSlots = jsonResponse["timeslots"].arrayValue
                        
                        let statusArray = jsonResponse["status"].arrayValue;
                        if(statusArray.count > 0){
                            let statusDict = statusArray[0].dictionary
                            let currentStatus = statusDict!["status"]?.stringValue
                            if(currentStatus == "Reviewpending"){
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as!     ReviewViewController
                                vc.bookingDetails = statusDict
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            else{
                print(response.error!.localizedDescription)
                //                self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

}
