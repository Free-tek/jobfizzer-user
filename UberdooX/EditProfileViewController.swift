//
//  EditProfileViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 03/02/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Nuke

protocol updateImageDelegate
{
    func updateImage()
}
class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate,OfflineViewControllerDelegate
{
    func tryAgain() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ "
    let ACCEPTABLE_CHARACTERS1 = "0123456789+"
    @IBOutlet weak var titleLbl: UILabel!
    
    
    var imageName = " "
    @IBOutlet weak var phoneNumberTxtFld: UITextField!
    @IBOutlet weak var lastNameTxtFld: UITextField!
    @IBOutlet weak var firstNameTxtFld: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var btnSave: UIButton!
    var updateDelegate: updateImageDelegate?
    var imageclicked = true
    var mycolor = UIColor()
    var isback = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        lastNameTxtFld.delegate = self
        firstNameTxtFld.delegate = self
        phoneNumberTxtFld.delegate = self
        
        lastNameTxtFld.keyboardType = .asciiCapable
        firstNameTxtFld.keyboardType = .asciiCapable
        
        lastNameTxtFld.autocorrectionType = .no
        firstNameTxtFld.autocorrectionType = .no
        
        
        titleLbl.text = "Edit Profile".localized()
        firstNameTxtFld.placeholder = "First Name".localized()
        lastNameTxtFld.placeholder = "Last Name".localized()
        phoneNumberTxtFld.placeholder = "Phone number".localized()
        btnSave.setTitle("SAVE".localized(),for: .normal)
        
        titleLbl.font = FontBook.Medium.of(size: 20)
        firstNameTxtFld.font = FontBook.Regular.of(size: 17)
        lastNameTxtFld.font = FontBook.Regular.of(size: 17)
        phoneNumberTxtFld.font = FontBook.Regular.of(size: 17)
        btnSave.titleLabel!.font = FontBook.Regular.of(size: 17)
        
        self.getProfile()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if !isback
        {
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                btnSave.backgroundColor = mycolor
                changeTintColor(profilePicture, arg: mycolor)
                
            }
        }
    }
    func changeTintColor(_ img: UIImageView?, arg color: UIColor?) {
        if let aColor = color {
            img?.tintColor = aColor
        }
        var newImage: UIImage? = img?.image?.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions((img?.image?.size)!, false, (img?.image?.scale)!)
        color?.set()
        newImage?.draw(in: CGRect(x: 0, y: 0, width: img?.image?.size.width ?? 0.0, height: img?.image?.size.height ?? 0.0))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        img?.image = newImage
    }
    
    
    
    func getProfile(){
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
        
        SwiftSpinner.show("Fetching Profile Details...".localized())
        
        let url = APIList().getUrlString(url: .VIEWPROFILE)
        
        Alamofire.request(url,method: .get, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("VIEW PROFILE JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    if(jsonResponse["error"].stringValue == "Unauthenticated" || jsonResponse["error"].stringValue == "true")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else{
                        self.firstNameTxtFld.text = jsonResponse["user_details"]["first_name"].stringValue
                        self.lastNameTxtFld.text = jsonResponse["user_details"]["last_name"].stringValue
                        self.phoneNumberTxtFld.text = jsonResponse["user_details"]["mobile"].stringValue
                        if let image = jsonResponse["user_details"]["image"].string{
                            self.imageName = image
                            if let imageUrl = URL.init(string: image) as URL!{
                                Nuke.loadImage(with: imageUrl, into: self.profilePicture)
                            }
                        }
                        else
                        {
                            if UserDefaults.standard.object(forKey: "myColor") != nil
                            {
                                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                                //            var color: UIColor? = nil
                                self.mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                                //                            self.btnSave.backgroundColor = mycolor
                                self.changeTintColor(self.profilePicture, arg: self.mycolor)
                                
                            }
                        }
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
    
    /*
     func showAlert(title: String,msg : String)
     {
     let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
     
     // add an action (button)
     alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
     
     // show the alert
     self.present(alert, animated: true, completion: nil)
     }*/
    
    @IBAction func profilePictureClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".localized(), style: .default, handler: {
            action in
            
            picker.sourceType = .camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library".localized(), style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        isback = true
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.profilePicture.image = image
        imageclicked = false
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isback = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage()
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
            //        let url = "\(Constants.adminBaseURL)/imageupload"
            print(imageName)
            if imageclicked
            {
                print("Image is empty")
                self.setProfile()
            }
            else {
                //let url = APIList().getAdminUrlString(url: .IMAGEUPLOAD)
                let url = APIList().getUrlString(url: .IMAGEUPLOAD)
                
                _ = try! URLRequest(url: url, method: .post)
                let img = self.profilePicture.image
                let imagedata = UIImageJPEGRepresentation(img!, 0.6)
                
                
                
                SwiftSpinner.show("Uploading Image".localized())
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    if let data = imagedata{
                        multipartFormData.append(data, withName: "file", fileName: "image.png", mimeType: "image/png")
                    }
                }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers, encodingCompletion: { (result) in
                    
                    switch result
                    {
                    case .success(let upload, _, _):
                        upload.responseJSON
                            { response in
                                print("Upload Image = ",response)
                                let jsonResponse = JSON(response.result.value)
                                
                                if let err = response.error
                                {
                                    self.showAlert(title: "Oops".localized(), msg: jsonResponse["error_message"].stringValue)
                                    print(err)
                                    return
                                }
                                else
                                {
                                    self.imageName = jsonResponse["image"].stringValue
                                    print("Succesfully uploaded")
                                    self.setProfile()
                                    
                                }
                        }
                    case .failure(let error):
                        print("Error in upload: \(error.localizedDescription)")
                        
                        self.showAlert(title: "Oops".localized(), msg: error.localizedDescription)
                        
                    }
                })
            }
        }else{
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if(firstNameTxtFld.text != "")
        {
            if(lastNameTxtFld.text != "")
            {
                if(phoneNumberTxtFld.text != "")
                {
                    self.uploadImage()
                }
                else
                {
                    self.showAlert(title: "Validation Failed".localized(), msg: "Please Enter Phone Number".localized())
                }
                
            }
            else{
                self.showAlert(title: "Validation Failed".localized(), msg: "Please Enter Last Name".localized())
            }
        }
        else{
            self.showAlert(title: "Validation Failed".localized(), msg: "Please Enter First Name".localized())
        }
        
    }
    
    func setProfile()
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
        
        var params = Parameters()
        
        if SharedObject().hasData(value: self.imageName)
        {
            params = [
                "first_name": firstNameTxtFld.text!,
                "last_name": lastNameTxtFld.text!,
                "mobile": phoneNumberTxtFld.text!,
                "image": self.imageName
            ]
        }
        else
        {
            params = [
                "first_name": firstNameTxtFld.text!,
                "last_name": lastNameTxtFld.text!,
                "mobile": phoneNumberTxtFld.text!,
                "image": " "
            ]
        }
        
        
        print("Params = ",params)
        
        
        SwiftSpinner.show("Updating Profile Details...".localized())
        
        let url = APIList().getUrlString(url: .UPDATEPROFILE)
        
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("EDIT PROFILE JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    if(jsonResponse["error"].stringValue == "Unauthenticated"){
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }else if(jsonResponse["error"].stringValue == "true"){
                        self.showAlert(title: "Oops".localized(), msg: jsonResponse["error_message"].stringValue)
                        print(jsonResponse["error_message"].stringValue)
                    }else{
                        UserDefaults.standard.set(self.imageName, forKey: "image")
                        UserDefaults.standard.set(self.firstNameTxtFld.text, forKey: "first_name")
                        self.updateDelegate?.updateImage()
                        UserDefaults.standard.set(self.lastNameTxtFld.text, forKey: "last_name")
                        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
        if (textField == lastNameTxtFld || textField == firstNameTxtFld)
        {
            textField.text = textField.text!.trimmingCharacters(in: .whitespaces)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        if Int(range.location) == 0 && (string == " ")
        {
            return false
        }
        else if (textField == lastNameTxtFld || textField == firstNameTxtFld)
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
        else if (textField == phoneNumberTxtFld){
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
        else
        {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
        case firstNameTxtFld:
            lastNameTxtFld.becomeFirstResponder()
        case lastNameTxtFld:
            phoneNumberTxtFld.becomeFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    
}
