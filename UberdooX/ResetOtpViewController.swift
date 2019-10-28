//
//  ResetOtpViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 21/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON

class ResetOtpViewController: UIViewController {

    @IBOutlet weak var resetLbl: UILabel!
    @IBOutlet weak var btnreset: UIButton!
    @IBOutlet weak var passwordFld: UITextField!
    @IBOutlet weak var confrimPasswordFld: UITextField!
    var email : String!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        resetLbl.text = "Reset Password".localized()
        passwordFld.placeholder = "PASSWORD".localized()
        confrimPasswordFld.placeholder = "CONFIRM PASSWORD".localized()
        btnreset.setTitle("RESET".localized(),for: .normal)
        
        
        resetLbl.font = FontBook.Medium.of(size: 22)
        passwordFld.font = FontBook.Regular.of(size: 17)
        confrimPasswordFld.font = FontBook.Regular.of(size: 17)
        btnreset.titleLabel!.font = FontBook.Regular.of(size: 17)
       
        
        
        
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
            btnreset.backgroundColor = mycolor
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
    
    @IBAction func goToBack(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func resetPassword(_ sender: Any) {
        let pass = passwordFld.text!
        let confirmpass = confrimPasswordFld.text!
        if (passwordFld.text?.isEmpty)! {
            showAlert(title: "Validation Failed".localized(), msg: "Please enter Password".localized())
        }
        else if pass.count < 6 {
            showAlert(title: "Validation Failed".localized(), msg: "Password should be minimum 6 characters".localized())
        }
        else if (confrimPasswordFld.text?.isEmpty)! {
            showAlert(title: "Validation Failed".localized(), msg: "Please enter Confirm Password".localized())
        }
        else if confirmpass.count < 6 {
            showAlert(title: "Validation Failed".localized(), msg: "Confirm Password should be minimum 6 characters".localized())
        }
//        else if pass == confirmpass {
//            showAlert(title: "Validation Failed".localized(), msg: "Password doesn't match".localized())
//        }
        else {
        if(pass.count == 0)
        {
            showAlert(title: "Validation Failed".localized(), msg: "Please enter Password".localized())
        }
        else{
            print(pass,confirmpass)
            if(pass == confirmpass)
            {
                var Email = ""
                if SharedObject().hasData(value: email){
                    Email = email!
                }
                let params: Parameters = [
                    "email": Email,
                    "confirmpassword": confirmpass,
                    "password": pass
                ]
                print(params)
                SwiftSpinner.show("Changing your password...".localized())
                
                let url = APIList().getUrlString(url: .RESETPASSWORD)
                Alamofire.request(url,method: .post,parameters:params).responseJSON { response in
                    
                    if(response.result.isSuccess)
                    {
                        SwiftSpinner.hide()
                        if let json = response.result.value {
                            print("RESET PASSWORD JSON: \(json)") // serialized json response
                            let jsonResponse = JSON(json)
                            if(jsonResponse["error"].stringValue == "true")
                            {
                                let errorMessage = jsonResponse["error_message"].stringValue
                                self.showAlert(title: "Login Failed".localized(),msg: errorMessage)
                            }
                            else{
                                let alert = UIAlertController(title: "Password Changed Successfully".localized(), message: "Please login".localized(), preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: {
                                    (alert: UIAlertAction!) in
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                                    self.present(vc, animated: true, completion: nil)
                                }))
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
            else{
             showAlert(title: "Validation Failed".localized(), msg: "Password and Confirm Password must be same".localized())
            }
        }
    }
    }
    
}
