//
//  ForgotPasswordViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 19/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
class ForgotPasswordViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var forgotLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var btnnext: UIButton!
    @IBOutlet weak var btnemail: UIButton!
    @IBOutlet weak var countryCode: UIButton!
    @IBOutlet weak var phoneNumberField: UITextField!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        phoneNumberField.autocorrectionType = .no
        
        phoneNumberField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);

        phoneNumberField.delegate = self
        
        btnemail.setTitle("Email".localized(),for: .normal)
        btnnext.setTitle("Next".localized(),for: .normal)
        codeLbl.text = "Enter your email to receive a verification code".localized()
        
        forgotLbl.text = "Forgot Password".localized()
        
        
        forgotLbl.font = FontBook.Medium.of(size: 20)
        codeLbl.font = FontBook.Regular.of(size: 19)
        phoneNumberField.font = FontBook.Regular.of(size: 19)        
        btnemail.titleLabel!.font = FontBook.Regular.of(size: 17)
        btnnext.titleLabel!.font = FontBook.Medium.of(size: 18)
        
        
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
            btnnext.backgroundColor = mycolor
            btnemail.backgroundColor = mycolor
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
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
    
    
    func validateForm() -> Bool
    {
        let Emailvalid = validateEmail(enteredEmail: phoneNumberField.text!)
        if Emailvalid == false
        {
            showAlert(title: "Validation Failed".localized(),msg: "Invalid Email Id".localized())
            return false
        }
        else
        {
            return true
        }
        
    }
    
    @IBAction func goToOtpSCreen(_ sender: Any)
    {
        let isValid = validateForm()
        if(isValid)
        {
            if let text = phoneNumberField.text, !text.isEmpty
            {
                let params: Parameters = [
                    "email": phoneNumberField.text!            ]
                SwiftSpinner.show("Sending OTP...".localized())
                let url = APIList().getUrlString(url: .FORGOTPASSWORD)

                Alamofire.request(url,method: .post,parameters:params).responseJSON { response in
                    
                    if(response.result.isSuccess)
                    {
                        SwiftSpinner.hide()
                        if let json = response.result.value {
                            print("SEND OTP JSON: \(json)") // serialized json response
                            let jsonResponse = JSON(json)
                            print(jsonResponse)
                            if(jsonResponse["error"].stringValue == "true")
                            {
                                let errorMessage = jsonResponse["error_message"].stringValue
                                self.showAlert(title: "Failed".localized(),msg: errorMessage)
                            }
                            else{
                                let otp = jsonResponse["otp"].stringValue
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                                vc.otp = otp
                                vc.email = self.phoneNumberField.text
                                self.present(vc, animated: true, completion: nil)
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
            else
            {
                showAlert(title: "Validation Failed".localized(),msg: "Invalid Email".localized())
            }
        }
        else
        {
            showAlert(title: "Validation Failed".localized(),msg: "Invalid Email".localized())
        }
        
    }
    
    @IBAction func showCountyCodes(_ sender: Any)
    {
    
    }
    
    @IBAction func goBack(_ sender: Any)
    {
        //self.dismiss(animated: true, completion: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == phoneNumberField)
        {
            if  (string == " ")
            {
                return false
            }
            else
            {
                return true
            }
        }
        else
        {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField == phoneNumberField
        {
            textField.text = textField.text!.trimmingCharacters(in: .whitespaces)
        }
    }
    

}
