//
//  SignUpViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 12/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import Localize_Swift
import CoreLocation
import Firebase
import FirebaseMessaging
import CoreLocation


class SignUpViewController: UIViewController,UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate,OfflineViewControllerDelegate
{
    func tryAgain() {
        dismiss(animated: true, completion: nil)
    }
    
    
    var firstName = ""
    var lastName = ""
    var email = ""
    var image = ""
    
    @IBOutlet weak var orsignUpLbl: UILabel!
    
    
    @IBOutlet weak var passwordFld: UITextField!
    @IBOutlet weak var phoneFld: UITextField!
    @IBOutlet weak var emailFld: UITextField!
    @IBOutlet weak var firstNameFld: UITextField!
    @IBOutlet weak var lastNameFld: UITextField!
    var mycolor = UIColor()
    @IBOutlet weak var btnsignup: UIButton!
    
    @IBOutlet weak var haveAccountBtn: UIButton!
    
    @IBOutlet weak var signUpLbl: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    let locationManager = CLLocationManager()
    
    
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ "
    let ACCEPTABLE_CHARACTERS1 = "0123456789+"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        
        //      emailFld.delegate = self
        //      passwordFld.delegate = self
        phoneFld.delegate = self
        firstNameFld.delegate = self
        lastNameFld.delegate = self
        emailFld.delegate = self
        passwordFld.delegate = self
        
        emailFld.keyboardType = .emailAddress
        passwordFld.keyboardType = .asciiCapable
        firstNameFld.keyboardType = .asciiCapable
        lastNameFld.keyboardType = .asciiCapable
        
        emailFld.autocorrectionType = .no
        passwordFld.autocorrectionType = .no
        firstNameFld.autocorrectionType = .no
        lastNameFld.autocorrectionType = .no
        
        if #available(iOS 10.0, *) {
            phoneFld.keyboardType = .asciiCapableNumberPad
        } else {
            phoneFld.keyboardType = .numberPad
        }
        
        passwordFld.placeholder = "PASSWORD".localized()
        phoneFld.placeholder = "PHONE NUMBER".localized()
        emailFld.placeholder = "EMAIL ADDRESS".localized()
        firstNameFld.placeholder = "FIRST NAME".localized()
        lastNameFld.placeholder = "LAST NAME".localized()
        btnsignup.setTitle("SIGNUP".localized(),for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(),for: .normal)
        signUpLbl.text = "Sign up".localized()
        titleLbl.text = "Jobfizzer".localized()
        
        
        
        titleLbl.font = FontBook.Medium.of(size: 22)
        signUpLbl.font = FontBook.Medium.of(size: 20)
        passwordFld.font = FontBook.Regular.of(size: 16)
        phoneFld.font = FontBook.Regular.of(size: 16)
        emailFld.font = FontBook.Regular.of(size: 16)
        firstNameFld.font = FontBook.Regular.of(size: 16)
        lastNameFld.font = FontBook.Regular.of(size: 16)
        btnsignup.titleLabel!.font = FontBook.Regular.of(size: 17)
        haveAccountBtn.titleLabel!.font = FontBook.Medium.of(size: 14)
        
        
        
        //        changeFont()
        
    }
    
    //    @objc func keyboardWillShow(notification: NSNotification) {
    //        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
    //            if self.view.frame.origin.y == 0{
    //                self.view.frame.origin.y -= keyboardSize.height
    //            }
    //        }
    //    }
    
    //
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            btnsignup.backgroundColor = mycolor
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
        case firstNameFld:
            lastNameFld.becomeFirstResponder()
            break
        case lastNameFld:
            emailFld.becomeFirstResponder()
            break
        case emailFld:
            phoneFld.becomeFirstResponder()
            break
        case phoneFld:
            passwordFld.becomeFirstResponder()
            break
        case passwordFld:
            textField.resignFirstResponder()
            self.btnsignup.sendActions(for: .touchUpInside)
            break
        default:
            textField.resignFirstResponder()
        }
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
        let Email = emailFld.text!
        let Emailvalid = validateEmail(enteredEmail: Email)
        
        if (firstNameFld.text?.isEmpty)!
        {
            showAlert(title: "Validation Failed".localized(),msg: "Please Enter First Name".localized())
            return false
        }
        else if (lastNameFld.text?.isEmpty)!
        {
            showAlert(title: "Validation Failed".localized(),msg: "Please Enter Last Name".localized())
            return false
        }
        else if (emailFld.text?.isEmpty)!
        {
            showAlert(title: "Validation Failed".localized(),msg: "Please Enter Email Id".localized())
            return false
        }
        else if Emailvalid == false{
            showAlert(title: "Validation Failed".localized(),msg: "Invalid Email Id".localized())
            return false
        }
        else if (phoneFld.text?.isEmpty)!
        {
            showAlert(title: "Validation Failed".localized(),msg: "Please Enter Phone Number".localized())
            return false
        }
        else if(phoneFld.text!.count < 5)
        {
            showAlert(title: "Validation Failed".localized(),msg: "Mobile Number Should be minimum 5 digits".localized())
            return false
            
        }
        else if (passwordFld.text?.isEmpty)!
        {
            showAlert(title: "Validation Failed".localized(),msg: "Please Enter Password".localized())
            return false
        }
        else if passwordFld.text!.count < 6 {
            showAlert(title: "Validation Failed".localized(),msg: "Password should be minimum 6 characters".localized())
            return false
        }
        else{
            return true
        }
        
    }
    
    @IBAction func signUp(_ sender: Any)
    {
        let isValid = validateForm()
        if(isValid)
        {
            let params: Parameters = [
                "first_name": firstNameFld.text!,
                "last_name": lastNameFld.text!,
                "email": emailFld.text!,
                "mobile": phoneFld.text!,
                "password": passwordFld.text!
            ]
            
            let url = APIList().getUrlString(url: .SIGNUP)
            
            SwiftSpinner.show("Signing up...".localized())
            
            Alamofire.request(url,method: .post,parameters:params).responseJSON { response in
                
                //                print("Result: \(response.result)")                         // response serialization result
                if(response.result.isSuccess)
                {
                    SwiftSpinner.hide()
                    if let json = response.result.value {
                        print("SIGNUP JSON: \(json)") // serialized json response
                        let jsonResponse = JSON(json)
                        
                        if(jsonResponse["error"].stringValue == "true")
                        {
                            let errorMessage = jsonResponse["error_message"].stringValue
                            self.showAlert(title: "Signup Failed".localized(),msg: errorMessage)
                        }
                        else{
                            let alert = UIAlertController(title: "Signup Successful".localized(), message: "Please login".localized(), preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: {
                                (alert: UIAlertAction!) in
                                let domain = Bundle.main.bundleIdentifier!
                                UserDefaults.standard.removePersistentDomain(forName: domain)
                                UserDefaults.standard.synchronize()
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
    }
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        if Int(range.location) == 0 && (string == " ")
        {
            return false
        }
        else if (textField == firstNameFld || textField == lastNameFld)
        {
            
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if (string == filtered)
            {
                let maxLength = 15
                let currentString: NSString = textField.text! as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
            }
            else
            {
                return false
            }
            
        }
        else if (textField == phoneFld)
        {
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS1).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if (string == filtered)
            {
                let maxLength = 15
                let currentString: NSString = textField.text! as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
            }
            else
            {
                return false
            }
        }
        else if (textField == emailFld)
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
    
    
    @IBAction func goToLoginPage(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField == phoneFld || textField == firstNameFld || textField == lastNameFld || textField == emailFld
        {
            textField.text = textField.text!.trimmingCharacters(in: .whitespaces)
        }
    }
    
    @IBAction func fbLoginAtn(_ sender: Any)
    {
        if Reachability.isConnectedToNetwork() {
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            
            fbLoginManager.loginBehavior = .web
            
            fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
                if (error == nil){
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    // if user cancel the login
                    if (result?.isCancelled)!{
                        return
                    }
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                    }
                }
            }
        }else{
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    let jsonResponse = JSON(result!)
                    print(jsonResponse)
                    self.firstName = jsonResponse["first_name"].stringValue
                    self.lastName = jsonResponse["last_name"].stringValue
                    self.email = jsonResponse["email"].stringValue
                    self.image = jsonResponse["picture"]["data"]["url"].stringValue
                    let accessToken = FBSDKAccessToken.current().userID
                    self.socialLogin(socialType: "facebook", socialToken: accessToken)
                }
            })
        }
    }
    
    
    @IBAction func googleLoginAtn(_ sender: Any)
    {
        if Reachability.isConnectedToNetwork() {
            GIDSignIn.sharedInstance().delegate=self
            GIDSignIn.sharedInstance().uiDelegate=self
            GIDSignIn.sharedInstance().signIn()
        }else{
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!)
    {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if let error = error
        {
            print("Error = ",error.localizedDescription)
        }
        else
        {
            if error == nil
            {
                firstName = user.profile.givenName
                lastName = user.profile.familyName
                email = user.profile.email
                
                if user.profile.hasImage
                {
                    image = user.profile.imageURL(withDimension: 100).absoluteString
                }
                else
                {
                    image = " "
                }
                let token = user.userID
                self.socialLogin(socialType: "google", socialToken: token)
                
                GIDSignIn.sharedInstance().signOut()
                
            }
        }
    }
    
    func socialLogin(socialType: String!, socialToken : String!)
    {
        var firstname = ""
        var lastname = ""
        var socialtype = ""
        var socialtoken = ""
        var Email = ""
        
        if SharedObject().hasData(value: firstName)
        {
            firstname = firstName
        }
        if SharedObject().hasData(value: lastName)
        {
            lastname = lastName
        }
        if SharedObject().hasData(value: socialType)
        {
            socialtype = socialType
        }
        if SharedObject().hasData(value: socialToken)
        {
            socialtoken = socialToken
        }
        if SharedObject().hasData(value: email)
        {
            Email = email
        }
        
        let params: Parameters = [
            "firstname": firstname,
            "lastname" : lastname,
            "social_type": socialtype,
            "socialtoken":socialtoken,
            "email": Email
        ]
        
        SwiftSpinner.show("Logging in...".localized())
        
        let url = APIList().getUrlString(url: .SOCIALLOGIN)
        
        Alamofire.request(url,method: .post,parameters:params).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("LOGIN JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    print(jsonResponse)
                    if(jsonResponse["error"].stringValue == "true")
                    {
                        let errorMessage = jsonResponse["error_message"].stringValue
                        self.showAlert(title: "Login Failed".localized(),msg: errorMessage)
                    }
                    else{
                        let access_token = "Bearer ".appending(jsonResponse["access_token"].stringValue)
                        
                        let facebook_satatus: Bool = true
                        
                        UserDefaults.standard.set(facebook_satatus, forKey: "facebook_status")
                        UserDefaults.standard.set(access_token, forKey: "access_token")
                        UserDefaults.standard.set(self.firstName, forKey: "first_name")
                        UserDefaults.standard.set(self.lastName, forKey: "last_name")
                        UserDefaults.standard.set(self.image, forKey: "image")
                        //                        UserDefaults.standard.set(mobile, forKey: "mobile")
                        UserDefaults.standard.set(self.email, forKey: "email")
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        
                        self.updateDeviceToken()
                        
                        self.getAppSettings()
                        
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
    
    func getAppSettings()
    {
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
                            MainViewController.status = statusArray
                            self.present(vc, animated: true, completion: nil)
                        }
                        else{
                            let isLoggedInSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
                            if(isLoggedInSkipped)
                            {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
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
                //                self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
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
        
        let url = APIList().getUrlString(url: .UPDATEDEVICETOKEN)
        
        Alamofire.request(url,method: .post,parameters:params, headers:headers).responseJSON { response in
            
            print(response.description)
            
        }
        
    }
    
}
