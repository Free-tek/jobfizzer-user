
//
//  ChangePasswordViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 27/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    
    
    @IBOutlet weak var btnchange: UIButton!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        titleLbl.text = "Change Password".localized()
        oldPassword.placeholder = "OLD PASSWORD".localized()
        password.placeholder = "NEW PASSWORD".localized()
        confirmPassword.placeholder = "CONFIRM PASSWORD".localized()
        
        btnchange.setTitle("SUBMIT".localized(),for: .normal)
        
        
        
        titleLbl.font = FontBook.Medium.of(size: 20)
        oldPassword.font = FontBook.Regular.of(size: 17)
        password.font = FontBook.Regular.of(size: 17)
        confirmPassword.font = FontBook.Regular.of(size: 17)

        btnchange.titleLabel!.font = FontBook.Regular.of(size: 17)
     
        
        
//        changeFont()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            btnchange.backgroundColor = mycolor
        }
        
    }
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }*/
    
    @IBAction func submit(_ sender: Any) {
        if(oldPassword.text == "")
        {
            self.showAlert(title: "Validation Failed".localized(),msg: "Please Enter Old Password".localized())
        }else if oldPassword.text!.count < 6 {
            showAlert(title: "Validation Failed".localized(),msg: "Old Password should be minimum 6 characters".localized())
            
        }
        else{
            if(password.text == "" )
            {
                self.showAlert(title: "Validation Failed".localized(),msg: "Please Enter New Password".localized())
            }else if password.text!.count < 6 {
                showAlert(title: "Validation Failed".localized(),msg: "New Password should be minimum 6 characters".localized())
                
            }
            else if(confirmPassword.text! == "")
            {
                self.showAlert(title: "Validation Failed".localized(),msg: "Please Enter Confirm Password".localized())
            }
            else if(password.text != confirmPassword.text!)
            {
                self.showAlert(title: "Validation Failed".localized(),msg: "Password and Confirm Password must be same".localized())
            }
            else{
                
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
                
                let params: Parameters = [
                    "oldpassword": oldPassword.text!,
                    "newpassword": password.text!,
                    "cnfpassword": confirmPassword.text!
                ]
                
                
                SwiftSpinner.show("Changing Password...".localized())
                
                let url = APIList().getUrlString(url: .CHANGEPASSWORD)

                Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
                    
                    if(response.result.isSuccess)
                    {
                        SwiftSpinner.hide()
                        if let json = response.result.value {
                            print("CHANGE PASSWORD JSON: \(json)") // serialized json response
                            let jsonResponse = JSON(json)
                            
                            
                            if(jsonResponse["error"].stringValue == "true")
                            {
                                let errorMessage = jsonResponse["error_message"].stringValue
                                self.showAlert(title: "Failed".localized(),msg: errorMessage)
                            }
                            else{
                                let alert = UIAlertController(title: "Success".localized(), message: "Password Changed Successfully".localized(), preferredStyle: UIAlertControllerStyle.alert)
                                
                                // add an action (button)
                                alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: {
                                    (alert: UIAlertAction!) in
                                        self.dismissViewController()
                                    }))
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else{
                        SwiftSpinner.hide()
                        print(response.error.debugDescription)
                        self.showAlert(title: "Oops".localized(), msg: response.error!.localizedDescription)
                    }
                }
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func dismissViewController()
    {
        self.dismiss(animated: true, completion: nil)
    }

}
