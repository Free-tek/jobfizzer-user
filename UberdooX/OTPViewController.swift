//
//  OTPViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 19/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON

class OTPViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var btnverify: UIButton!
    
    @IBOutlet weak var otpLbl: UILabel!
    @IBOutlet weak var otpField: UITextField!
    var otp : String!
    var email : String!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        otpLbl.text = "Enter verification code".localized()
        otpField.delegate = self
        btnverify.setTitle("VERIFY".localized(),for: .normal)
        
        
        otpLbl.font = FontBook.Regular.of(size: 17)
        otpField.font = FontBook.Regular.of(size: 17)
        btnverify.titleLabel!.font = FontBook.Regular.of(size: 17)
        
        
//        changeFont()
        
        //otpField.text = otp
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
           btnverify.backgroundColor = mycolor
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated:true,completion:nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        if(textField == otpField)
        {
            if(textField.text!.count <= 5) {
                return true
            }else if(char.elementsEqual([0])){
                return true
            }else{
                return false
            }

        }else{
            return true
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
    
    
    @IBAction func verify(_ sender: Any) {
        if let text = otpField.text, !text.isEmpty
        {
            
            var Email = ""
            if SharedObject().hasData(value: email){
                Email = email!
            }
            let params: Parameters = [
                "email": Email,
                "otp": otpField.text!
            ]
            SwiftSpinner.show("Sending OTP...".localized())
            let url = APIList().getUrlString(url: .FORGOTOTPCHECK)

            Alamofire.request(url,method: .post,parameters:params).responseJSON { response in
                
                if(response.result.isSuccess)
                {
                    SwiftSpinner.hide()
                    if let json = response.result.value {
                        print("OTP VERIFY JSON: \(json)") // serialized json response
                        let jsonResponse = JSON(json)
                        if(jsonResponse["error"].stringValue == "true")
                        {
                            let errorMessage = jsonResponse["error_message"].stringValue
                            self.showAlert(title: "Failed".localized(),msg: errorMessage)
                        }
                        else{
//                            let otp = jsonResponse["otp"].stringValue
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResetOtpViewController") as! ResetOtpViewController
                            vc.email = self.email
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
        else{
            showAlert(title: "Validation Failed".localized(),msg: "Please Enter Otp".localized())
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
