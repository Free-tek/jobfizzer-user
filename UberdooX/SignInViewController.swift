//
//  SignInViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 12/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Firebase
import FirebaseMessaging
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import Localize_Swift
import CoreLocation

class SignInViewController: UIViewController,UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate,OfflineViewControllerDelegate {
    func tryAgain() {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ "


    @IBOutlet weak var passwordFld: UITextField!
    @IBOutlet weak var UsernameFld: UITextField!
    
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var signInLbl: UILabel!
    
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var orLbl: UILabel!
    
    @IBOutlet weak var dontHaveBtn: UIButton!
    
    @IBOutlet weak var forgotBtn: UIButton!
    
    let locationManager = CLLocationManager()
    
    
    var firstName : String!
    var lastName : String!
    var email : String!
    var image : String!
    var mycolor = UIColor()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()

        passwordFld.delegate = self
        UsernameFld.delegate = self
        
        
        UsernameFld.keyboardType = .emailAddress
        passwordFld.keyboardType = .asciiCapable
        
        UsernameFld.autocorrectionType = .no
        passwordFld.autocorrectionType = .no

        
        
//        UILabel.appearance().substituteFontName = "IRANSans";
//        UITextView.appearance().substituteFontName = "IRANSans";
//        UITextField.appearance().substituteFontName = "IRANSans";
        
        passwordFld.placeholder = "PASSWORD".localized()
        UsernameFld.placeholder = "EMAIL ADDRESS".localized()
        titleLbl.text = "Jobfizzer".localized()
        self.signInLbl.text = "Sign in".localized()
        loginBtn.setTitle("LOGIN".localized(),for: .normal)
        orLbl.text = "or sign in with:"
        dontHaveBtn.setTitle("Don't have an account?".localized(),for: .normal)
        forgotBtn.setTitle("Forgot Password?".localized(),for: .normal)
        
        
        
        titleLbl.font = FontBook.Medium.of(size: 22)
        signInLbl.font = FontBook.Medium.of(size: 20)
        passwordFld.font = FontBook.Regular.of(size: 16)
        UsernameFld.font = FontBook.Regular.of(size: 16)
        loginBtn.titleLabel!.font = FontBook.Regular.of(size: 17)
        orLbl.font = FontBook.Medium.of(size: 14)
        dontHaveBtn.titleLabel!.font = FontBook.Medium.of(size: 14)
        forgotBtn.titleLabel!.font = FontBook.Medium.of(size: 14)

//        changeFont()
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            loginBtn.backgroundColor = mycolor
        }
    }

    
    func validateForm() -> Bool
    {
        UsernameFld.text = UsernameFld.text!.trimmingCharacters(in: .whitespaces)
        let Email = UsernameFld.text
        let Emailvalid = validateEmail(enteredEmail: Email!)
        if (UsernameFld.text?.isEmpty)!
        {
            showAlert(title: "Validation Failed".localized(),msg: "Enter mail Id".localized())
            return false
        }
        else if Emailvalid == false
        {
            showAlert(title: "Validation Failed".localized(),msg: "Invalid Email Id".localized())
            return false
        }
        else if (passwordFld.text?.isEmpty)!
        {
            showAlert(title: "Validation Failed",msg: "Enter the Password".localized())
            return false
        }
        else
        {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
            case UsernameFld:
                passwordFld.becomeFirstResponder()
            break
        case passwordFld:
            passwordFld.resignFirstResponder()
            loginBtn.sendActions(for: .touchUpInside)
            break
        default:
                textField.resignFirstResponder()
        }
        return true
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
            firstname = firstName!
        }
        if SharedObject().hasData(value: lastName)
        {
            lastname = lastName!
        }
        if SharedObject().hasData(value: socialType)
        {
            socialtype = socialType!
        }
        if SharedObject().hasData(value: socialToken)
        {
            socialtoken = socialToken!
        }
        if SharedObject().hasData(value: email)
        {
            Email = email!
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
                        
                        //                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        //                            self.present(vc, animated: true, completion: nil)
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
    
    
    @IBAction func login(_ sender: Any) {
         UserDefaults.standard.set(false, forKey: "isLoggedInSkipped")
        let isValid = validateForm()
        if(isValid)
        {
            UsernameFld.text = UsernameFld.text!.trimmingCharacters(in: .whitespaces)
            let params: Parameters = [
                "email": UsernameFld.text!,
                "user_type": "User",
                "password": passwordFld.text!
            ]
            SwiftSpinner.show("Logging in...".localized())
            let url = APIList().getUrlString(url: .USERLOGIN)

            Alamofire.request(url,method: .post,parameters:params).responseJSON { response in
                
                if(response.result.isSuccess)
                {
                    SwiftSpinner.hide()
                    if let json = response.result.value {
                        print("LOGIN JSON: \(json)") // serialized json response
                        let jsonResponse = JSON(json)
                        if(jsonResponse["error"].stringValue == "true")
                        {
                            let errorMessage = jsonResponse["error_message"].stringValue
                            self.showAlert(title: "Login Failed",msg: errorMessage)
                        }
                        else
                        {
                            let access_token = "Bearer ".appending(jsonResponse["access_token"].stringValue)
                            let first_name = jsonResponse["first_name"].stringValue
                            
                            let last_name = jsonResponse["last_name"].stringValue
                            let image = jsonResponse["image"].stringValue
                            let mobile = jsonResponse["mobile"].stringValue
                            let email = jsonResponse["email"].stringValue
                            let id = jsonResponse["id"].stringValue
                            let facebook_satatus: Bool = false
                            UserDefaults.standard.set(facebook_satatus, forKey: "facebook_status")
                            
                            UserDefaults.standard.set(access_token, forKey: "access_token")
                            UserDefaults.standard.set(first_name, forKey: "first_name")
                            UserDefaults.standard.set(last_name, forKey: "last_name")
                            UserDefaults.standard.set(image, forKey: "image")
                            UserDefaults.standard.set(mobile, forKey: "mobile")
                            UserDefaults.standard.set(email, forKey: "email")
                            UserDefaults.standard.set(id, forKey: "userid")
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")

                            self.updateDeviceToken()
                            
                           self.getAppSettings()
                            
//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//                            self.present(vc, animated: true, completion: nil)
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

        Alamofire.request(url,method: .get, headers:headers).responseJSON
        {
            response in
            
            if(response.result.isSuccess)
            {
                if let json = response.result.value
                {
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
                    else
                    {
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
                        else
                        {
                            let isLoggedInSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
                            if(isLoggedInSkipped)
                            {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                                MainViewController.status = statusArray
                                self.present(vc, animated: true, completion: nil)
                            }
                            else
                            {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnboardViewController") as! OnboardViewController
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            else
            {
                print("Login Error = ",response.error!.localizedDescription)
                self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
/*                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
                self.present(vc, animated: true, completion: nil)*/
            }
        }
    }
    
    func updateDeviceToken()
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

        Alamofire.request(url,method: .post,parameters:params, headers:headers).responseJSON
        {
            response in
            print(response.description)
        }
    }
    
    @IBAction func facebookLogin(_ sender: Any)
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
        }
        else {
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
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error
        {
            print("Error = ",error.localizedDescription)
        }
        else
        {
//            if user.authentication.accessToken != nil
//            {
//                GIDSignIn.sharedInstance().signOut()
//            }
//            else
//            {
                if error == nil
                {
                    firstName = user.profile.givenName
                    lastName = user.profile.familyName
                    email = user.profile.email
                    //            image = user.profile
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
            
//            }
        }
        
    }
    
    
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate=self
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToSignUp(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func goToForgotPassword(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
/*        if textField == UsernameFld
        {
            if Int(range.location) == 0 && (string == " ")
            {
                return false
            }
            else
            {
                return true
            }
        }
        else */
        if (textField == UsernameFld)
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
        if textField == UsernameFld
        {
            textField.text = textField.text!.trimmingCharacters(in: .whitespaces)
        }
    }
    
}
