//
//  AccountViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 13/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON
import Nuke
import UserNotifications

class AccountViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UNUserNotificationCenterDelegate, updateImageDelegate,OfflineViewControllerDelegate
{
    func tryAgain() {
        dismiss(animated: true, completion: nil)
    }
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func updateImage()
    {
        
        if let image = UserDefaults.standard.string(forKey: "image") as String!
        {
            if let imageUrl = URL.init(string: image) as URL!
            {
                Nuke.loadImage(with: imageUrl, into: self.userPicture)
            }
            
        }
        
        if let first_name = UserDefaults.standard.string(forKey: "first_name") as String!
        {
            if let  last_name = UserDefaults.standard.string(forKey: "last_name") as String!{
                nameLbl.text = "\(String(describing: first_name)) \(String(describing: last_name))"
            }
            else{
                nameLbl.text = "\(String(describing: first_name))"
            }
        }
        else
        {
            nameLbl.text = "Guest User"
        }
        
    }
    
    
    //    var changetheme : Bool = false
    
    @IBOutlet weak var clrbtn6: UIButton!
    @IBOutlet weak var clrbtn5: UIButton!
    @IBOutlet weak var clrbtn4: UIButton!
    @IBOutlet weak var clrbtn3: UIButton!
    @IBOutlet weak var clrbtn2: UIButton!
    @IBOutlet weak var clrbtn1: UIButton!
    @IBOutlet weak var collectionvw: UICollectionView!
    @IBOutlet weak var vwchangeTheme: UIView!
    @IBOutlet weak var themeTopView: UIView!
    
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    var titles :[String] = []
    var images :NSArray!
    var userdefaults = UserDefaults.standard
    var Social_Login :Bool = false
    @IBOutlet weak var tableView: UITableView!
    var mycolor = UIColor.init(red: 107 / 255, green: 127 / 255, blue: 252 / 255, alpha: 1.0)
    var color = UIColor()
    var changeTheme : Bool = false
    var color1: UIColor = UIColor.init(red: 107 / 255, green: 127 / 255, blue: 252 / 255, alpha: 1.0)
    var color2: UIColor = UIColor.init(red: 252 / 255, green: 107 / 255, blue: 180 / 255, alpha: 1.0)
    var color3: UIColor = UIColor.init(red: 48 / 255, green: 58 / 255 , blue: 82 / 255, alpha: 1.0)
    var color4: UIColor  = UIColor.init(red: 54 / 255, green: 209 / 255, blue: 196 / 255, alpha: 1.0)
    var color5: UIColor = UIColor.init(red: 165 / 255, green: 107 / 255, blue: 252 / 255, alpha: 1.0)
    var color6: UIColor = UIColor.init(red: 252 / 255, green: 107 / 255, blue: 107 / 255 , alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = UserDefaults.standard.string(forKey: "image") as String!{
            
            if let imageUrl = URL.init(string: image) as URL!{
                Nuke.loadImage(with: imageUrl, into: self.userPicture)
            }
        }
        
        
        nameLbl.font = FontBook.Medium.of(size: 23)
        
        
        themeTopView.isHidden = true
        vwchangeTheme.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        //        Social_Login = userdefaults.object(forKey: "facebook_status")as! Bool
        if userdefaults.object(forKey: "facebook_status") != nil
        {
            Social_Login = userdefaults.object(forKey: "facebook_status") as! Bool
        }
        else {
            Social_Login = false
        }
        clrbtn1.layer.cornerRadius = clrbtn1.frame.size.width / 2
        clrbtn1.layer.masksToBounds = true
        clrbtn2.layer.cornerRadius = clrbtn2.frame.size.width / 2
        clrbtn2.layer.masksToBounds = true
        clrbtn3.layer.cornerRadius = clrbtn3.frame.size.width / 2
        clrbtn3.layer.masksToBounds = true
        clrbtn4.layer.cornerRadius = clrbtn4.frame.size.width / 2
        clrbtn4.layer.masksToBounds = true
        clrbtn5.layer.cornerRadius = clrbtn5.frame.size.width / 2
        clrbtn5.layer.masksToBounds = true
        clrbtn6.layer.cornerRadius = clrbtn6.frame.size.width / 2
        clrbtn6.layer.masksToBounds = true
        let isLoggedInSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
        if(isLoggedInSkipped)
        {
            //            self.titles = NSArray(objects: "About Us","Help and FAQ","Login") as! [String]
            //            self.images = NSArray(objects:"new_about_us","info","new_logout")
            
            self.titles = NSArray(objects: "About Us","Login") as! [String]
            self.images = NSArray(objects:"new_about_us","new_logout")
            
        }
        else{
            if !Social_Login
            {
                //                self.titles = NSArray(objects: "Profile","Change Password","Addresses","About Us","Help and FAQ","Change Color","Logout") as! [String]
                //
                //                self.images = NSArray(objects:"new_profile","new_change_passsword","new_address","new_about_us","info","Themes-1","new_logout")
                
                
                self.titles = NSArray(objects: "Profile","Change Password","Addresses","About Us","Change Theme","Logout") as! [String]
                
                self.images = NSArray(objects:"new_profile","new_change_passsword","new_address","new_about_us","Themes-1","new_logout")
                
            }
            else
            {
                //                self.titles = NSArray(objects: "Profile","Addresses","About Us","Help and FAQ","Change Theme","Logout") as! [String]
                //                self.images = NSArray(objects:"new_profile","new_address","new_about_us","info","Themes-1","new_logout")
                
                
                self.titles = NSArray(objects: "Profile","Addresses","About Us","Change Theme","Logout") as! [String]
                self.images = NSArray(objects:"new_profile","new_address","new_about_us","Themes-1","new_logout")
                
            }
        }
        
        
        
        //        let height = self.titles.count * 70;
        //        tableView.frame = CGRect.init(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: CGFloat(height))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let image = UserDefaults.standard.string(forKey: "image") as String!
        {
            if let imageUrl = URL.init(string: image) as URL!{
                Nuke.loadImage(with: imageUrl, into: self.userPicture)
            }
            else
            {
                if UserDefaults.standard.object(forKey: "myColor") != nil
                {
                    
                    let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                    //            var color: UIColor? = nil
                    mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor

                    changeTintColor(userPicture, arg: mycolor)
                }else{
                    print("ok")
                }
                
            }
        }
        else
        {
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                
                changeTintColor(userPicture, arg: mycolor)
            }
            
        }
        //        else {
        //            if let image = UserDefaults.standard.string(forKey: "image") as String!{
        //
        //                if let imageUrl = URL.init(string: image) as URL!{
        //                    Nuke.loadImage(with: imageUrl, into: self.userPicture)
        //                }
        //            }
        //        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let image = UserDefaults.standard.string(forKey: "image") as String!{
            
            if let imageUrl = URL.init(string: image) as URL!{
                Nuke.loadImage(with: imageUrl, into: self.userPicture)
            }
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        if let first_name = UserDefaults.standard.string(forKey: "first_name") as String!
        {
            if let  last_name = UserDefaults.standard.string(forKey: "last_name") as String!{
                nameLbl.text = "\(String(describing: first_name)) \(String(describing: last_name))"
            }
            else{
                nameLbl.text = "\(String(describing: first_name))"
            }
        }
        else{
            nameLbl.text = "Guest User".localized()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
        
        cell.selectionStyle = .none
        
        
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
            
            let imagename = self.images.object(at: indexPath.row) as! String
            cell.icon.image = UIImage(named:imagename)
            //             cell.icon.tintColor = mycolor
            changeTintColor(cell.icon, arg: mycolor)
            tabBarController?.tabBar.tintColor = mycolor
            
            cell.title.text = self.titles[indexPath.row].localized()
            
            
            //            print("mycolor****",mycolor)
        }
        else {
            let imgname = images.object(at: indexPath.row) as! String
            cell.icon.image = UIImage(named: imgname)
            cell.title.text = self.titles[indexPath.row].localized()
        }
        //        cell.title.text = self.titles[indexPath.row]
        
        
        return cell
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.titles = NSArray(objects: "View Profile","Change Password","About Us","Help and FAQ","Logout")
        
        if(self.titles[indexPath.row] == "Profile")
        {
            if Reachability.isConnectedToNetwork() {
                print(self.titles[indexPath.row])
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                MainViewController.changePage = false
                vc.updateDelegate = self
                self.present(vc, animated: true, completion: nil)
            }else{
                let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
                let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
                Dvc.modalTransitionStyle = .crossDissolve
                Dvc.delegate = self
                present(Dvc, animated: true, completion: nil)
            }
        }
        else if(self.titles[indexPath.row] == "Change Password")
        {
            if Reachability.isConnectedToNetwork() {
                print(self.titles[indexPath.row])
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
                MainViewController.changePage = false
                self.present(vc, animated: true, completion: nil)
            }else{
                let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
                let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
                Dvc.modalTransitionStyle = .crossDissolve
                Dvc.delegate = self
                present(Dvc, animated: true, completion: nil)
            }
        }
        else if(self.titles[indexPath.row] == "About Us")
        {
            if Reachability.isConnectedToNetwork() {
                print(self.titles[indexPath.row])
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                vc.titleString = "About Us".localized()
                MainViewController.changePage = false
                self.present(vc, animated: true, completion: nil)
            }else{
                let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
                let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
                Dvc.modalTransitionStyle = .crossDissolve
                Dvc.delegate = self
                present(Dvc, animated: true, completion: nil)
            }
        }
        else if(self.titles[indexPath.row] == "Help and FAQ")
        {
            print(self.titles[indexPath.row])
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            vc.titleString = "Help and FAQ".localized()
            MainViewController.changePage = false
            self.present(vc, animated: true, completion: nil)
            print(self.titles[indexPath.row])
        }
        else if(self.titles[indexPath.row] == "Addresses")
        {
            if Reachability.isConnectedToNetwork() {
                print(self.titles[indexPath.row])
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressesViewController") as! AddressesViewController
                MainViewController.changePage = false
                self.present(vc, animated: true, completion: nil)
                print(self.titles[indexPath.row])
            }else{
                let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
                let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
                Dvc.modalTransitionStyle = .crossDissolve
                Dvc.delegate = self
                present(Dvc, animated: true, completion: nil)
            }
        }
        else if(self.titles[indexPath.row] == "Change Theme"){
            if changeTheme
            {
                changeTheme = false
                vwchangeTheme.isHidden = true
                themeTopView.isHidden = true
                
            }
            else {
                changeTheme = true
                vwchangeTheme.isHidden = false
                //                themeTopView.isHidden = false
                
                self.setView(view: themeTopView, hidden: false)
            }
            
        }
        else if(self.titles[indexPath.row] == "Logout" || self.titles[indexPath.row] == "Login")
        {
            print(self.titles[indexPath.row])
            let isLoggedInSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
            UserDefaults.standard.set(false, forKey: "isLoggedInSkipped")
            
            if (self.titles[indexPath.row] == "Login")
            {
                self.signIn()
            }
            else if(isLoggedInSkipped)
            {
                self.login()
            }
            else{
                self.logout()
            }
            
        }
    }
    
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    
    
    @IBAction func clrbtn6(_ sender: Any) {
        let colorData = NSKeyedArchiver.archivedData(withRootObject: color6)
        mycolor = color6
        UserDefaults.standard.set(colorData, forKey: "myColor")
        vwchangeTheme.isHidden = true
        themeTopView.isHidden = true
        
        self.chageColor()
    }
    @IBAction func clrbtn5(_ sender: Any) {
        let colorData = NSKeyedArchiver.archivedData(withRootObject: color5)
        mycolor = color5
        UserDefaults.standard.set(colorData, forKey: "myColor")
        vwchangeTheme.isHidden = true
        themeTopView.isHidden = true
        self.chageColor()
        
    }
    @IBAction func clrbtn4(_ sender: Any) {
        let colorData = NSKeyedArchiver.archivedData(withRootObject: color4)
        mycolor = color4
        UserDefaults.standard.set(colorData, forKey: "myColor")
        vwchangeTheme.isHidden = true
        themeTopView.isHidden = true
        self.chageColor()
        
    }
    @IBAction func clrbtn3(_ sender: Any) {
        let colorData = NSKeyedArchiver.archivedData(withRootObject: color3)
        mycolor = color3
        UserDefaults.standard.set(colorData, forKey: "myColor")
        vwchangeTheme.isHidden = true
        themeTopView.isHidden = true
        
        self.chageColor()
        
    }
    @IBAction func clrbtn2(_ sender: Any) {
        let colorData = NSKeyedArchiver.archivedData(withRootObject: color2)
        mycolor = color2
        UserDefaults.standard.set(colorData, forKey: "myColor")
        vwchangeTheme.isHidden = true
        themeTopView.isHidden = true
        
        self.chageColor()
        
    }
    @IBAction func clrbtn1(_ sender: Any) {
        let colorData = NSKeyedArchiver.archivedData(withRootObject: color1)
        mycolor = color1
        UserDefaults.standard.set(colorData, forKey: "myColor")
        vwchangeTheme.isHidden = true
        themeTopView.isHidden = true
        
        self.chageColor()
        
    }
    
    func chageColor()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        vc.isFrom = "color"
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //    func saveColor() {
    //        let colorData = NSKeyedArchiver.archivedData(withRootObject: themeColor)
    //        UserDefaults.standard.set(colorData, forKey: "themeColor")
    //        topView.backgroundColor = themeColor
    //        changeTintColor(userImg, arg: themeColor)
    //        changeTintColor(notImg, arg: themeColor)
    //        changeTintColor(privacyImg, arg: themeColor)
    //        changeTintColor(themeImg, arg: themeColor)
    //    }
    
    
    /*   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     return color.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     let cell: ChangethemeCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "ChangethemeCVC", for: indexPath)as! ChangethemeCVC
     cell.vwcolor.backgroundColor = color[indexPath.row]
     cell.vwcolor.layer.cornerRadius = cell.vwcolor.frame.size.width / 2
     cell.vwcolor.layer.masksToBounds = true
     return cell
     }
     */
    /*    func showAlert(title: String,msg : String)
     {
     let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
     
     // add an action (button)
     alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
     
     // show the alert
     self.present(alert, animated: true, completion: nil)
     }*/
    
    
    func signIn()
    {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func login()
    {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnboardViewController") as! OnboardViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func logout()
    {
        let accesstoken = UserDefaults.standard.string(forKey: "access_token") as String!
        print(accesstoken!)
        let headers: HTTPHeaders = [
            "Authorization": accesstoken!,
            "Accept": "application/json"
        ]
        
        SwiftSpinner.show("Logging out...".localized())
        
        let url = APIList().getUrlString(url: .LOGOUT)
        
        Alamofire.request(url,method: .get,headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("LOGOUT JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    print("mycolor =\(self.mycolor)")
                    if self.mycolor != nil
                    {
                        let colorData = NSKeyedArchiver.archivedData(withRootObject: self.mycolor)
                        UserDefaults.standard.set(colorData, forKey: "myColor")
                    }
                    
                    if(jsonResponse["error"].stringValue == "Unauthenticated" || jsonResponse["error"].stringValue == "true")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        
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
    
    /*    {
     getAppSettings()
     //        completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
     
     }*/
    
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
                            if(currentStatus == "Completedjob")
                            {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
                                vc.bookingDetails = statusDict
                                vc.modalPresentationStyle = .overCurrentContext
                                self.present(vc, animated: true, completion: nil)
                            }
                            else if(currentStatus == "Waitingforpaymentconfirmation"){
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WaitingForPaymentConfirmationViewController") as! WaitingForPaymentConfirmationViewController
                                vc.bookingDetails = statusDict
                                self.present(vc, animated: true, completion: nil)
                            }
                            else if(currentStatus == "Reviewpending"){
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
    
    @IBAction func closeBtn(_ sender: Any)
    {
        changeTheme = false
        self.setView(view: vwchangeTheme, hidden: true)
        self.setView(view: themeTopView, hidden: true)
    }
    
    
}
