//
//  SplashViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 05/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import Localize_Swift

class SplashViewController: UIViewController, OfflineViewControllerDelegate
{
    func tryAgain() {
        getAppSettings()
        dismiss(animated: true, completion: nil)
    }
    var isFrom = ""

    override func viewDidLoad() {
        super.viewDidLoad()
//        Localize.setCurrentLanguage("pt-BR")
       
        
        // Do any additional setup after loading the view.
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    func getAppSettings()
    {
        if Reachability.isConnectedToNetwork() {
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
                        self.showAlert(title: "Oops", msg: jsonResponse["error_message"].stringValue)
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else if(jsonResponse["message"].stringValue == "Unauthenticated.")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnboardViewController") as! OnboardViewController
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
                        
                        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                        if(isLoggedIn)
                        {
                            self.updateDeviceToken()
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                            vc.isFrom = self.isFrom
                            MainViewController.status = statusArray
                            self.present(vc, animated: true, completion: nil)
                        }
                        else{
                            let isLoggedInSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
                            if(isLoggedInSkipped)
                            {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                                vc.isFrom = self.isFrom
                                 MainViewController.status = statusArray
                                self.present(vc, animated: true, completion: nil)
                            }
                            else{
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnboardViewController") as! OnboardViewController
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            else{
                print(response.error!.localizedDescription)
                
                /*
                
//                self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController

                self.present(vc, animated: true, completion: nil)*/
                
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.present(vc, animated: true, completion: nil)

            }
        }
        }
        else {
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
//            showAlert(title: "Oops".localized(), msg: "Please check the internet connection".localized())
        }
    }
    
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }*/
    
    func updateDeviceToken(){
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
        
        let deviceToken = InstanceID.instanceID().token()
        
        var params = Parameters()
        
        if SharedObject().hasData(value: deviceToken)
        {
            params = [
                "fcm_token": deviceToken!,
                "os":"iOS"
            ]
        }
        else
        {
            params = [
                "fcm_token": "",
                "os":"iOS"
            ]
        }
        
        
        
        print("Splash Params = ",params)
        
        
        let url = APIList().getUrlString(url: .UPDATEDEVICETOKEN)

        Alamofire.request(url,method: .post,parameters:params, headers:headers).responseJSON { response in
            
            print(response.description)
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAppSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
